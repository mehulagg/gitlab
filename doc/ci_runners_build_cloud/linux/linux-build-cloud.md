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

### Settings

The Linux runners are managed by the for shared-runners-manager-X Runner Managers. Jobs handled by the shared-runners-manager-X.gitlab.com Runner Managers time out after 3 hours, regardless of the timeout configured in a project. Check the issues 4010 and 4070 for the reference. 

| Setting                               | GitLab.com                                        | Default    |
| -----------                           | -----------------                                 | ---------- |
| [GitLab Runner](https://gitlab.com/gitlab-org/gitlab-runner) | [Runner versions dashboard](https://dashboards.gitlab.com/d/000000159/ci?from=now-1h&to=now&refresh=5m&orgId=1&panelId=12&fullscreen&theme=light) | - |
| Executor                              | `docker+machine`                                  | -          |
| Default Docker image                  | `ruby:2.5`                                        | -          |
| `privileged` (run [Docker in Docker](https://hub.docker.com/_/docker/)) | `true`          | `false`    |

#### Pre-clone script

Linux shared runners on GitLab.com provide a way to run commands in a CI
job before the runner attempts to run `git init` and `git fetch` to
download a GitLab repository. The
[`pre_clone_script`](https://docs.gitlab.com/runner/configuration/advanced-configuration.html#the-runners-section)
can be used for:

- Seeding the build directory with repository data
- Sending a request to a server
- Downloading assets from a CDN
- Any other commands that must run before the `git init`

To use this feature, define a [CI/CD variable](../../ci/variables/README.md#custom-cicd-variables) called
`CI_PRE_CLONE_SCRIPT` that contains a bash script.

[This example](../../development/pipelines.md#pre-clone-step)
demonstrates how you might use a pre-clone step to seed the build
directory.

#### `config.toml`

The full contents of our `config.toml` are:

NOTE:
Settings that are not public are shown as `X`.

**Google Cloud Platform**

```toml
concurrent = X
check_interval = 1
metrics_server = "X"
sentry_dsn = "X"

[[runners]]
  name = "docker-auto-scale"
  request_concurrency = X
  url = "https://gitlab.com/"
  token = "SHARED_RUNNER_TOKEN"
  pre_clone_script = "eval \"$CI_PRE_CLONE_SCRIPT\""
  executor = "docker+machine"
  environment = [
    "DOCKER_DRIVER=overlay2",
    "DOCKER_TLS_CERTDIR="
  ]
  limit = X
  [runners.docker]
    image = "ruby:2.5"
    privileged = true
    volumes = [
      "/certs/client",
      "/dummy-sys-class-dmi-id:/sys/class/dmi/id:ro" # Make kaniko builds work on GCP.
    ]
  [runners.machine]
    IdleCount = 50
    IdleTime = 3600
    MaxBuilds = 1 # For security reasons we delete the VM after job has finished so it's not reused.
    MachineName = "srm-%s"
    MachineDriver = "google"
    MachineOptions = [
      "google-project=PROJECT",
      "google-disk-size=25",
      "google-machine-type=n1-standard-1",
      "google-username=core",
      "google-tags=gitlab-com,srm",
      "google-use-internal-ip",
      "google-zone=us-east1-d",
      "engine-opt=mtu=1460", # Set MTU for container interface, for more information check https://gitlab.com/gitlab-org/gitlab-runner/-/issues/3214#note_82892928
      "google-machine-image=PROJECT/global/images/IMAGE",
      "engine-opt=ipv6", # This will create IPv6 interfaces in the containers.
      "engine-opt=fixed-cidr-v6=fc00::/7",
      "google-operation-backoff-initial-interval=2" # Custom flag from forked docker-machine, for more information check https://github.com/docker/machine/pull/4600
    ]
    [[runners.machine.autoscaling]]
      Periods = ["* * * * * sat,sun *"]
      Timezone = "UTC"
      IdleCount = 70
      IdleTime = 3600
    [[runners.machine.autoscaling]]
      Periods = ["* 30-59 3 * * * *", "* 0-30 4 * * * *"]
      Timezone = "UTC"
      IdleCount = 700
      IdleTime = 3600
  [runners.cache]
    Type = "gcs"
    Shared = true
    [runners.cache.gcs]
      CredentialsFile = "/path/to/file"
      BucketName = "bucket-name"
```

