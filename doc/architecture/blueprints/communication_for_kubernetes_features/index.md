---
stage: configure
group: configure
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#designated-technical-writers
comments: false
description: 'Communication for Kubernetes-based features'
---

# Communication for Kubernetes-based features

The goal of this document is to define how teams, building Kubernetes-based GitLab features, can leverage GitLab Kubernetes Agent to communicate with GitLab from within the cluster.

Communication with the in-cluster agent is covered by the [GitLab to Kubernetes communication](../gitlab_to_kubernetes_communication/index.md) blueprint.

## Challenges

Configure and other GitLab teams may want to add new functionality to the GitLab Kubernetes Agent (`agentk`), the in-cluster component. Some of the features may need to make requests to GitLab. That may be to send some information from the cluster or to get some data from GitLab, or both. 

An organic way to build this would be to add API endpoints (gRPC methods) to Kubernetes Agent Server (`gitlab-kas`) that proxy requests to GitLab. On GitLab side some features would also require new endpoints. This would happen as needed, for each feature.

In the long term this approach would lead to:

- A lot of unique endpoints that `gitlab-kas` needs to be able to access.
- Overhead for each new feature. Code needs to be added not only to GitLab and `agentk`, but also to `gitlab-kas`.

## Proposal

Implement a consolidated REST endpoint on the GitLab side and expose access to it to `agentk` to allow to make requests to the desired REST endpoint. This would make `gitlab-kas` oblivious of which API endpoint is being called and hence no code changes would be necessary in it to add new functionality.

### Security

To prevent server-side request forgery:

- Agent authentication token is only recognized by endpoints under `/api/v4/internal/kubernetes/`. `gitlab-kas` already cannot authenticate and use any other GitLab API endpoints.
- A nested endpoint like `/api/v4/internal/kubernetes/requests_coming_from_agentk/<agentk_plugin_name>/<api_path>` will be used for all such requests.

### Iterations

TBD

## Who

Proposal:

<!-- vale gitlab.Spelling = NO -->

| Role                         | Who
|------------------------------|-------------------------|
| Author                       |    Mikhail Mazurskiy    |
| Architecture Evolution Coach |    Andrew Newdigate     |
| Engineering Leader           |    Nicholas Klick       |
| Domain Expert                |    Thong Kuah           |
| Domain Expert                |    Graeme Gillies       |
| Security Expert              | Vitor Meireles De Sousa |

DRIs:

| Role                         | Who
|------------------------------|------------------------|
| Product Lead                 |    Viktor Nagy         |
| Engineering Leader           |    Nicholas Klick      |
| Domain Expert                |    Mikhail Mazurskiy   |

<!-- vale gitlab.Spelling = YES -->
