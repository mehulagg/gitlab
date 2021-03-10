---
stage: Protect
group: Container Security
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#designated-technical-writers
---

# Security Orchestration **(FREE)**

> - [Introduced](https://gitlab.com/groups/gitlab-org/-/epics/5329) in GitLab 13.10.
> - It's deployed behind a feature flag, disabled by default.
> - It's disabled on GitLab.com.

Security Orchestration in GitLab provides security teams a way to enforce/require scans of their choice to be run whenever a project pipeline is run according to the configuration specified so that they can be confident that the scans they set up have not been changed, altered, or disabled.

## Enable or disable Security Orchestration

Security Orchestration is under development and not ready for production use. It's
deployed behind a feature flag that's **disabled by default**.
[GitLab administrators with access to the GitLab Rails console](../../../../../administration/feature_flags.md)
can enable it for your instance. Security Orchestration can be enabled or disabled per-project.

To enable it:

```ruby
# Instance-wide
Feature.enable(:security_orchestration_policies_configuration)
# or by project
Feature.enable(:security_orchestration_policies_configuration, Project.find(<project ID>))
```

To disable it:

```ruby
# Instance-wide
Feature.disable(:security_orchestration_policies_configuration)
# or by project
Feature.disable(:security_orchestration_policies_configuration, Project.find(<project ID>))
```

## Installation

See the [installation guide](quick_start_guide.md) for the recommended steps to install GitLab
Security Orchestration. This guide shows the recommended way of installing scanning policies

## Features

- Allow enforecement of DAST scans.

## Roadmap

See the [Category Direction page](https://about.gitlab.com/direction/protect/container_network_security/)
for more information on the product direction of Container Network Security.
