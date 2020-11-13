# GitLab CI/CD tutorial

GitLab CI/CD uses "jobs", "stages" and a "pipeline" as its fundamental building blocks.

The pipeline can contain multiple stages, and stages can contain multiple jobs. Jobs
run the commands and scripts that you need to build, test, and deploy your code.

GitLab CI/CD configuration is written in YAML, and the default configuration file
is `.gitlab-ci.yml`. Add this file to the root of your project, and GitLab uses it
automatically.

## Runners

Jobs do not run within GitLab itself. They are run by GitLab Runners which you can
install and manage yourself. You can also use free public shared runners if your
project is hosted on GitLab.com.

Runners load Docker images into containers, and then load and run the jobs within
those containers. When the job completes, the container is dropped, but any new data
created by the job can be passed to future jobs.

You need to specify the Docker image you want to use. It can be specified globally
for all jobs, but each job can also have an image specified:

```yaml
image: busybox

job-name1:
  script:
    - echo "This runs in a busybox container"
```

You can view the job log while it is running, and after it completes.

## Jobs

Jobs do all the work in pipelines. Commands added to `script` sections run within
containers like CLI commands:

```yaml
image: busybox

job-name1:
  script:
    - echo "This job runs some commands"

job-name2:
  script:
    - echo "This job runs at the same time as job-name1"
    - echo "and runs multiple commands"
    - sleep 100
```

## Stages

Stages are used to group jobs together. All jobs in a stage run in parallel and independently.
Stages run in order (unless you use DAG), so that later stages must wait for earlier
stages to complete before they start. The default stages are `Build`, `Test`, `Deploy`,
but you can define any name you want with the `stages:` keyword:

```yaml
image: busybox

stages:
  - Build
  - Test
  - Deploy

my-build-job:
  stage: Build
  script:
    - echo "This builds code"

my-test-job-1:
  stage: Test
  script:
    - echo "This tests some of the code from my-build-job"

my-test-job-1:
  stage: Test
  script:
    - echo "This tests some different code from my-build-job"

my-deploy-job:
  stage: Deploy
  script:
    - echo "This deploys my project, after the code is built and tested successfully"
```

If a job fails the complete successfully, all the other jobs in the stage continue
to run, but by default later stages don't start. This behavior can be controlled
with the `when` keyword.

```yaml
image: busybox

stages:
  - Build
  - Test
  - Deploy

my-build-job:
  stage: Build
  script:
    - echo "This builds code"

my-test-job-1:
  stage: Test
  script:
    - echo "This tests some of the code from my-build-job"

my-test-job-1:
  stage: Test
  script:
    - echo "This tests some different code from my-build-job"
    - echo "but something goes wrong and it fails"
    - exit 1

my-deploy-job:
  stage: Deploy
  script:
    - echo "This deploys my project, after the code is built and tested successfully"
```

## Variables
