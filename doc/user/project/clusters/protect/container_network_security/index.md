---
stage: Protect
group: Container Security
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#designated-technical-writers
---

# Container Network Security

GitLab's Container Network Security capabilities provide basic firewalling functionality by leveraging Cilium NetworkPolicies to filter traffic going in and out of the cluster as well as traffic between pods inside the cluster.
much more.

## Overview

Container Network Security can be used to enforce L3, L4, and L7 policies and can prevent an attacker with control over one pod from spreading laterally to access other pods in the same cluster. Both Ingress and Egress rules are supported.

By default, Cilium is deployed in Detection-only mode and only logs attack attempts.  GitLab provides a set of out-of-the-box policies as examples and to help users get started.  As these policies usually need to be customized to match application-specific needs, these out-of-the-box policies come disabled by default.

## Installation

See the [installation guide](quick_start_guide.md) for the recommended steps to install GitLab's Container Network Security capabilities.

NOTE: **Note:**
This guide shows the recommended way of installing Container Network Security through GMAv2; however, it is also possible to do a manual install of Cilium through our Helm chart.

## Features

- GitLab managed installation of Cilium
- Support for L3, L4, and L7 policies
- Ability to export logs to a SIEM
- Statistics page showing volume of packets processed and dropped over time (Gold/Ultimate users only)
- Management of NetworkPolicies through code in a project (Available for auto DevOps users only)
- Management of CiliumNetworkPolicies through a UI policy manager (Gold/Ultimate users only)

## Support

### Supported container orchestrators
Currently Kubernetes v1.14+ is the only supported container orchestrator.  OpenShift and other container orchestrators are not yet supported.

### Supported Kubernetes providers
Currently the following cloud providers are supported:
- Amazon EKS
- Google GKE

Container Network Security is not officially tested and supported for Azure or for self-hosted Kubernetes instances at this time; however, in theory it is possible to use it with those providers.

### Supported NetworkPolicies

Currently only the use of CiliumNetworkPolicies is officially supported through GitLab.  While generic Kubernetes NetworkPolicies or other kinds of NetworkPolicies may work, those are not tested or officially supported.

## Managing NetworkPolicies through GitLab vs your Cloud Provider

Some cloud providers offer integrations with Cilium or offer other ways to manage NetworkPolicies in Kubernetes.  Currently Container Network Security is not supported for deployments that have NetworkPolicies managed by an external provider.  By choosing to manage NetworkPolicies through GitLab, users are able to take advantage of the following benefits:

- Support for handling NetworkPolicy Infrastructure as Code
- Full revision history and audit log of all changes made
- Ability to revert back to a previous version at any time

## Roadmap

You can find more information on the product direction of Container Network Security at
[Category Direction - Container Network Security](https://about.gitlab.com/direction/protect/container_network_security/).
