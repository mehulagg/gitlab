---
comments: false
stage: Verify
group: Runner
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#assignments
---

## Linux Build Cloud (GA)

GiLab Build Cloud Linux runners use the GitLab Runner Docker executor. This means that your CI job runs in the container image that you specify in your .gitlab-ci.yml pipeline file. 
GitLab Build Cloud Linux runners are powered by Google Compute. 

The default and currently only available machine type is the gbc-linux-small, a GCP n1-standard-1 machine type. 

| Offer name | vCPUS | Memory (GB) |Notes|
| --------- | --- | ------- |------- |
|  gbc-linux-small| 1 | 3.75 |default, generally available|
|  gbc-linux-medium   | TBD | TBD |not yet available|
|  gbc-linux-large   | TBD | TBD |not yet available|

### Quickstart

This section describes how to quickly get started. Overall, the process involves a few steps:

1. Add a .gitlab-ci.yml file to your project repository.
1. Specify the docker image that you would like to use for each CI job in your pipeline.

Below is a simple `.gitlab-ci.yml` file. In this example the `ruby:2.5` image is specified only once so this container image version will be used for all of the jobs in the pipeline. You can also specifiy a different container image for each job in the pipeline.

```yaml
image: "ruby:2.5"

stages:
  - build
  - test

before_script:
 - Set-Variable -Name "time" -Value (date -Format "%H:%m")
 - echo ${time}
 - echo "started by ${GITLAB_USER_NAME}"

build-code-job:
  stage: build
  script:
    - echo "Check the ruby version, then build some Ruby project files:"
    - ruby -v
    - rake

test-code-job1:
  stage: test
  script:
    - echo "If the files are built successfully, test some files with one command:"
    - rake test1

test-code-job2:
  stage: test
  script:
    - echo "If the files are built successfully, test other files with a different command:"
    - rake test2
```

