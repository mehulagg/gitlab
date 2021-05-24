---
comments: false
stage: Verify
group: Runner
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#assignments
---

## Windows Build Cloud (BETA)

GiLab Build Cloud Windows Runners are in [beta](https://about.gitlab.com/handbook/product/gitlab-the-product/#beta)
and shouldn't be used for production workloads. 

### CI Minutes Quota and Pricing

While in beta, the [shared runner pipeline quota](../admin_area/settings/continuous_integration.md#shared-runners-pipeline-minutes-quota)
applies for groups and projects in the same manner as Linux runners. This will change when the offer transitions to GA.

### Virtual Machine Configuration

GitLab Build Cloud Window runners are powered by Google Compute and use the GitLab Runner Shell executor. This means that your CI job runs on the OS environment of VM. 

The default and currently only available machine type is the gbc-windows-medium, a GCP n1-standard-2 machine type. 

| Offer name | vCPUS | Memory (GB) |Notes|
| --------- | --- | ------- |------- |
|  gbc-windows-medium| 2 | 7.5 |default, beta|

### Quickstart

This section describes how to quickly get started. Overall, the process involves a few steps:

1. Add a .gitlab-ci.yml file to your project repository and ensure that it includes the tags as in the example below.
1. Commit a change to your repo and the GitLab.com Build Cloud Windows Runners will automatically run your build.

Below is a simple `.gitlab-ci.yml` file with the required tag definitions.

```yaml
.shared_windows_runners:
  tags:
    - shared-windows
    - windows
    - windows-1809

stages:
  - build
  - test

before_script:
 - Set-Variable -Name "time" -Value (date -Format "%H:%m")
 - echo ${time}
 - echo "started by ${GITLAB_USER_NAME}"

build:
  extends:
    - .shared_windows_runners
  stage: build
  script:
    - echo "running scripts in the build job"

test:
  extends:
    - .shared_windows_runners
  stage: test
  script:
    - echo "running scripts in the test job"
```

### Settings

NOTE:
Settings that aren't public are shown as `X`.

```toml
concurrent = X
check_interval = 3

[[runners]]
  name = "windows-runner"
  url = "https://gitlab.com/"
  token = "TOKEN"
  executor = "custom"
  builds_dir = "C:\\GitLab-Runner\\builds"
  cache_dir = "C:\\GitLab-Runner\\cache"
  shell  = "powershell"
  [runners.custom]
    config_exec = "C:\\GitLab-Runner\\autoscaler\\autoscaler.exe"
    config_args = ["--config", "C:\\GitLab-Runner\\autoscaler\\config.toml", "custom", "config"]
    prepare_exec = "C:\\GitLab-Runner\\autoscaler\\autoscaler.exe"
    prepare_args = ["--config", "C:\\GitLab-Runner\\autoscaler\\config.toml", "custom", "prepare"]
    run_exec = "C:\\GitLab-Runner\\autoscaler\\autoscaler.exe"
    run_args = ["--config", "C:\\GitLab-Runner\\autoscaler\\config.toml", "custom", "run"]
    cleanup_exec = "C:\\GitLab-Runner\\autoscaler\\autoscaler.exe"
    cleanup_args = ["--config", "C:\\GitLab-Runner\\autoscaler\\config.toml", "custom", "cleanup"]
```

The full contents of our `autoscaler/config.toml` are:

```toml
Provider = "gcp"
Executor = "winrm"
OS = "windows"
LogLevel = "info"
LogFormat = "text"
LogFile = "C:\\GitLab-Runner\\autoscaler\\autoscaler.log"
VMTag = "windows"

[GCP]
  ServiceAccountFile = "PATH"
  Project = "some-project-df9323"
  Zone = "us-east1-c"
  MachineType = "n1-standard-2"
  Image = "IMAGE"
  DiskSize = 50
  DiskType = "pd-standard"
  Subnetwork = "default"
  Network = "default"
  Tags = ["TAGS"]
  Username = "gitlab_runner"

[WinRM]
  MaximumTimeout = 3600
  ExecutionMaxRetries = 0

[ProviderCache]
  Enabled = true
  Directory = "C:\\GitLab-Runner\\autoscaler\\machines"
```

### Software Configuration

You can find a full list of available Windows packages in
the [package documentation](https://gitlab.com/gitlab-org/ci-cd/shared-runners/images/gcp/windows-containers/blob/master/cookbooks/preinstalled-software/README.md).


#### Limitations and known issues

- All the limitations mentioned in our [beta
  definition](https://about.gitlab.com/handbook/product/#beta).
- The average provisioning time for a new Windows VM is 5 minutes.
  This means that you may notice slower build start times
  on the Windows shared runner fleet during the beta. In a future
  release we intend to update the autoscaler to enable
  the pre-provisioning of virtual machines. This is intended to significantly reduce
  the time it takes to provision a VM on the Windows fleet. You can
  follow along in the [related issue](https://gitlab.com/gitlab-org/ci-cd/custom-executor-drivers/autoscaler/-/issues/32).
- The Windows shared runner fleet may be unavailable occasionally
  for maintenance or updates.
- The Windows shared runner virtual machine instances do not use the
  GitLab Docker executor. This means that you can't specify
  [`image`](../../ci/yaml/README.md#image) or [`services`](../../ci/yaml/README.md#services) in
  your pipeline configuration.
- For the beta release, we have included a set of software packages in
  the base VM image. If your CI job requires additional software that's
  not included in this list, then you must add installation
  commands to [`before_script`](../../ci/yaml/README.md#before_script) or [`script`](../../ci/yaml/README.md#script) to install the required
  software. Note that each job runs on a new VM instance, so the
  installation of additional software packages needs to be repeated for
  each job in your pipeline.
- The job may stay in a pending state for longer than the
  Linux shared runners.
- There is the possibility that we introduce breaking changes which will
  require updates to pipelines that are using the Windows shared runner
  fleet.

