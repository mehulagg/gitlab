---
stage: Configure
group: Configure
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#designated-technical-writers
---

# GitLab Kubernetes Agent **(PREMIUM ONLY)**

> - [Introduced](https://gitlab.com/gitlab-org/gitlab/-/issues/223061) in [GitLab Premium](https://about.gitlab.com/pricing/) 13.4.
> - It's disabled on GitLab.com. Rolling this feature out to GitLab.com is [planned](https://gitlab.com/groups/gitlab-org/-/epics/3834).

CAUTION: **Warning:**
This feature might not be available to you. Check the **version history** note above for details.

The [GitLab Kubernetes Agent](https://gitlab.com/gitlab-org/cluster-integration/gitlab-agent)
is an active in-cluster component for solving GitLab and Kubernetes integration
tasks in a secure and cloud-native way. It enables:

- Integrating GitLab with a Kubernetes cluster behind a firewall or NAT
  (network address translation).
- Pull-based GitOps deployments by leveraging the
  [GitOps Engine](https://github.com/argoproj/gitops-engine).
- Real-time access to API endpoints within a cluster.

Many more features are planned. Please [review our roadmap](https://gitlab.com/groups/gitlab-org/-/epics/3329).

## Architecture

### GitLab Agent GitOps workflow

```mermaid
sequenceDiagram
  participant D as Developer
  participant A as Application code repository
  participant M as Manifest repository
  participant K as Kubernetes agent
  participant C as Agent configuration repository
  K->C: Grab the configuration
  D->>+A: Pushing code changes
  A->>M: Updating manifest
  loop Regularly
    K-->>M: Watching changes
    M-->>K: Pulling and applying changes
  end
```

Please refer to our [full architecture documentation](https://gitlab.com/gitlab-org/cluster-integration/gitlab-agent/-/blob/master/doc/architecture.md#high-level-architecture)
in the Agent project.

## Get started with GitOps and the GitLab Agent

There are several components that work in concert for the Agent to accomplish GitOps deployments:

- A properly-configured Kubernetes cluster.
- A configuration repository that contains a `config.yaml` file, which tells the
  Agent which repositories to synchronize with.
- A manifest repository that contains a `manifest.yaml`, which is tracked by the
  Agent and can be auto-generated. Any changes to `manifest.yaml` are applied to the cluster.

The setup process involves a few steps to enable GitOps deployments:

1. [Installing the Agent server](#install-the-kubernetes-agent-server).
1. [Defining a configuration directory](#define-a-configuration-repository).
1. [Creating an Agent record in GitLab](#create-an-agent-record-in-gitlab).
1. [Generating and copying a Secret token used to connect to the Agent](#create-the-kubernetes-secret).
1. [Installing the Agent into the cluster](#install-the-agent-into-the-cluster).
1. [Creating a `manifest.yaml`](#create-a-manifestyaml).

### Install the Kubernetes Agent Server

The GitLab Kubernetes Agent Server (KAS) can be deployed using [Omnibus
GitLab](https://docs.gitlab.com/omnibus/) or the [GitLab
chart](https://gitlab.com/gitlab-org/charts/gitlab). If you don't already have
GitLab installed, please refer to our [installation
documentation](https://docs.gitlab.com/ee/install/README.html).

NOTE: **Note:**
GitLab plans to include the KAS on [GitLab.com](https://gitlab.com/groups/gitlab-org/-/epics/3834).

When using the [Omnibus GitLab](https://docs.gitlab.com/omnibus/) package:

1. Edit `/etc/gitlab/gitlab.rb`:

    ```plaintext
    gitlab_kas['enable'] = true
    ```

1. [Reconfigure GitLab](../../../administration/restart_gitlab.md#omnibus-gitlab-reconfigure).

When installing or upgrading the GitLab Helm chart, consider the following Helm 2 example.
(If you're using Helm 3, you must modify this example.) You must set `global.kas.enabled=true`
for the KAS to be properly installed and configured:

```shell
helm repo update
helm upgrade --force --install gitlab gitlab/gitlab \
  --timeout 600 \
  --set global.hosts.domain=<YOUR_DOMAIN> \
  --set global.hosts.externalIP=<YOUR_IP> \
  --set certmanager-issuer.email=<YOUR_EMAIL> \
  --set name=gitlab-instance \
  --set global.kas.enabled=true
```

If you need to specify other options related to kas sub-chart, they should be specified in
`gitlab.kas` sub-section of your `values.yaml` file like this:

```shell
gitlab:
  kas:
    # put your kas custom options here
```

For details, see the doc [Using the GitLab-Kas chart](https://docs.gitlab.com/charts/charts/gitlab/kas/).

### Define a configuration repository

Next, you need a GitLab repository to contain your Agent configuration. The minimal
repository layout looks like this:

```plaintext
.gitlab/agents/<agent-name>/config.yaml
```

The `config.yaml` file contents should look like this. Note that you may speficy multiple manifest
projects in the section `manifest_projects`:

```yaml
gitops:
  manifest_projects:
  - id: "path-to/your-manifest-project-number1"
  ...
```

### Create an Agent record in GitLab

Next, create an GitLab Rails Agent record so the Agent can associate itself with
the configuration repository project. Creating this record also creates a Secret needed to configure
the Agent in subsequent steps. You can create an Agent record either:

- Through the Rails console, see [Starting a Rails console session](../../../administration/operations/rails_console.md#starting-a-rails-console-session) for details how to start it:

  ```ruby
  project = ::Project.find_by_full_path("path-to/your-configuration-project")
  # agent-name should be the same as specified above in the config.yaml
  agent = ::Clusters::Agent.create(name: "<agent-name>", project: project)
  token = ::Clusters::AgentToken.create(agent: agent)
  token.token # this will print out the token you need to use on the next step
  ```

- Through GraphQL: **(PREMIUM ONLY)**

  ```graphql
  mutation createAgent {
    # agent-name should be the same as specified above in the config.yaml
    createClusterAgent(input: { projectPath: "path-to/your-configuration-project", name: "<agent-name>" }) {
      clusterAgent {
        id
        name
      }
      errors
    }
  }

  mutation createToken {
    clusterAgentTokenCreate(input: { clusterAgentId: <cluster-agent-id-taken-from-the-previous-mutation> }) {
      secret # This is the value you need to use on the next step
      token {
        createdAt
        id
      }
      errors
    }
  }
  ```

  NOTE: **Note:**
  GraphQL only displays the token once, after creating it.

  If you are new to using the GitLab GraphQL API, refer to the
  [Getting started with the GraphQL API page](../../../api/graphql/getting_started.md),
  or the [GraphQL Explorer](https://gitlab.com/-/graphql-explorer).

### Create the Kubernetes secret

After generating the token, you must apply it to the Kubernetes cluster.

1. If you haven't previous defined or created a namespace, run the following command:

   ```shell
   kubectl create namespace <YOUR-DESIRED-NAMESPACE>
   ```

1. Run the following command to create your Secret:

   ```shell
   kubectl create secret generic -n <YOUR-DESIRED-NAMESPACE> gitlab-agent-token --from-literal=token='YOUR_AGENT_TOKEN'
   ```

### Install the Agent into the cluster

Next, install the in-cluster component of the Agent. This example file contains the
Kubernetes resources required for the Agent to be installed. You can modify this
example [`resources.yml` file](#example-resourcesyml-file) in the following ways:

- You will need to replace `namespace: gitlab-agent` with `namespace: <YOUR-DESIRED-NAMESPACE>`.
- There are several ways how `kas-address` (Kubernetes Agent Server) can be configured. The agent can use the WebSockets
  or gRPC protocols to connect to the Agent Server. Depending on your cluster configuration and GitLab architecture, 
  you may need to use one or the other.
  - By default, `wss` scheme (an encrypted WebSockets connection) is used after you install `gitlab-kas` sub-chart or
    enable `kas` for Omnibus GitLab. In this case, you will need to set `wss://GitLab.host.tld:443/-/kubernetes-agent` as 
    `kas-address` where `GitLab.host.tld` is your GitLab hostname.
  - Specify the `ws` scheme (such as `ws://GitLab.host.tld:80/-/kubernetes-agent`) to use an unencrypted WebSockets connection.
  - `grpc` scheme can be used if both Agent and Server are installed in one cluster. In this case, you may specify `kas-address` value as
    `grpc://gitlab-kas.<your-namespace>:5005`) to use gRPC directly. Here `gitlab-kas` is the name of the service created by `gitlab-kas` chart,
    and `your-namespace` is the namespace where the chart was installed. Encrypted gRPC is not supported yet. Follow the
    [Support TLS for gRPC communication issue](https://gitlab.com/gitlab-org/cluster-integration/gitlab-agent/-/issues/7)
    for progress updates.
- If you defined your own secret name, replace `gitlab-agent-token` with your secret name in `secretName:` section.

To apply this file, run the following command:

```shell
kubectl apply -n <YOUR-DESIRED-NAMESPACE> -f ./resources.yml
```

To review your configuration, run the following command:

```shell
$ kubectl get pods -n <YOUR-DESIRED-NAMESPACE>

NAMESPACE     NAME                               READY   STATUS    RESTARTS   AGE
gitlab-agent  gitlab-agent-77689f7dcb-5skqk      1/1     Running   0          51s
```

#### Example `resources.yml` file

```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: gitlab-agent
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: gitlab-agent
spec:
  replicas: 1
  selector:
    matchLabels:
      app: gitlab-agent
  template:
    metadata:
      labels:
        app: gitlab-agent
    spec:
      serviceAccountName: gitlab-agent
      containers:
      - name: agent
        image: "registry.gitlab.com/gitlab-org/cluster-integration/gitlab-agent/agentk:latest"
        args:
        - --token-file=/config/token
        - --kas-address
        - wss://gitlab.host.tld:443/-/kubernetes-agent
        volumeMounts:
        - name: token-volume
          mountPath: /config
      volumes:
      - name: token-volume
        secret:
          secretName: gitlab-agent-token
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 0
      maxUnavailable: 1
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: gitlab-agent-write
rules:
- resources:
  - '*'
  apiGroups:
  - '*'
  verbs:
  - create
  - update
  - delete
  - patch
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: gitlab-agent-write-binding
roleRef:
  name: gitlab-agent-write
  kind: ClusterRole
  apiGroup: rbac.authorization.k8s.io
subjects:
- name: gitlab-agent
  kind: ServiceAccount
  namespace: gitlab-agent
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: gitlab-agent-read
rules:
- resources:
  - '*'
  apiGroups:
  - '*'
  verbs:
  - get
  - list
  - watch
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: gitlab-agent-read-binding
roleRef:
  name: gitlab-agent-read
  kind: ClusterRole
  apiGroup: rbac.authorization.k8s.io
subjects:
- name: gitlab-agent
  kind: ServiceAccount
  namespace: gitlab-agent
```

### Create a `manifest.yaml`

In a previous step, you configured a `config.yaml` to point to the GitLab projects
the Agent should synchronize. In each of those projects, you must create a `manifest.yaml`
file for the Agent to monitor. You can auto-generate this `manifest.yaml` with a
templating engine or other means. Note that currently only public projects are supported as
manifest projects. The ability to use private projects will be added in scope of the issue
[Agent authorization for private manifest projects](https://gitlab.com/gitlab-org/gitlab/-/issues/220912).

Each time you commit and push a change to this file, the Agent logs the change:

```plaintext
2020-09-15_14:09:04.87946 gitlab-k8s-agent      : time="2020-09-15T10:09:04-04:00" level=info msg="Config: new commit" agent_id=1 commit_id=e6a3651f1faa2e928fe6120e254c122451be4eea
```

#### Example `manifest.yaml` file

This file creates a simple NGINX deployment.

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
  namespace: gitlab-agent  # Can be any namespace managed by you that the agent has access to.
spec:
  selector:
    matchLabels:
      app: nginx
  replicas: 2
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:1.14.2
        ports:
        - containerPort: 80
```

## Example projects

This basic GitOps example deploys NGINX:

- [Configuration repository](https://gitlab.com/gitlab-org/configure/examples/kubernetes-agent)
- [Manifest repository](https://gitlab.com/gitlab-org/configure/examples/gitops-project)
