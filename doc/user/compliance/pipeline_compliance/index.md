---
type: reference, howto
stage: Manage
group: Compliance
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#assignments
---

#### Compliance pipeline configuration **(ULTIMATE)**

> - [Introduced](https://gitlab.com/groups/gitlab-org/-/epics/3156) in GitLab 13.9.
> - [Deployed behind a feature flag](../../feature_flags.md).
> - [Enabled by default](https://gitlab.com/gitlab-org/gitlab/-/issues/300324) in GitLab 13.11.
> - Enabled on GitLab.com.
> - Recommended for production use.

WARNING:
This feature might not be available to you. Check the **version history** note above for details.

Group owners can use the compliance pipeline configuration to define compliance requirements
such as scans or tests, and enforce them in individual projects.

The [custom compliance framework](#custom-compliance-frameworks) feature allows group owners to specify the location
of a compliance pipeline configuration stored and managed in a dedicated project, distinct from a developer's project.

When you set up the compliance pipeline configuration field, use the
`file@group/project` format. For example, you can configure
`.compliance-gitlab-ci.yml@compliance-group/compliance-project`.
This field is inherited by projects where the compliance framework label is applied. The result
forces the project to run the compliance configurations.

When a project with a custom label executes a pipeline, it begins by evaluating the compliance pipeline configuration.
The custom pipeline configuration can then execute any included individual project configuration.

The user running the pipeline in the project should at least have Reporter access to the compliance project.

Example `.compliance-gitlab-ci.yml`

```yaml
stages: # Allows compliance team to control the ordering and interweaving of stages/jobs
- pre-compliance
- build
- test
- pre-deploy-compliance
- deploy
- post-compliance

variables: # can be overriden by a developer's local .gitlab-ci.yml
  FOO: sast

sast: # none of these attributes can be overriden by a developer's local .gitlab-ci.yml
  variables:
    FOO: sast
  stage: pre-compliance
  script:
  - echo "running $FOO"

sanity check:
  stage: pre-deploy-compliance
  script:
  - echo "running $FOO"


audit trail:
  stage: post-compliance
  script:
  - echo "running $FOO"

include: # Execute individual project's configuration
  project: '$CI_PROJECT_PATH'
  file: '$CI_PROJECT_CONFIG_PATH'
```