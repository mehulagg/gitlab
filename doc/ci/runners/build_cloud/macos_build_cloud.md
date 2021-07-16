---
stage: Verify
group: Runner
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#assignments
---

# Build Cloud runners for macOS (beta)

Build Cloud for macOS Beta provides on-demand GitLab Runners integrated with GitLab SaaS [CI/CD](https://docs.gitlab.com/ee/ci/index.html) to build, test and deploy apps for the Apple ecosystem (macOS, IOS, tvOS).

Build Cloud runners for macOS are in [beta](https://about.gitlab.com/handbook/product/gitlab-the-product/#beta)
and shouldn't be relied upon for mission-critical production jobs. 

## Quickstart

To start using Build Cloud for macOS beta, you will need to submit an access request issue. Once your access request has been granted and your build environment configured, you will need to configure your `.gitlab-ci.yml` pipeline file as follows:

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

**Note** during the beta period we plan to complete the enablement of the GitLab macOS Autoscaler and activate the instance-wide macOS Runner Managers on GitLab SaaS. We will notify all beta participants of any planned maintenance in order to complete this work.
