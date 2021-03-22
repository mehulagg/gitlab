---
stage: Configure
group: Configure
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#assignments
---

# Kubernetes Agent Server (KAS)

The Kubernetes Agent Server (KAS) is a GitLab backend service dedicated to
managing [Kubernetes Agents](../../user/clusters/agent/index.md).

## Install the Kubernetes Agent Server **(FREE SELF)**

The GitLab Kubernetes Agent Server (KAS) can be installed through Omnibus GitLab or
through the GitLab Helm Chart. If you don't already have
GitLab installed, please refer to our [installation
documentation](https://docs.gitlab.com/ee/install/README.html).
You can install the KAS within GitLab as explained below according to your GitLab installation method.
You can also opt to use an [external KAS](#use-an-external-kas-installation).

### Install KAS with Omnibus

For [Omnibus](https://docs.gitlab.com/omnibus/) package installations:

1. Edit `/etc/gitlab/gitlab.rb` to enable the Kubernetes Agent Server:

   ```plaintext
   gitlab_kas['enable'] = true
   ```

1. [Reconfigure GitLab](../restart_gitlab.md#omnibus-gitlab-reconfigure).

To configure any additional options related to GitLab Kubernetes Agent Server,
refer to the **Enable GitLab KAS** section of the
[`gitlab.rb.template`](https://gitlab.com/gitlab-org/omnibus-gitlab/-/blob/master/files/gitlab-config-template/gitlab.rb.template).

### Install KAS with GitLab Helm Chart

For GitLab [Helm Chart](https://gitlab.com/gitlab-org/charts/gitlab)
installations, you must set `global.kas.enabled=true` for the KAS to be
installed with GitLab. For example, in a shell with `helm` and `kubectl`
installed, run:

```shell
helm repo add gitlab https://charts.gitlab.io/
helm repo update
helm upgrade --install gitlab gitlab/gitlab \
  --timeout 600s \
  --set global.hosts.domain=<YOUR_DOMAIN> \
  --set global.hosts.externalIP=<YOUR_IP> \
  --set certmanager-issuer.email=<YOUR_EMAIL> \
  --set global.kas.enabled=true # <-- without this, KAS will not be installed
```

For details, read [Installing GitLab using Helm](https://docs.gitlab.com/charts/installation/).

To configure KAS, use a `gitlab.kas` sub-section in your `values.yaml` file:

```yaml
gitlab:
  kas:
    # put your KAS custom options here
```

For details, read [Using the GitLab-KAS chart](https://docs.gitlab.com/charts/charts/gitlab/kas/).

### Use an external KAS installation

> [Introduced](https://gitlab.com/gitlab-org/gitlab/-/issues/299850) in GitLab 13.10.

Besides installing KAS with GitLab, you can opt to configure GitLab to use an external KAS.

For GitLab instances installed through the GitLab Helm Chart, see [how to configure your external KAS](https://docs.gitlab.com/charts/charts/globals.html#external-kas).

For GitLab instances installed through Omnibus packages:

1. Edit `/etc/gitlab/gitlab.rb` adding the paths to your external KAS:

   ```ruby
   gitlab_kas['enable'] = false
   gitlab_kas['api_secret_key'] = 'Your shared secret between GitLab and KAS'

   gitlab_rails['gitlab_kas_enabled'] = true
   gitlab_rails['gitlab_kas_external_url'] = 'wss://kas.gitlab.example.com' # User-facing URL for the in-cluster agentk
   gitlab_rails['gitlab_kas_internal_url'] = 'grpc://kas.internal.gitlab.example.com' # Internal URL for the GitLab backend
   ```

1. [Reconfigure GitLab](../restart_gitlab.md#omnibus-gitlab-reconfigure).
