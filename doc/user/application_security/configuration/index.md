---
type: reference, howto
stage: Secure
group: Static Analysis
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#designated-technical-writers
---

# Security Configuration **(ULTIMATE)**

> [Introduced](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/20711) in [GitLab Ultimate](https://about.gitlab.com/pricing/) 12.6.

## Overview

The security configuration page displays the configuration state of each of the security
features and can be accessed through a project's sidebar nav.

![Screenshot of security configuration page](../img/security_configuration_page_v13_2.png)

The page uses the project's latest default branch [CI pipeline](../../../ci/pipelines/index.md) to determine the configuration
state of each feature. If a job with the expected security report artifact exists in the pipeline,
the feature is considered configured.

NOTE: **Note:**
If the latest pipeline used [Auto DevOps](../../../topics/autodevops/index.md),
all security features will be configured by default.

## SAST Configuration

> [Introduced](https://gitlab.com/groups/gitlab-org/-/epics/3659) in GitLab Ultimate 13.3.

For projects that do not already have a `.gitlab-ci.yml` file,
[configure SAST in the UI](../sast/index.md#configure-sast-in-the-ui).

## Limitations

It is not yet possible to enable or disable most features using the
configuration page. However, instructions on how to enable or disable a feature
can be found through the links next to each feature on that page.

If a project does not have an existing CI configuration, then the SAST feature
can be enabled by clicking on the "Enable with Merge Request" button under the
"Manage" column. Future work will expand this to editing _existing_ CI
configurations, and to other security features.
