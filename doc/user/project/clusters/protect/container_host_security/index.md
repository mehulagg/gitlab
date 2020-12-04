---
stage: Protect
group: Container Security
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#designated-technical-writers
---

# Container Host Security

GitLab's Container Host Security provides Intrusion Detection and Prevention capabilities that can monitor and (optionally) block activity inside the containers themselves. This is done by leveraging an integration with Falco to provide the monitoring capabilities and an integration with Pod Security Policies and AppArmor to provide blocking capabilities.

## Overview

Container Host Security can be used to monitor and block activity inside a container as well as to enforce security policies across the entire Kubernetes cluster. Falco profiles allow for users to define the activity they want to monitor for and detect.  Among other things, this can include system log entries, process starts, file activity, and network ports opened. AppArmor is used to block any undesired activity via AppArmor profiles.  These profiles are loaded into the cluster when referenced by Pod Security Policies.

By default, Container Host Security is deployed into the cluster in monitor mode only, with no default profiles or rules running out-of-the-box. Activity monitoring and blocking begins only when users define profiles for these technologies.

## Installation

See the [installation guide](quick_start_guide.md) for the recommended steps to install GitLab's Container Host Security capabilities.

NOTE: **Note:**
This guide shows the recommended way of installing Container Host Security through GMAv2; however, it is also possible to do a manual installation through our Helm chart.

## Features

- Prevent containers from starting as root
- Limit the privileges and system calls that are available to containers
- Monitor system logs, process starts, files read/written/deleted, and network ports opened
- Optionally block processes from starting or files from being read/written/deleted

## Support

### Supported container orchestrators
Currently Kubernetes vx.x.x+ is the only supported container orchestrator.  OpenShift and other container orchestrators are not yet supported.

## Supported Kubernetes providers

The following cloud providers are supported:

- Amazon EKS
- Google GKE

Container Host Security is not officially tested and supported for Azure or for self-hosted Kubernetes instances at this time; however, in theory it is possible to use it with those providers.

## Roadmap

You can find more information on the product direction of the WAF in
[Category Direction - Container Host Security](https://about.gitlab.com/direction/protect/container_host_security/).
