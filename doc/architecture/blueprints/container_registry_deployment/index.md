---
comments: false
description: 'Self-service Container Registry deployment'
---

# Usage of the GitLab Container Registry

With the Docker Container Registry integrated into GitLab, every GitLab project can have its own space to store its Docker images. You can use the registry to build, push and share images using the Docker client, CI/CD or the GitLab API. Each day on GitLab.com, between [150 and 200 thousand images are pushed to the registry](https://app.periscopedata.com/app/gitlab/527857/Package-GitLab.com-Stage-Activity-Dashboard?widget=9620193&udv=0) and about [700k API events](https://app.periscopedata.com/app/gitlab/527857/Package-GitLab.com-Stage-Activity-Dashboard?widget=7601761&udv=0). 

It’s also worth noting that although many customers use multiple registry vendors, more than 96% of instances have configured their [instance to use the GitLab Container Registry](https://app.periscopedata.com/app/gitlab/527857/Package-GitLab.com-Stage-Activity-Dashboard?widget=9832282&udv=0). 

For GitLab.com and for GitLab's customers, the Container Registry is a critical component to building and deploying software. 

## Challenges

With registry v3.0, we intend to include several major architectural changes. We will update the registry to store image manifests in PostgreSQL instead of ojbect storage. This will allow us to implement [lightning](https://gitlab.com/groups/gitlab-org/-/epics/3011) and [zero-downtime garbage collection](https://gitlab.com/groups/gitlab-org/-/epics/3012), saving tens of thousands of dollars each month in storage costs.

When considering GitLab and the Community's reliance on the registry, it's critical that we do not introduce breaking changes. Yet, when considering the amount of changes included in v3 of the registry, it's unlikely that we will not encounter bugs, especially considering the scale of the registry. That is why we will need a self-service registry deployment. So when issues arise, even though we'll do our best to avoid them, they can be remediated as quickly as possible. 

The current deployment process takes 1-2 days and can be viewed in the [issue template](https://gitlab.com/gitlab-org/container-registry/-/blob/master/.gitlab/issue_templates/Release%20Plan.md).

There are some additional challenges worth noting as well:

- How to support backend database migrations [container-registry-#221](https://gitlab.com/gitlab-org/container-registry/-/issues/221)
- [Whether or not PostgreSQL 12 is a hard requirement](https://gitlab.com/gitlab-com/gl-infra/infrastructure/-/issues/11154#note_420820923)

## Goals

The priority is to be able to ship for GitLab.com on a regular basis with minimal manual intervention and delay.

## Proposal

1. Upon a tag in `gitlab-org/container-registry`, trigger a deploy to `k8s-workloads/gitlab-com`
1. This triggered pipeline will need to receive some information, minimally, the version desired, though we'll need more to ensure the correct pipeline is built.
1. The pipeline will perform its deploy, which closes this issue, and sets a precedent for delivery#552

To get here, I propose the following:

- Modify `k8s-workloads/gitlab-com` to accept information on the registry version and build an appropriate deployment pipeline
- Modify `k8s-workloads/gitlab-com` such that it can apply the Container Registry in an idempotent manner, similar to what we did with auto-deploy and Sidekiq
- Make some form of locking mechanism, such that registry deployments, auto-deploy deployments, etc, do not stomp on top of each other
  - This is already a hindrance at times...
- Build out notification capabilities as already described here:
  - [delivery#669](https://gitlab.com/gitlab-com/gl-infra/delivery/issues/669)
  - [delivery#526](https://gitlab.com/gitlab-com/gl-infra/delivery/-/issues/526)
- Add safety checks to validate it is safe to proceed with a deployment at each stage
  - This would use metric `gitlab_deployment_health:service`
  - Currently this does not monitor the registry component so it will need to be added.
- And finally, something added to `gitlab-org/container-registry` where upon a tag, it'll send a trigger

The idempotent part is important that way we do not store the version in the Git repo. Instead this is maintained as a tag at `gitlab-org/container-registry` with pipeline pointers serving as an audit/compliance mechanism. Idempotency will also help in the case of a failure; we don't need to worry about trying to figure out or build some mechanism to roll back the desired version which is currently stored in Git.

### Questions

#### A few open questions

- Our pipelines deploy to Production manually. Should we leave that manual action in place?
- Currently the permissions model is very tight on the ops instance, preventing persons outside of Infrastructure from seeing the status or output of pipelines. How can we revise our permissions model such that users minimally have read access to `k8s-workloads/gitlab-com` on the ops instance?

#### A few answered questions

- We run QA for non-auto-deploy pipelines. Has QA improved the testing on the Container Registry?
  - Based on `gitlab-org/quality/testcases#14`, the answer is no; we can attempt to utilize the metric `gitlab_deployment_health:service` for creating a check allowing a production deploy. This metric monitors apdex and error ratio. The goal for this would be to validate we've not exceeded thresholds for canary providing us with confidence that we can move forward with a production deploy.
- Is there any sort of tight version dependency between `gitlab-rails` and the Container Registry?
  - The Container Registry is fully independent of the rails app. On the other way around, the rails app does depend on specific versions of the Container Registry to enable some features, but that's expected.
- What protections do we have in place such that if there's a scenario that prevented the Container Registry from being properly updated, so it's stuck on version X, but GitLab Rails is updated and might require version Y of the Container Registry?
  - There is no automated protection mechanism for this.
- Currently there's no mechanism. For us, during auto-deploy, to validate that we are running a specific version of the Container Registry prior to GitLab being deployed too. How can we avoid situations where functionality of GitLab is broken if there's a dependency in this realm. Fallback methods and feature toggling should not be the (only) answers to this.
  - There is no automated protection mechanism for this.
- How is it done for other components?
  - Other components all maintain their own version file inside of the GitLab code base. [Example](https://gitlab.com/gitlab-org/gitlab/-/blob/v13.2.9-ee/GITLAB_ELASTICSEARCH_INDEXER_VERSION)

## Reasons

These are reason why these changes are needed:
- Ensure the smooth deployment of the GitLab Container Registry
- Reduce the total time to remediation for any future registry incidents.
- Ensure there is a smooth migration from registry 2.x to 3.0.

## Iterations

This work is being done as part of dedicated epic: [gl-infra-#316](https://gitlab.com/groups/gitlab-com/gl-infra/-/epics/316). This epic details the proposed solution and ideas for future iterations. 

## Who

Proposal:

| Role                         | Who
|------------------------------|-------------------------|
| Author                       |                         |
| Architecture Evolution Coach |                         |
| Engineering Leader           |                         |
| Domain Expert                |                         |

DRIs:

| Role                         | Who
|------------------------------|------------------------|
| Product                      |                        |
| Leadership                   |                        |
| Engineering                  |                        |
