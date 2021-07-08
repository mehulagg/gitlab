---
stage: Configure
group: Configure
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#assignments
---

# Auto DevOps **(FREE)**

> - [Introduced](https://gitlab.com/gitlab-org/gitlab-foss/-/issues/38366) in GitLab 11.0.

GitLab Auto DevOps helps to reduce the complexity of the software delivery process. It automatically:

- Detects the language of your code.
- Builds and tests you application.
- Measures code quality.
- Scans for vulnerabilities and security flaws.
- Checks for licensing issues.
- Monitors in real time.
- Deploys your application.

**Some of the benefits of using Auto DevOps are:**

- Consistency.
- Simplicity.
- Productivity.
- Efficiency.

<i class="fa fa-youtube-play youtube" aria-hidden="true"></i>
For an introduction to Auto DevOps, watch [Auto DevOps in GitLab 11.0](https://youtu.be/0Tc0YYBxqi4).

## Auto DevOps features

Based on the DevOps [stages](stages.md), you can use Auto DevOps:

**To build your app:**

- [Auto Build](stages.md#auto-build)
- [Auto Dependency Scanning](stages.md#auto-dependency-scanning)

**To test your app:**

- [Auto Test](stages.md#auto-test)
- [Auto Browser Performance Testing](stages.md#auto-browser-performance-testing)
- [Auto Code Intelligence](stages.md#auto-code-intelligence)
- [Auto Code Quality](stages.md#auto-code-quality)
- [Auto Container Scanning](stages.md#auto-container-scanning)
- [Auto License Compliance](stages.md#auto-license-compliance)

**To deploy your app:**

- [Auto Review Apps](stages.md#auto-review-apps)
- [Auto Deploy](stages.md#auto-deploy)

**To monitor your app:**

- [Auto Monitoring](stages.md#auto-monitoring)

**To secure your app:**

- [Auto DAST (Dynamic Application Security Testing)](stages.md#auto-dast)
- [Auto SAST (Static Application Security Testing)](stages.md#auto-sast)
- [Auto Secret Detection](stages.md#auto-secret-detection)

Auto DevOps uses [CI templates](https://gitlab.com/gitlab-org/gitlab/-/tree/master/lib/gitlab/ci/templates)
for its tasks. You can [customize](customize.md) them later.

You can also [manage Auto DevOps with APIs](customize.md#extend-auto-devops-with-the-api).

### Comparison to application platforms and PaaS

Auto DevOps provides features often included in an application
platform or in a Platform as a Service (PaaS).

Inspired by [Heroku](https://www.heroku.com/), Auto DevOps goes beyond it
in multiple ways:

- It works with any Kubernetes cluster.
- There is no additional cost.
- You can use a cluster hosted by yourself or on any public cloud.
- It offers an incremental graduation path. If you need to [customize](customize.md), start by changing the templates and evolve from there.

## Get started with Auto DevOps

To get started with Auto DevOps:

1. See the [prerequisites](#auto-devops-prerequisites) listed below.
1. (Optional) [Prepare for deployment](prepare_deployment.md).
1. [Enable Auto DevOps](#enable-or-disable-auto-devops).
1. Follow the [quick start guide](#quick-start).

### Prerequisites

As Auto DevOps relies on many components, you should be familiar with:

- [Kubernetes](https://kubernetes.io/docs/home/)
- [Helm](https://helm.sh/docs/)
- [Docker](https://docs.docker.com)
- [GitLab Runner](https://docs.gitlab.com/runner/)
- [Prometheus](https://prometheus.io/docs/introduction/overview/)
- [Continuous methodologies](../../ci/introduction/index.md)

See also the technical [requirements for Auto DevOps](requirements.md).

### Enable or disable Auto DevOps

> - [Introduced](https://gitlab.com/gitlab-org/gitlab-foss/-/issues/41729) in GitLab 11.3, Auto DevOps is enabled by default.
> - [Introduced](https://gitlab.com/gitlab-org/gitlab/-/issues/26655) GitLab 12.7, Auto DevOps runs pipelines automatically only if a [`Dockerfile` or matching buildpack](stages.md#auto-build) exists.

Depending on your instance type, you can enable or disable Auto DevOps at the
following levels:

| Instance type       | [Project](#at-the-project-level) | [Group](#at-the-group-level) | [Instance](#at-the-instance-level) (Admin Area)  |
|---------------------|------------------------|------------------------|------------------------|
| GitLab SaaS         | **{check-circle}** Yes | **{dotted-circle}** No | **{dotted-circle}** No |
| GitLab self-managed | **{check-circle}** Yes | **{check-circle}** Yes | **{check-circle}** Yes |

Before enabling Auto DevOps, consider setting up a
[base domain](prepare_deployment.md#auto-devops-base-domain) to deploy your application(s). If you
don't, Auto DevOps can build and test your app, but cannot deploy it.

#### At the project level

Only project Maintainers can enable or disable Auto DevOps at the project level.

Before enabling Auto DevOps, ensure that your project does not have a
`.gitlab-ci.yml` present. If it exists, remove it.

To enable it:

1. Go to your project's **Settings > CI/CD > Auto DevOps**.
1. Select the **Default to Auto DevOps pipeline**.
1. (Recommended) Add the [base domain](prepare_deployment.md#auto-devops-base-domain).
1. (Recommended) Choose the [deployment strategy](prepare_deployment.md#deployment-strategy).
1. Select **Save changes**.

GitLab triggers the Auto DevOps pipeline on the default branch.

To disable it, follow the same process and deselect **Default to Auto
DevOps pipeline**.

#### At the group level

> [Introduced](https://gitlab.com/gitlab-org/gitlab-foss/-/issues/52447) in GitLab 11.10.

Only GitLab administrators and group owners can enable or disable Auto DevOps
at the group level.

When you enable (or disable) Auto DevOps for a group, all subgroups and projects inherit the configuration.

Projects or subgroups already set aren't affected.

To enable it:

1. Go to your group's **Settings > CI/CD > Auto DevOps** page.
1. Select **Default to Auto DevOps pipeline**.
1. Select **Save changes**.

To disable it, follow the same process and deselect **Default to Auto DevOps pipeline**.

#### At the instance level **(FREE SELF)**

Only GitLab administrators can enable or disable Auto DevOps in the instance level.

Even when disabled for an instance, group owners and project maintainers
can still enable Auto DevOps at the group and project levels.

To enable it:

1. From the top bar, select **Menu >** **{admin}** **Admin**.
1. Go to **Settings > CI/CD > Continuous Integration and Deployment**.
1. Select **Default to Auto DevOps pipeline**.
1. (Optional) Add the Auto DevOps [base domain](prepare_deployment.md#auto-devops-base-domain).
1. Select **Save changes**.

When enabled, it attempts to run pipelines in each project. If the pipeline fails in a particular project, it disables itself.
GitLab administrators can opt to change this in the [Auto DevOps settings](../../user/admin_area/settings/continuous_integration.md#auto-devops).

If a [CI/CD configuration file](../../ci/yaml/index.md) is present in a given
project, Auto DevOps doesn't change or affect it.

To disable Auto DevOps, follow the same process and deselect the **Default to
Auto DevOps pipeline** checkbox.

### Quick start

#### For GitLab.com users

If you're using GitLab.com, see the [quick start guide](quick_start_guide.md).

It shows how to set up Auto DevOps and Auto Deploy your app
to a Kubernetes cluster hosted on Google Kubernetes Engine.

You can also deploy to [AWS ECS](requirements.md#auto-devops-requirements-for-amazon-ecs).

#### For GitLab self-managed instances **(FREE SELF)**

1. Configure the [Google OAuth 2.0 OmniAuth Provider](../../integration/google.md).
1. Configure a cluster on GKE.
1. Follow the [quick start guide](quick_start_guide.md).

## Limitations

### Private registry support

We cannot guarantee that you can use a private container registry with Auto DevOps.

We strongly advise you to use GitLab Container Registry with Auto DevOps to
simplify configuration and prevent any unforeseen issues.

### Install applications behind a proxy

The GitLab integration with Helm does not support installing applications when
behind a proxy.

To do so, inject proxy settings into the installation pods at runtime.
For example, you can use a [`PodPreset`](https://v1-19.docs.kubernetes.io/docs/concepts/workloads/pods/podpreset/):

```yaml
apiVersion: settings.k8s.io/v1alpha1
kind: PodPreset
metadata:
  name: gitlab-managed-apps-default-proxy
  namespace: gitlab-managed-apps
spec:
  env:
    - name: http_proxy
      value: "PUT_YOUR_HTTP_PROXY_HERE"
    - name: https_proxy
      value: "PUT_YOUR_HTTPS_PROXY_HERE"
```

<!-- DO NOT ADD TROUBLESHOOTING INFO HERE -->
<!-- Troubleshooting information has moved to troubleshooting.md -->
