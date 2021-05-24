---
comments: false
stage: Verify
group: Runner
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#assignments
---

## macOS Build Cloud (BETA)

GiLab Build Cloud macOS Runners are in [beta](https://about.gitlab.com/handbook/product/gitlab-the-product/#beta)
and shouldn't be used for production workloads. 

### CI Minutes Quota and Pricing

While in beta, the [shared runner pipeline quota](../admin_area/settings/continuous_integration.md#shared-runners-pipeline-minutes-quota)
applies for groups and projects in the same manner as Linux runners. This will change when the offer transitions to GA.

### Virtual Machine Configuration

GitLab Build Cloud macOS Runners are powered by Mac Server infrastructure hosted by Mac Stadium, a leading provider of enterprise-class cloud solutions for Mac.

The default and currently only available machine type is the gbc-macos-large.

| Offer name | vCPUS | Memory (GB) |Notes|
| --------- | --- | ------- |------- |
|  gbc-macos-large| 4 | 10 |default, beta|

### Quickstart

This section describes how to quickly get started. Overall, the process involves a few steps:

1. Add a .gitlab-ci.yml file to your project repository.
1. Commit a change to your repo and the GitLab.com Build Cloud macOS Runners will automatically run your build.

Below is a simple `.gitlab-ci.yml` file with the required tag definitions.

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

## Additional topics

- Builds
- VM images and available software
- Code signing

