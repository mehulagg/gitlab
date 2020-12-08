---
stage: Protect
group: Container Security
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#designated-technical-writers
---

# Getting started with GitLab's Container Host Security

The following installation steps are the recommended way of installing GitLab's Protect capabilities.  Although some capabilities can be installed through GMAv1, it is [recommended and preferred](#using-gmav1-with-gmav2) to install applications through GMAv2 exclusively when using Container Network Security.

## Installation steps

The following steps are recommended to install and use Container Host Security through GitLab:

1. [Install at least one runner and connect it to GitLab](https://docs.gitlab.com/runner/).
1. [Create a group](../../../../group/#create-a-new-group).
1. [Connect a Kubernetes cluster to the group](../../add_remove_clusters.md).
1. [Create a cluster management project and associate it with the Kubernetes cluster](../../../../clusters/management_project.md).

1. Install and configure an Ingress node:

   - [Install the Ingress node via CI/CD (GMAv2)](../../../../clusters/applications.md#install-ingress-using-gitlab-cicd).
   - [Determine the external endpoint via the manual method](../../../../clusters/applications.md#determining-the-external-endpoint-manually).
   - Navigate to the Kubernetes page and enter the [DNS address for the external endpoint](../../index.md#base-domain)
     into the **Base domain** field on the **Details** tab. Save the changes to the Kubernetes
     cluster.

1. [Install and configure Falco](../../../../clusters/applications.md#install-falco-using-gitlab-cicd)
   for activity monitoring.
1. [Install and configure AppArmor](../../../../clusters/applications.md#install-apparmor-using-gitlab-cicd)
   for activity blocking.
1. [Configure Pod Security Policies](../../../../clusters/applications.md#using-podsecuritypolicy-in-your-deployments)
   (required to be able to load AppArmor profiles).

It is possible to install and manage Falco and AppArmor in other ways, such as by installing Falco and AppArmor manually into a Kubernetes cluster and then connecting it back to GitLab. These methods are not currently documented or officially supported.

## Viewing the logs

Falco logs can be viewed by running the following command in your Kubernetes cluster:

```
kubectl -n gitlab-managed-apps logs -l app=falco
```

## Troubleshooting

### Trouble connecting to the cluster

Occasionally your CI/CD pipeline may fail or have trouble connecting to the cluster.  Below are some initial troubleshooting steps that resolve the most common problems:

1. [Clear the cluster cache](../../index.md#clearing-the-cluster-cache)
1. If things still aren't working, a more assertive set of actions may help get things back to a
   good state:

   - Stop and [delete the problematic environment](../../../../../ci/environments/#delete-environments-through-the-ui)
     in GitLab.
   - Delete the relevant namespace in Kubernetes by running
     `kubectl delete namespaces <insert-some-namespace-name>` in your Kubernetes cluster.
   - Re-run the application project pipeline to re-deploy the application.

### Using GMAv1 with GMAv2

When users use GMAv1 and GMAv2 together on the same cluster, they may experience problems with applications being uninstalled or removed from the cluster.  This is due to the fact that GMAv2 actively uninstalls applications that are installed via GMAv1 and not configured to be installed via GMAv2. It is possible to use a mixture of applications installed via GMAv1 and GMAv2 by ensuring that the GMAv1 applications are installed **after** the GMAv2 cluster management project pipeline runs.  GMAv1 applications will need to be re-installed after each run of that pipeline.  This approach is not recommended as it is error prone and can lead to downtime as applications are uninstalled and later re-installed.  The preferred and recommended path is to install all necessary components via GMAv2 and the cluster management project when using Container Network Security.

**Related documentation links:**

- [GitLab Managed Apps v1 (GMAv1)](../../../../clusters/applications.md#install-with-one-click)
- [GitLab Managed Apps v2 (GMAv2)](../../../../clusters/management_project.md)