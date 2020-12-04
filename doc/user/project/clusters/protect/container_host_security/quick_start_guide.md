---
stage: Protect
group: Container Security
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#designated-technical-writers
---

# Getting started with GitLab's Container Host Security

The following installation steps are the recommended way of installing GitLab's Protect capabilities.  Although some capabilities can be installed through GMAv1, it is [recommended and preferred]() to install applications through GMAv2 exclusively when using Container Network Security.

## Installation steps

The following steps are recommended to install and use Container Host Security through GitLab:

1. [Install and connect at least one runner to GitLab](https://docs.gitlab.com/runner/)
1. [Create a group](https://docs.gitlab.com/ee/user/group/#create-a-new-group)
1. [Connect a Kubernetes cluster to the group](https://docs.gitlab.com/ee/user/project/clusters/add_remove_clusters.html)
1. [Create a cluster management project and associate it with the Kubernetes cluster](https://docs.gitlab.com/ee/user/clusters/management_project.html)
1. Install and configure an Ingress node
  1. [Install the Ingress node via CI/CD (GMAv2)](https://docs.gitlab.com/ee/user/clusters/applications.html#install-ingress-using-gitlab-cicd)
  1. [Determine the external endpoint via the manual method](https://docs.gitlab.com/ee/user/clusters/applications.html#determining-the-external-endpoint-manually)
  1. Navigate to the Kubernetes page and enter the [DNS address for the external endpoint](https://docs.gitlab.com/ee/user/project/clusters/#base-domain) into the **Base domain** field on the Details tab.  Save the changes to the Kubernetes cluster.
1. [Install and configure Falco](https://docs.gitlab.com/ee/user/clusters/applications.html#install-falco-using-gitlab-cicd) for activity monitoring
1. [Install and configure AppArmor](https://docs.gitlab.com/ee/user/clusters/applications.html#install-apparmor-using-gitlab-cicd) for activity blocking
1. [Configure Pod Security Policies](https://docs.gitlab.com/ee/user/clusters/applications.html#using-podsecuritypolicy-in-your-deployments) (required to be able to load AppArmor profiles)

It is possible to install and manage Falco and AppArmor in other ways, such as by installing Falco and AppArmor manually into a Kubernetes cluster and then connecting it back to GitLab. These methods are not currently documented or officially supported.

## Viewing the logs

Falco logs can be viewed by running the following command in your Kubernetes cluster:

```
kubectl -n gitlab-managed-apps logs -l app=falco
```

## Troubleshooting

### Trouble connecting to the cluster

Occasionally your CI/CD pipeline may fail or have trouble connecting to the cluster.  Below are some initial troubleshooting steps that resolve the most common problems:

1. [Clear the cluster cache](https://docs.gitlab.com/ee/user/project/clusters/#clearing-the-cluster-cache)
1. If things still aren't working, a more assertive set of actions may help get things back into a good state:
  1. Stop and [delete the problematic environment](https://docs.gitlab.com/ee/ci/environments/#delete-environments-through-the-ui) in GitLab
  1. Delete the relevant namespace in Kubernetes by running `kubectl delete namespaces <insert-some-namespace-name>` in your Kubernetes cluster
  1. Re-run the application project pipeline to re-deploy the application

### Using GMAv1 with GMAv2

When users use GMAv1 and GMAv2 together on the same cluster, they may experience problems with applications being uninstalled or removed from the cluster.  This is due to the fact that GMAv2 actively uninstalls applications that are installed via GMAv1 and not configured to be installed via GMAv2. It is possible to use a mixture of applications installed via GMAv1 and GMAv2 by ensuring that the GMAv1 applications are installed **after** the GMAv2 cluster management project pipeline runs.  GMAv1 applications will need to be re-installed after each run of that pipeline.  This approach is not recommended as it is error prone and can lead to downtime as applications are uninstalled and later re-installed.  The preferred and recommended path is to install all necessary components via GMAv2 and the cluster management project when using Container Network Security.

NOTE: **Note:**
These diagrams use the term _Kubernetes_ for simplicity. In practice, Sidekiq connects to a Helm
Tiller daemon running in a pod in the cluster.

#### GitLab Managed Apps v1 (GMAv1)

GitLab Managed Apps v1 (GMAv1) allows you to install capabilities into your Kubernetes cluster from the GitLab web interface with a one-click setup process. GitLab
uses Sidekiq (a background processing service) to facilitate this.

```mermaid
  sequenceDiagram
    autonumber
    GitLab->>+Sidekiq: Install a GitLab Managed App
    Sidekiq->>+Kubernetes: Helm install
    Kubernetes-->>-Sidekiq: Installation complete
    Sidekiq-->>-GitLab: Refresh UI
```

Although this installation method is easier because it's a point-and-click action in the user
interface, it's inflexible and harder to debug. If something goes wrong, you can't see the
deployment logs, and your deployment may be removed or overwritten if you deploy any applications through GMAv2.

#### GitLab Managed Apps v2 (GMAv2)

However, the next generation of GitLab Managed Apps V2 ([CI/CD-based GitLab Managed Apps](https://gitlab.com/groups/gitlab-org/-/epics/2103))
don't use Sidekiq to deploy. All the applications are deployed using a GitLab CI/CD pipeline and
therefore, by runners.

```mermaid
sequenceDiagram
  autonumber
  GitLab->>+GitLab: Trigger pipeline
  GitLab->>+Runner: Run deployment job
  Runner->>+Kubernetes: Helm install
  Kubernetes-->>-Runner: Installation is complete
  Runner-->>-GitLab: Report job status and update pipeline
```

Debugging is easier because you have access to the raw logs of these jobs (the Helm Tiller output is
available as an artifact in case of failure), and the flexibility is much better. Since these
deployments are only triggered when a pipeline is running (most likely when there's a new commit in
the cluster management repository), every action has a paper trail and follows the classic merge
request workflow (approvals, merge, deploy). The Network Policy (Cilium) Managed App, and Container
Host Security (Falco) are deployed with this model.
