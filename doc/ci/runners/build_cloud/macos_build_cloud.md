---
stage: Verify
group: Runner
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#assignments
---

# Build Cloud runners for macOS (beta)

GitLab Build Cloud runners for macOS are in [beta](https://about.gitlab.com/handbook/product/gitlab-the-product/#beta)
and shouldn't be used for production workloads. 

## CI minute quota and pricing

While in beta, the [shared runner pipeline quota](../admin_area/settings/continuous_integration.md#shared-runners-pipeline-minutes-quota)
applies for groups and projects in the same manner as Linux runners. This will change when the offer transitions to general availability (GA).

## Virtual machine configuration

GitLab Build Cloud runners for macOS are powered by Mac Server infrastructure hosted by Mac Stadium, a leading provider of enterprise-class cloud solutions for Mac.

The available machine type is `gbc-macos-large`.

| Instance type | vCPUS | Memory (GB) | Notes |
| --------- | --- | ------- | ------- |
|  `gbc-macos-large` | 4 | 10 | default, beta |

## Quickstart

To start using the runners for macOS:

1. Add a `.gitlab-ci.yml` file to your project repository.
1. Commit a change to your repository.

The runners automatically run your build.

## Example `.gitlab-ci.yml` file

Below is a sample `.gitlab-ci.yml` file that shows how to start using the runners for macOS:

```yaml
.macos_buildcloud_runners:
  tags:
    - shared-macos-amd64

stages:
  - build
  - test

before_script:
 - echo "started by ${GITLAB_USER_NAME}"

build:
  extends:
    - .macos_buildcloud_runners
  stage: build
  script:
    - echo "running scripts in the build job"

test:
  extends:
    - .macos_buildcloud_runners
  stage: test
  script:
    - echo "running scripts in the test job"
```
