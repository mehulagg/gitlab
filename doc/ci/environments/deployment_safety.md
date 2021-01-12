---
stage: Release
group: Release
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#assignments
---

# Deployment safety

Deployment jobs can be more sensitive than other jobs in a pipeline,
and might need to be treated with extra care. GitLab has several features
that help maintain deployment security and stability.

You can:

- [Restrict write-access to a critical environment](#restrict-write-access-to-a-critical-environment)
- [Prevent deployments during deploy freeze windows](#prevent-deployments-during-deploy-freeze-windows)
- [Set appropriate roles to your project](Setting-appropriate-roles-to-your-project)
- [Protect production secrets](#protect-production-secrets)
- [Seperate project for deployments](#seperate-project-for-deployments)

If you are using a continuous deployment workflow and want to ensure that concurrent deployments to the same environment do not happen, you should enable the following options:

- [Ensure only one deployment job runs at a time](#ensure-only-one-deployment-job-runs-at-a-time)
- [Skip outdated deployment jobs](#skip-outdated-deployment-jobs)

## Restrict write access to a critical environment

By default, environments can be modified by any team member that has [Developer permission or higher](../../user/permissions.md#project-members-permissions).
If you want to restrict write access to a critical environment (for example a `production` environment),
you can set up [protected environments](protected_environments.md).

## Ensure only one deployment job runs at a time

Pipeline jobs in GitLab CI/CD run in parallel, so it's possible that two deployment
jobs in two different pipelines attempt to deploy to the same environment at the same
time. This is not desired behavior as deployments should happen sequentially.

You can ensure only one deployment job runs at a time with the [`resource_group` keyword](../yaml/README.md#resource_group) in your `.gitlab-ci.yml`.

For example:

```yaml
deploy:
  script: deploy-to-prod
  resource_group: prod
```

Example of a problematic pipeline flow **before** using the resource group:

1. `deploy` job in Pipeline-A starts running.
1. `deploy` job in Pipeline-B starts running. *This is a concurrent deployment that could cause an unexpected result.*
1. `deploy` job in Pipeline-A finished.
1. `deploy` job in Pipeline-B finished.

The improved pipeline flow **after** using the resource group:

1. `deploy` job in Pipeline-A starts running.
1. `deploy` job in Pipeline-B attempts to start, but waits for the first `deploy` job to finish.
1. `deploy` job in Pipeline-A finishes.
1. `deploy` job in Pipeline-B starts running.

For more information, see [`resource_group` keyword in `.gitlab-ci.yml`](../yaml/README.md#resource_group).

## Skip outdated deployment jobs

The execution order of pipeline jobs can vary from run to run, which could cause
undesired behavior. For example, a deployment job in a newer pipeline could
finish before a deployment job in an older pipeline.
This creates a race condition where the older deployment finished later,
overwriting the "newer" deployment.

You can ensure that older deployment jobs are cancelled automatically when a newer deployment
runs by enabling the [Skip outdated deployment jobs](../pipelines/settings.md#skip-outdated-deployment-jobs) feature.

Example of a problematic pipeline flow **before** enabling Skip outdated deployment jobs:

1. Pipeline-A is created on the `master` branch.
1. Later, Pipeline-B is created on the `master` branch (with a newer commit SHA).
1. The `deploy` job in Pipeline-B finishes first, and deploys the newer code.
1. The `deploy` job in Pipeline-A finished later, and deploys the older code, **overwriting** the newer (latest) deployment.

The improved pipeline flow **after** enabling Skip outdated deployment jobs:

1. Pipeline-A is created on the `master` branch.
1. Later, Pipeline-B is created on the `master` branch (with a newer SHA).
1. The `deploy` job in Pipeline-B finishes first, and deploys the newer code.
1. The `deploy` job in Pipeline-A is automatically cancelled, so that it doesn't overwrite the deployment from the newer pipeline.

## Prevent deployments during deploy freeze windows

If you want to prevent deployments for a particular period, for example during a planned
vacation period when most employees are out, you can set up a [Deploy Freeze](../../user/project/releases/index.md#prevent-unintentional-releases-by-setting-a-deploy-freeze).
During a deploy freeze period, no deployment can be executed. This is helpful to
ensure that deployments do not happen unexpectedly.


## Setting appropriate roles to your project

1. Gitlab supports several different [roles](../../user/permissions.md#group-members-permissions) that can be assigned to your project members
  1. Guest - Has the lowest level of permissions
  1. Reporter
  1. Developer
  1. Maintainer - includes project settings (including protected configurations) - has access to produciton environment 
  1. Owner - Highest level of permissions - Full access to all project features

[!7 tips to secure your pipelines]<iframe width="560" height="315" src="https://www.youtube.com/embed/Mq3C1KveDc0" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>

## Protect production secrets 

Production secrets are needed in order to deploy successfuly. For example when deploying to the cloud, cloud providers require these secrets in order to connect to their services. Environment variables can be used and can be defined under the project settings and they can also be protected. [Protected Variables](variables.md#protect-a-custom-variable)  are only passed to pipelines running on [protected branches](../../user/project/protected_branches.md) or [protected tags](../../user/project/protected_tags.md). The other pipelines do not get the protected variable.
Variables can also be [scoped to specific environments](variables/where_variables_can_be_used.md#variables-with-an-environment-scope). It is recommended to use protected varaibles on protected environments to make sure that the secrets are not exposed to n unintentional environment.  Production secrets should also be defined on the [runner side](../../charts/installation/secrets.md#gitlab-runner-secret) this prevents other maintainers from reading the secrets and makes sure that the runner runs only on protected branches.

For more information, see [pipeline security](pipelines.md#pipeline-security-on-protected-branches).

## Seperate project for deployments

All maintainers of a project have access to production secrets. In case there is a need to limit the number of users that are deploying to a produciton environment, another way to achieve this is to create a seperate project where you can configure a new permisison model where you can isolate the CD permisisons from the original project and prevent maintainers from that project to access produciton secret and CD configuration. You can connect the CD project to your development projects by using [multi-project pipelines](multi_project_pipelines.md).

## Troubleshooting

### Pipelines jobs fail with `The deployment job is older than the previously succeeded deployment job...`

This is caused by the [Skip outdated deployment jobs](../pipelines/settings.md#skip-outdated-deployment-jobs) feature.
If you have multiple jobs for the same environment (including non-deployment jobs), you might encounter this problem, for example:

```yaml
build:service-a:
  environment:
    name: production

build:service-b:
  environment:
    name: production
```

The [Skip outdated deployment jobs](../pipelines/settings.md#skip-outdated-deployment-jobs) might
not work well with this configuration, and must be disabled.

There is a [plan to introduce a new annotation for environments](https://gitlab.com/gitlab-org/gitlab/-/issues/208655) to address this issue.
