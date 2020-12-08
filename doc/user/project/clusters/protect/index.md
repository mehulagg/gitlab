---
stage: Protect
group: Container Security
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#designated-technical-writers
---

# Protecting your deployed applications

GitLab makes it easy to protect applications deployed in [connected Kubernetes clusters](index.md).  GitLab's protections are available in both the Kubernetes network layer, and in the container itself.

At the network layer, GitLab's Container Network Security capabilities provide basic firewalling functionality by leveraging Cilium NetworkPolicies to filter traffic going in and out of the cluster as well as traffic between pods inside the cluster.

Inside the container, GitLab's Container Host Security provides Intrusion Detection and Prevention capabilities that can monitor and block activity inside the containers themselves.

## Capabilities

The following capabilities are available to protect deployed applications in Kubernetes:

- Web Application Firewall - [overview](web_application_firewall/index.md) - [installation guide](web_application_firewall/quick_start_guide.md)
- Container Network Security - [overview](container_network_security/index.md) - [installation guide](container_network_security/quick_start_guide.md)
- Container Host Security - [overview](container_host_security/index.md) - [installation guide](container_host_security/quick_start_guide.md)
