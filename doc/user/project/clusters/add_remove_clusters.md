---
stage: Configure
group: Configure
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#assignments
---

# Adding and removing Kubernetes clusters **(FREE)**

GitLab offers integrated cluster creation for the following Kubernetes providers:

- Google Kubernetes Engine (GKE).
- Amazon Elastic Kubernetes Service (EKS).

GitLab can also integrate with any standard Kubernetes provider, either on-premise or hosted.

NOTE:
Watch the webcast [Scalable app deployment with GitLab and Google Cloud Platform](https://about.gitlab.com/webcast/scalable-app-deploy/)
and learn how to spin up a Kubernetes cluster managed by Google Cloud Platform (GCP)
in a few clicks.

NOTE:
Every new Google Cloud Platform (GCP) account receives
[$300 in credit upon sign up](https://console.cloud.google.com/freetrial).
In partnership with Google, GitLab is able to offer an additional $200 for new GCP
accounts to get started with the GitLab integration with Google Kubernetes Engine.
[Follow this link](https://cloud.google.com/partners/partnercredit/?pcn_code=0014M00001h35gDQAQ#contact-form)
to apply for credit.

## Before you begin

Before [adding a Kubernetes cluster](#create-new-cluster) using GitLab, you need:

- GitLab itself. Either:
  - A [GitLab.com account](https://about.gitlab.com/pricing/#gitlab-com).
  - A [self-managed installation](https://about.gitlab.com/pricing/#self-managed) with GitLab version
    12.5 or later. This ensures the GitLab UI can be used for cluster creation.
- The following GitLab access:
  - [Maintainer role for a project](../../permissions.md#project-members-permissions) for a
    project-level cluster.
  - [Maintainer role for a group](../../permissions.md#group-members-permissions) for a
    group-level cluster.
  - [Admin Area access](../../admin_area/index.md) for a self-managed instance-level
    cluster. **(FREE SELF)**

## Access controls

> - Restricted service account for deployment was [introduced](https://gitlab.com/gitlab-org/gitlab-foss/-/issues/51716) in GitLab 11.5.

When creating a cluster in GitLab, you are asked if you would like to create either:

- A [Role-based access control (RBAC)](https://kubernetes.io/docs/reference/access-authn-authz/rbac/)
  cluster, which is the GitLab default and recommended option.
- An [Attribute-based access control (ABAC)](https://kubernetes.io/docs/reference/access-authn-authz/abac/) cluster.

GitLab creates the necessary service accounts and privileges to install and run
[GitLab managed applications](index.md#installing-applications). When GitLab creates the cluster,
a `gitlab` service account with `cluster-admin` privileges is created in the `default` namespace
to manage the newly created cluster.

The first time you install an application into your cluster, the `tiller` service
account is created with `cluster-admin` privileges in the
`gitlab-managed-apps` namespace. This service account is used by Helm to
install and run [GitLab managed applications](index.md#installing-applications).

Helm also creates additional service accounts and other resources for each
installed application. Consult the documentation of the Helm charts for each application
for details.

If you are [adding an existing Kubernetes cluster](add_remove_clusters.md#add-existing-cluster),
ensure the token of the account has administrator privileges for the cluster.

The resources created by GitLab differ depending on the type of cluster.

### Important notes

Note the following about access controls:

- Environment-specific resources are only created if your cluster is
  [managed by GitLab](index.md#gitlab-managed-clusters).
- If your cluster was created before GitLab 12.2, it uses a single namespace for all project
  environments.

### RBAC cluster resources

GitLab creates the following resources for RBAC clusters.

| Name                  | Type                 | Details                                                                                                    | Created when           |
|:----------------------|:---------------------|:-----------------------------------------------------------------------------------------------------------|:-----------------------|
| `gitlab`              | `ServiceAccount`     | `default` namespace                                                                                        | Creating a new cluster |
| `gitlab-admin`        | `ClusterRoleBinding` | [`cluster-admin`](https://kubernetes.io/docs/reference/access-authn-authz/rbac/#user-facing-roles) roleRef | Creating a new cluster |
| `gitlab-token`        | `Secret`             | Token for `gitlab` ServiceAccount                                                                          | Creating a new cluster |
| `tiller`              | `ServiceAccount`     | `gitlab-managed-apps` namespace                                                                            | Installing Helm charts |
| `tiller-admin`        | `ClusterRoleBinding` | `cluster-admin` roleRef                                                                                    | Installing Helm charts |
| Environment namespace | `Namespace`          | Contains all environment-specific resources                                                                | Deploying to a cluster |
| Environment namespace | `ServiceAccount`     | Uses namespace of environment                                                                              | Deploying to a cluster |
| Environment namespace | `Secret`             | Token for environment ServiceAccount                                                                       | Deploying to a cluster |
| Environment namespace | `RoleBinding`        | [`admin`](https://kubernetes.io/docs/reference/access-authn-authz/rbac/#user-facing-roles) roleRef         | Deploying to a cluster |

The environment namespace `RoleBinding` was
[updated](https://gitlab.com/gitlab-org/gitlab/-/issues/31113) in GitLab 13.6
to `admin` roleRef. Previously, the `edit` roleRef was used.

### ABAC cluster resources

GitLab creates the following resources for ABAC clusters.

| Name                  | Type                 | Details                              | Created when               |
|:----------------------|:---------------------|:-------------------------------------|:---------------------------|
| `gitlab`              | `ServiceAccount`     | `default` namespace                         | Creating a new cluster |
| `gitlab-token`        | `Secret`             | Token for `gitlab` ServiceAccount           | Creating a new cluster |
| `tiller`              | `ServiceAccount`     | `gitlab-managed-apps` namespace             | Installing Helm charts |
| `tiller-admin`        | `ClusterRoleBinding` | `cluster-admin` roleRef                     | Installing Helm charts |
| Environment namespace | `Namespace`          | Contains all environment-specific resources | Deploying to a cluster |
| Environment namespace | `ServiceAccount`     | Uses namespace of environment               | Deploying to a cluster |
| Environment namespace | `Secret`             | Token for environment ServiceAccount        | Deploying to a cluster |

### Security of runners

Runners have the [privileged mode](https://docs.gitlab.com/runner/executors/docker.html#the-privileged-mode)
enabled by default, which allows them to execute special commands and run
Docker in Docker. This functionality is needed to run some of the
[Auto DevOps](../../../topics/autodevops/index.md)
jobs. This implies the containers are running in privileged mode and you should,
therefore, be aware of some important details.

The privileged flag gives all capabilities to the running container, which in
turn can do almost everything that the host can do. Be aware of the
inherent security risk associated with performing `docker run` operations on
arbitrary images as they effectively have root access.

If you don't want to use a runner in privileged mode, either:

- Use shared runners on GitLab.com. They don't have this security issue.
- Set up your own runners using the configuration described at
  [shared runners](../../gitlab_com/index.md#shared-runners). This involves:
  1. Making sure that you don't have it installed via
     [the applications](index.md#installing-applications).
  1. Installing a runner
     [using `docker+machine`](https://docs.gitlab.com/runner/executors/docker_machine.html).

## Create new cluster

New clusters can be created using GitLab on Google Kubernetes Engine (GKE) or
Amazon Elastic Kubernetes Service (EKS) at the project, group, or instance level:

1. Navigate to your:
   - Project's **{cloud-gear}** **Operations > Kubernetes** page, for a project-level cluster.
   - Group's **{cloud-gear}** **Kubernetes** page, for a group-level cluster.
   - **Admin Area >** **{cloud-gear}** **Kubernetes** page, for an instance-level cluster.
1. Click **Integrate with a cluster certificate**.
1. Click the **Create new cluster** tab.
1. Click either **Amazon EKS** or **Google GKE**, and follow the instructions for your desired service:
   - [Amazon EKS](add_eks_clusters.md#new-eks-cluster).
   - [Google GKE](add_gke_clusters.md#creating-the-cluster-on-gke).

After creating a cluster, you can install runners for it as described in
[GitLab Managed Apps](../../clusters/applications.md).

## Add existing cluster

If you have an existing Kubernetes cluster, you can add it to a project, group,
or instance.

Kubernetes integration isn't supported for arm64 clusters. See the issue
[Helm Tiller fails to install on arm64 cluster](https://gitlab.com/gitlab-org/gitlab/-/issues/29838)
for details.

After adding an existing cluster, you can install runners for it as described in
[GitLab Managed Apps](../../clusters/applications.md).

### Existing Kubernetes cluster

To add a Kubernetes cluster to your project, group, or instance:

1. Navigate to your:
   1. Project's **{cloud-gear}** **Operations > Kubernetes** page, for a project-level cluster.
   1. Group's **{cloud-gear}** **Kubernetes** page, for a group-level cluster.
   1. **Admin Area >** **{cloud-gear}** **Kubernetes** page, for an instance-level cluster.
1. Click **Add Kubernetes cluster**.
1. Click the **Add existing cluster** tab and fill in the details:
   1. **Kubernetes cluster name** (required) - The name you wish to give the cluster.
   1. **Environment scope** (required) - The
      [associated environment](index.md#setting-the-environment-scope) to this cluster.
   1. **API URL** (required) -
      It's the URL that GitLab uses to access the Kubernetes API. Kubernetes
      exposes several APIs, we want the "base" URL that is common to all of them.
      For example, `https://kubernetes.example.com` rather than `https://kubernetes.example.com/api/v1`.

      Get the API URL by running this command:

      ```shell
      kubectl cluster-info | grep -E 'Kubernetes master|Kubernetes control plane' | awk '/http/ {print $NF}'
      ```

   1. **CA certificate** (required) - A valid Kubernetes certificate is needed to authenticate to the cluster. We use the certificate created by default.
      1. List the secrets with `kubectl get secrets`, and one should be named similar to
         `default-token-xxxxx`. Copy that token name for use below.
      1. Get the certificate by running this command:

         ```shell
         kubectl get secret <secret name> -o jsonpath="{['data']['ca\.crt']}" | base64 --decode
         ```

         If the command returns the entire certificate chain, you must copy the Root CA
         certificate and any intermediate certificates at the bottom of the chain.
         A chain file has following structure:

         ```plaintext
            -----BEGIN MY CERTIFICATE-----
            -----END MY CERTIFICATE-----
            -----BEGIN INTERMEDIATE CERTIFICATE-----
            -----END INTERMEDIATE CERTIFICATE-----
            -----BEGIN INTERMEDIATE CERTIFICATE-----
            -----END INTERMEDIATE CERTIFICATE-----
            -----BEGIN ROOT CERTIFICATE-----
            -----END ROOT CERTIFICATE-----
         ```

   1. **Token** -
      GitLab authenticates against Kubernetes using service tokens, which are
      scoped to a particular `namespace`.
      **The token used should belong to a service account with
      [`cluster-admin`](https://kubernetes.io/docs/reference/access-authn-authz/rbac/#user-facing-roles)
      privileges.** To create this service account:
      1. Create a file called `gitlab-admin-service-account.yaml` with contents:

         ```yaml
         apiVersion: v1
         kind: ServiceAccount
         metadata:
           name: gitlab
           namespace: kube-system
         ---
         apiVersion: rbac.authorization.k8s.io/v1
         kind: ClusterRoleBinding
         metadata:
           name: gitlab-admin
         roleRef:
           apiGroup: rbac.authorization.k8s.io
           kind: ClusterRole
           name: cluster-admin
         subjects:
           - kind: ServiceAccount
             name: gitlab
             namespace: kube-system
         ```

      1. Apply the service account and cluster role binding to your cluster:

         ```shell
         kubectl apply -f gitlab-admin-service-account.yaml
         ```

         You need the `container.clusterRoleBindings.create` permission
         to create cluster-level roles. If you do not have this permission,
         you can alternatively enable Basic Authentication and then run the
         `kubectl apply` command as an administrator:

         ```shell
         kubectl apply -f gitlab-admin-service-account.yaml --username=admin --password=<password>
         ```

         NOTE:
         Basic Authentication can be turned on and the password credentials
         can be obtained using the Google Cloud Console.

         Output:

         ```shell
         serviceaccount "gitlab" created
         clusterrolebinding "gitlab-admin" created
         ```

      1. Retrieve the token for the `gitlab` service account:

         ```shell
         kubectl -n kube-system describe secret $(kubectl -n kube-system get secret | grep gitlab | awk '{print $1}')
         ```

         Copy the `<authentication_token>` value from the output:

         ```plaintext
         Name:         gitlab-token-b5zv4
         Namespace:    kube-system
         Labels:       <none>
         Annotations:  kubernetes.io/service-account.name=gitlab
                      kubernetes.io/service-account.uid=bcfe66ac-39be-11e8-97e8-026dce96b6e8

         Type:  kubernetes.io/service-account-token

         Data
         ====
         ca.crt:     1025 bytes
         namespace:  11 bytes
         token:      <authentication_token>
         ```

      NOTE:
      For GKE clusters, you need the
      `container.clusterRoleBindings.create` permission to create a cluster
      role binding. You can follow the [Google Cloud
      documentation](https://cloud.google.com/iam/docs/granting-changing-revoking-access)
      to grant access.

   1. **GitLab-managed cluster** - Leave this checked if you want GitLab to manage namespaces and service accounts for this cluster.
      See the [Managed clusters section](index.md#gitlab-managed-clusters) for more information.
   1. **Project namespace** (optional) - You don't have to fill it in; by leaving
      it blank, GitLab creates one for you. Also:
      - Each project should have a unique namespace.
      - The project namespace is not necessarily the namespace of the secret, if
        you're using a secret with broader permissions, like the secret from `default`.
      - You should **not** use `default` as the project namespace.
      - If you or someone created a secret specifically for the project, usually
        with limited permissions, the secret's namespace and project namespace may
        be the same.

1. Finally, click the **Create Kubernetes cluster** button.

After a couple of minutes, your cluster is ready. You can now proceed
to install some [pre-defined applications](index.md#installing-applications).

#### Disable Role-Based Access Control (RBAC) (optional)

When connecting a cluster via GitLab integration, you may specify whether the
cluster is RBAC-enabled or not. This affects how GitLab interacts with the
cluster for certain operations. If you did *not* check the **RBAC-enabled cluster**
checkbox at creation time, GitLab assumes RBAC is disabled for your cluster
when interacting with it. If so, you must disable RBAC on your cluster for the
integration to work properly.

![RBAC](img/rbac_v13_1.png)

WARNING:
Disabling RBAC means that any application running in the cluster,
or user who can authenticate to the cluster, has full API access. This is a
[security concern](index.md#security-implications), and may not be desirable.

To effectively disable RBAC, global permissions can be applied granting full access:

```shell
kubectl create clusterrolebinding permissive-binding \
  --clusterrole=cluster-admin \
  --user=admin \
  --user=kubelet \
  --group=system:serviceaccounts
```

## Configuring your Kubernetes cluster

After [adding a Kubernetes cluster](add_remove_clusters.md) to GitLab, read this section that covers
important considerations for configuring Kubernetes clusters with GitLab.

### Security implications

WARNING:
The whole cluster security is based on a model where [developers](../../permissions.md)
are trusted, so **only trusted users should be allowed to control your clusters**.

The default cluster configuration grants access to a wide set of
functionalities needed to successfully build and deploy a containerized
application. Bear in mind that the same credentials are used for all the
applications running on the cluster.

### GitLab-managed clusters

> - [Introduced](https://gitlab.com/gitlab-org/gitlab-foss/-/merge_requests/22011) in GitLab 11.5.
> - Became [optional](https://gitlab.com/gitlab-org/gitlab-foss/-/merge_requests/26565) in GitLab 11.11.

You can choose to allow GitLab to manage your cluster for you. If your cluster
is managed by GitLab, resources for your projects are automatically created. See
the [Access controls](add_remove_clusters.md#access-controls) section for
details about the created resources.

If you choose to manage your own cluster, project-specific resources aren't created
automatically. If you are using [Auto DevOps](../../../topics/autodevops/index.md), you must
explicitly provide the `KUBE_NAMESPACE` [deployment variable](#deployment-variables)
for your deployment jobs to use. Otherwise, a namespace is created for you.

#### Important notes

Note the following with GitLab and clusters:

- If you [install applications](#installing-applications) on your cluster, GitLab will
  create the resources required to run these even if you have chosen to manage your own
  cluster.
- Be aware that manually managing resources that have been created by GitLab, like
  namespaces and service accounts, can cause unexpected errors. If this occurs, try
  [clearing the cluster cache](#clearing-the-cluster-cache).

#### Clearing the cluster cache

> [Introduced](https://gitlab.com/gitlab-org/gitlab/-/issues/31759) in GitLab 12.6.

If you allow GitLab to manage your cluster, GitLab stores a cached
version of the namespaces and service accounts it creates for your projects. If you
modify these resources in your cluster manually, this cache can fall out of sync with
your cluster. This can cause deployment jobs to fail.

To clear the cache:

1. Navigate to your project's **Operations > Kubernetes** page, and select your cluster.
1. Expand the **Advanced settings** section.
1. Click **Clear cluster cache**.

### Base domain

> [Introduced](https://gitlab.com/gitlab-org/gitlab-foss/-/merge_requests/24580) in GitLab 11.8.

You do not need to specify a base domain on cluster settings when using GitLab Serverless. The domain in that case
is specified as part of the Knative installation. See [Installing Applications](#installing-applications).

Specifying a base domain automatically sets `KUBE_INGRESS_BASE_DOMAIN` as an deployment variable.
If you are using [Auto DevOps](../../../topics/autodevops/index.md), this domain is used for the different
stages. For example, Auto Review Apps and Auto Deploy.

The domain should have a wildcard DNS configured to the Ingress IP address.
After Ingress has been installed (see [Installing Applications](#installing-applications)),
you can either:

- Create an `A` record that points to the Ingress IP address with your domain provider.
- Enter a wildcard DNS address using a service such as nip.io or xip.io. For example, `192.168.1.1.xip.io`.

To determine the external Ingress IP address, or external Ingress hostname:

- *If the cluster is on GKE*:
  1. Click the **Google Kubernetes Engine** link in the **Advanced settings**,
     or go directly to the [Google Kubernetes Engine dashboard](https://console.cloud.google.com/kubernetes/).
  1. Select the proper project and cluster.
  1. Click **Connect**
  1. Execute the `gcloud` command in a local terminal or using the **Cloud Shell**.

- *If the cluster is not on GKE*: Follow the specific instructions for your
  Kubernetes provider to configure `kubectl` with the right credentials.
  The output of the following examples show the external endpoint of your
  cluster. This information can then be used to set up DNS entries and forwarding
  rules that allow external access to your deployed applications.

Depending an your Ingress, the external IP address can be retrieved in various ways.
This list provides a generic solution, and some GitLab-specific approaches:

- In general, you can list the IP addresses of all load balancers by running:

  ```shell
  kubectl get svc --all-namespaces -o jsonpath='{range.items[?(@.status.loadBalancer.ingress)]}{.status.loadBalancer.ingress[*].ip} '
  ```

- If you installed Ingress using the **Applications**, run:

  ```shell
  kubectl get service --namespace=gitlab-managed-apps ingress-nginx-ingress-controller -o jsonpath='{.status.loadBalancer.ingress[0].ip}'
  ```

- Some Kubernetes clusters return a hostname instead, like
  [Amazon EKS](https://aws.amazon.com/eks/). For these platforms, run:

  ```shell
  kubectl get service --namespace=gitlab-managed-apps ingress-nginx-ingress-controller -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'
  ```

  If you use EKS, an [Elastic Load Balancer](https://docs.aws.amazon.com/elasticloadbalancing/)
  is also created, which incurs additional AWS costs.

- Istio/Knative uses a different command. Run:

  ```shell
  kubectl get svc --namespace=istio-system istio-ingressgateway -o jsonpath='{.status.loadBalancer.ingress[0].ip} '
  ```

If you see a trailing `%` on some Kubernetes versions, do not include it.

### Multiple Kubernetes clusters

> - Introduced in [GitLab Premium](https://about.gitlab.com/pricing/) 10.3
> - [Moved](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/35094) to GitLab Free in 13.2.

You can associate more than one Kubernetes cluster to your
project. That way you can have different clusters for different environments,
like development, staging, production, and so on.
Add another cluster, like you did the first time, and make sure to
[set an environment scope](#setting-the-environment-scope) that
differentiates the new cluster from the rest.

#### Setting the environment scope

When adding more than one Kubernetes cluster to your project, you need to differentiate
them with an environment scope. The environment scope associates clusters with [environments](../../../ci/environments/index.md) similar to how the
[environment-specific CI/CD variables](../../../ci/variables/README.md#limit-the-environment-scope-of-a-cicd-variable) work.

The default environment scope is `*`, which means all jobs, regardless of their
environment, use that cluster. Each scope can be used only by a single cluster
in a project, and a validation error occurs if otherwise. Also, jobs that don't
have an environment keyword set can't access any cluster.

For example, let's say the following Kubernetes clusters exist in a project:

| Cluster     | Environment scope |
| ----------- | ----------------- |
| Development | `*`               |
| Production  | `production`      |

And the following environments are set in
[`.gitlab-ci.yml`](../../../ci/yaml/README.md):

```yaml
stages:
  - test
  - deploy

test:
  stage: test
  script: sh test

deploy to staging:
  stage: deploy
  script: make deploy
  environment:
    name: staging
    url: https://staging.example.com/

deploy to production:
  stage: deploy
  script: make deploy
  environment:
    name: production
    url: https://example.com/
```

The results:

- The Development cluster details are available in the `deploy to staging`
  job.
- The production cluster details are available in the `deploy to production`
  job.
- No cluster details are available in the `test` job because it doesn't
  define any environment.

## Enabling or disabling integration

The Kubernetes cluster integration enables after you have successfully either created
a new cluster or added an existing one. To disable Kubernetes cluster integration:

1. Navigate to your:
   - Project's **{cloud-gear}** **Operations > Kubernetes** page, for a project-level cluster.
   - Group's **{cloud-gear}** **Kubernetes** page, for a group-level cluster.
   - **Admin Area >** **{cloud-gear}** **Kubernetes** page, for an instance-level cluster.
1. Click on the name of the cluster.
1. Click the **GitLab Integration** toggle.
1. Click **Save changes**.

## Removing integration

To remove the Kubernetes cluster integration from your project, first navigate to the **Advanced Settings** tab of the cluster details page and either:

- Select **Remove integration**, to remove only the Kubernetes integration.
- [From GitLab 12.6](https://gitlab.com/gitlab-org/gitlab/-/issues/26815), select
  **Remove integration and resources**, to also remove all related GitLab cluster resources (for
  example, namespaces, roles, and bindings) when removing the integration.

When removing the cluster integration, note:

- You need Maintainer [permissions](../../permissions.md) and above to remove a Kubernetes cluster
  integration.
- When you remove a cluster, you only remove its relationship to GitLab, not the cluster itself. To
  remove the cluster, you can do so by visiting the GKE or EKS dashboard, or using `kubectl`.

## Learn more

To learn more on automatically deploying your applications,
read about [Auto DevOps](../../../topics/autodevops/index.md).

## Troubleshooting

### There was a problem authenticating with your cluster. Please ensure your CA Certificate and Token are valid

If you encounter this error while adding a Kubernetes cluster, ensure you're
properly pasting the service token. Some shells may add a line break to the
service token, making it invalid. Ensure that there are no line breaks by
pasting your token into an editor and removing any additional spaces.

You may also experience this error if your certificate is not valid. To check that your certificate's
subject alternative names contain the correct domain for your cluster's API, run this:

```shell
echo | openssl s_client -showcerts -connect kubernetes.example.com:443 2>/dev/null |
openssl x509 -inform pem -noout -text
```

Note that the `-connect` argument expects a `host:port` combination. For example, `https://kubernetes.example.com` would be `kubernetes.example.com:443`.

### This job failed because the necessary resources were not successfully created.

Before the deployment jobs starts, GitLab creates the following specifically for
the deployment job:

- A namespace.
- A service account.

However, sometimes GitLab can not create them. In such instances, your job can fail with the message:

```plaintext
This job failed because the necessary resources were not successfully created.
```

To find the cause of this error when creating a namespace and service account, check the [logs](../../../administration/logs.md#kuberneteslog).

Reasons for failure include:

- The token you gave GitLab does not have [`cluster-admin`](https://kubernetes.io/docs/reference/access-authn-authz/rbac/#user-facing-roles)
  privileges required by GitLab.
- Missing `KUBECONFIG` or `KUBE_TOKEN` deployment variables. To be passed to your job, they must have a matching
  [`environment:name`](../../../ci/environments/index.md). If your job has no
  `environment:name` set, the Kubernetes credentials are not passed to it.

NOTE:
Project-level clusters upgraded from GitLab 12.0 or older may be configured
in a way that causes this error. Ensure you deselect the
[GitLab-managed cluster](#gitlab-managed-clusters) option if you want to manage
namespaces and service accounts yourself.