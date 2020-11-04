---
stage: configure
group: configure
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#designated-technical-writers
comments: false
description: 'GitLab to Kubernetes communication'
---

# GitLab to Kubernetes communication

## Challenges

### Lack of network connectivity 

For various features that exist today GitLab communicates with Kubernetes by directly or indirectly calling its API endpoints. This works fine as long as there is a network path from GitLab to the cluster. This is not always the case:

- GitLab.com and a self-managed cluster where the cluster is not exposed to the Internet.
- GitLab.com and a cloud-vendor managed cluster where the cluster is not exposed to the Internet.
- Self-managed GitLab and a cloud-vendor managed cluster where the cluster is not exposed to the Internet and where there is no private peering between cloud network and customer's network.

Even if technically possible, it's almost always undesirable to expose a Kubernetes cluster's API to the Internet for security reasons. Because of that, our customers are reluctant to do so and are faced with a choice of security vs the features GitLab provides.

The above is true not only for Kubernetes' API but for all APIs exposed by services running on a customer's cluster that GitLab may need to access. For example, Prometheus running in a cluster must be exposed for our integration to be able to access it.

### Cluster-admin permissions

Both current integrations - BYO cluster (certificate-based) and GitLab-managed cluster in a cloud, require granting full cluster-admin access to GitLab. Credentials are stored on the GitLab side and this is yet another security concern for our customers.

See [#212810](https://gitlab.com/gitlab-org/gitlab/-/issues/212810) for a discussion on the above issues.

## [GitLab Kubernetes Agent](https://gitlab.com/gitlab-org/cluster-integration/gitlab-agent) ([epic](https://gitlab.com/groups/gitlab-org/-/epics/3329))

To address the challenges above and to provide some new functionality, ~"group::configure" is building an active in-cluster component that inverts the direction of communication. Customer installs an agent into their cluster, the agent connects to GitLab.com or their self-managed GitLab instance, receiving commands from it. Customer does not need to provide any credentials to GitLab and is in full control of what permissions the agent has.

### Request routing

Agents connect to the server-side component called GitLab Kubernetes Agent Server (`gitlab-kas`) and keep an open connection, essentially waiting for commands. The difficulty with the approach is in routing requests from GitLab to the correct agent - in each cluster there may be multiple logical agents, each may be running as multiple replicas (`Pod`s), connected to an arbitrary `gitlab-kas` instance.

Existing and new functionality requires real-time access to the APIs of the cluster (and/or APIs of components, running in the cluster) and hence it'd be hard to pass the information back and forth using the more traditional polling approach.

A good example to illustrate the real-time need is the Prometheus integration again. If we want to e.g. draw real-time graphs we need direct access to the Prometheus API to make queries and quickly get results. `gitlab-kas` could expose Prometheus API to GitLab and transparently route traffic to one of the correct agents, connected at the moment.

## Proposal

Implement request routing in `gitlab-kas`, encapsulating and hiding all related complexity from the main application by providing a clean API to work with Kubernetes and the agents.

The above does not necessarily mean we'll proxy Kubernetes' API directly, but that is possible should we need it.

What APIs `gitlab-kas` provides depends on the features we'll develop, but first we need to solve the request routing problem as it blocks any and all features that require direct communication with agents, Kubernetes or in-cluster services.

### Iterations

Iterations will be tracked in [the dedicated epic](https://gitlab.com/groups/gitlab-org/-/epics/4591).

## Who

Proposal:

<!-- vale gitlab.Spelling = NO -->

| Role                         | Who
|------------------------------|-------------------------|
| Author                       |    Mikhail Mazurskiy    |
| Architecture Evolution Coach |                         |
| Engineering Leader           |    Daniel Croft         |
| Domain Expert                |    Thong Kuah           |
| Domain Expert                |    Graeme Gillies       |

DRIs:

| Role                         | Who
|------------------------------|------------------------|
| Product Lead                 |    Viktor Nagy         |
| Engineering Leader           |    Daniel Croft        |
| Domain Expert                |    Mikhail Mazurskiy   |

<!-- vale gitlab.Spelling = YES -->
