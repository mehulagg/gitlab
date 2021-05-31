---
stage: Configure
group: Configure
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#assignments
---

# Adding and removing Kubernetes clusters **(FREE)**

NOTE:
Promotion: Every new Google Cloud Platform (GCP) account receives
[$300 in credit upon sign up](https://console.cloud.google.com/freetrial).
In partnership with Google, GitLab is able to offer an additional $200 for new GCP
accounts to get started with the GitLab integration with Google Kubernetes Engine.
[Follow this link](https://cloud.google.com/partners/partnercredit/?pcn_code=0014M00001h35gDQAQ#contact-form)
to apply for credit.

NOTE:
Watch the webcast [Scalable app deployment with GitLab and Google Cloud Platform](https://about.gitlab.com/webcast/scalable-app-deploy/)
and learn how to spin up a Kubernetes cluster managed by Google Cloud Platform (GCP)
in a few clicks.

## Create a new cluster

You can create your Kubernetes cluster with GitLab either:

- Through the [GitLab Kubernetes Agent]() (recommended).
- Through a certificate-based process, hosted on-premises or in:
  - [Google Kubernetes Engine (GKE)]().
  - [Amazon Elastic Kubernetes Service (EKS)]().

To integrate your cluster with GitLab, you need:

- Either a GitLab.com account or a self-managed installation running GitLab 12.5
or later.
- Maintainer permissions for group-level and project-level clusters.
- Access to the Admin area for instance-level clusters. **(FREE SELF)**

## Add an existing cluster

See how to [add an existing cluster](add_existing_cluster.md) to GitLab.

## Cluster integrations

<!-- [link to cluster integrations] -->

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
