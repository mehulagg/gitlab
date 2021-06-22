---
stage: Protect
group: Container Security
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#designated-technical-writers
---

# Install Cilium using the Cluster Management Project Template

[Cilium](https://cilium.io/) is a networking plugin for Kubernetes that you can use to implement
support for [NetworkPolicy](https://kubernetes.io/docs/concepts/services-networking/network-policies/)
resources. For more information, see [Network Policies](../../topics/autodevops/stages.md#network-policy).

<i class="fa fa-youtube-play youtube" aria-hidden="true"></i>
For an overview, see the
[Container Network Security Demo for GitLab 12.8](https://www.youtube.com/watch?v=pgUEdhdhoUI).

You can use the [Cluster Management Project Template](../management_project_template.md)
to install Cilium in your Kubernetes cluster.

1. In your cluster management project, go to `helmfile.yaml` and uncomment `- path: applications/cilium/helmfile.yaml`.
1. In `./applications/cilium/helmfile.yaml`, set `clusterType` to either `gke` or `eks` based on which Kubernetes provider your are using.

    ```yaml
    environments:
      default:
          values:
          # Set to "gke" or "eks" based on your cluster type
          - clusterType: ""
    ```

1. Merge or push these changes to the default branch of your cluster management project,
and [GitLab CI/CD](https://docs.gitlab.com/ee/ci/README.html) will automatically install Cilium.

You can customize Cilium's Helm variables by editing the `applications/cilium/values.yaml`
file in your cluster management project. Refer to the [Cilium helm reference](https://docs.cilium.io/en/stable/helm-reference/)
for the available configuration options.

WARNING:
Installation and removal of the Cilium requires a **manual**
[restart](https://docs.cilium.io/en/stable/gettingstarted/k8s-install-gke/#restart-unmanaged-pods)
of all affected pods in all namespaces to ensure that they are
[managed](https://docs.cilium.io/en/v1.10/operations/troubleshooting/#ensure-managed-pod)
by the correct networking plugin. Whenever Hubble is enabled, its related pod might require a
restart depending on whether it started prior to Cilium. For more information, see
[Failed Deployment](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/#failed-deployment)
in the Kubernetes docs.

NOTE:
Major upgrades might require additional setup steps. For more information, see
the official [upgrade guide](https://docs.cilium.io/en/v1.10/operations/upgrade/).

By default, Cilium's
[audit mode](https://docs.cilium.io/en/v1.10/gettingstarted/policy-creation/#enable-policy-audit-mode)
is enabled. In audit mode, Cilium doesn't drop disallowed packets. You
can use `policy-verdict` log to observe policy-related decisions. You
can disable audit mode by setting `policyAuditMode: false` in
`applications/cilium/values.yaml`.

The Cilium monitor log for traffic is logged out by the
`cilium-monitor` sidecar container. You can check these logs with the following command:

```shell
kubectl -n gitlab-managed-apps logs -l k8s-app=cilium -c cilium-monitor
```

You can disable the monitor log in `application/cilium/values.yaml`:

```yaml
monitor:
  enabled: false
```

The [Hubble](https://github.com/cilium/hubble) monitoring daemon is enabled by default
and it's set to collect per namespace flow metrics. This metrics are accessible on the
[Threat Monitoring](../application_security/threat_monitoring/index.md)
dashboard. You can disable Hubble by adding the following to
`applications/cilium/values.yaml`:

```yaml
hubble:
  enabled: false
```

You can also adjust Helm values for Hubble by using
`applications/cilium/values.yaml`:

```yaml
hubble:
  enabled: true
  metrics:
    enabled:
    - 'flow:sourceContext=namespace;destinationContext=namespace'
```

Support for installing the Cilium application is provided by the
GitLab Container Security group. If you run into unknown issues,
[open a new issue](https://gitlab.com/gitlab-org/gitlab/-/issues/new), and ping at
least 2 people from the
[Container Security group](https://about.gitlab.com/handbook/product/categories/#container-security-group).
