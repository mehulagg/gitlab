---
comments: false
description: 'Container Registry New Architecture'
---

# Usage of the GitLab Container Registry

With the Docker Container Registry integrated into GitLab, every GitLab project can have its own space to store its Docker images. You can use the registry to build, push and share images using the Docker client, CI/CD or the GitLab API. Each day on GitLab.com, between [150 and 200 thousand images are pushed to the registry](https://app.periscopedata.com/app/gitlab/527857/Package-GitLab.com-Stage-Activity-Dashboard?widget=9620193&udv=0) and about [700k API events](https://app.periscopedata.com/app/gitlab/527857/Package-GitLab.com-Stage-Activity-Dashboard?widget=7601761&udv=0). 

It’s also worth noting that although many customers use multiple registry vendors, more than 96% of instances have configured their [instance to use the GitLab Container Registry](https://app.periscopedata.com/app/gitlab/527857/Package-GitLab.com-Stage-Activity-Dashboard?widget=9832282&udv=0). 

For GitLab.com and for GitLab's customers, the Container Registry is a critical component to building and deploying software. 

## Current Architecture

The Container Registry is a single [Go](https://golang.org/) application. Its only dependency is the storage backend on which images and metadata are stored.

``mermaid
graph LR
   C((Client)) -- HTTP request --> R(Container Registry) -- Upload/download blobs<br><br>Write/read metadata --> B(Storage Backend)
``

Client applications (e.g. GitLab Rails and Docker CLI) interact with the Container Registry through its [HTTP API](https://gitlab.com/gitlab-org/container-registry/-/blob/master/docs/spec/api.md). The most common operations are pushing and pulling images to/from the registry, which require a series of HTTP requests in a specific order. The request flow for these operations is detailed [here](https://gitlab.com/gitlab-org/container-registry/-/blob/master/docs-gitlab/push-pull-requzest-flow.md).

The registry supports multiple [storage backends](https://gitlab.com/gitlab-org/container-registry/-/blob/master/docs/configuration.md#storage), among which Google Cloud Storage (GCS), used for the GitLab.com registry. In the storage backend, images are stored as blobs, deduplicated, and shared across repositories. These are then linked (like a symlink) to each repository that relies on them, giving them access to the central storage location.

The name and hierarchy of repositories, as well as image manifests and tags are also stored in the storage backend, represented by a nested structure of folders and files. [This](https://www.youtube.com/watch?v=i5mbF2bgWoM&feature=youtu.be) video gives a practical overview of the registry storage structure.

### Challenges

#### Garbage Collection

The container registry relies on an offline *mark* and *sweep* garbage collection (GC) algorithm. To run it, the registry needs to be either shutdown or set to read-only, remaining like that during the whole GC run.

During the *mark* phase, the registry analyzes all repositories, creating a list of configurations, layers, and manifests that are referenced/linked in each one of them. The registry will then list all existing configurations, layers, and manifests (stored centrally) and obtain a list of those that are not referenced/linked in any repository. This is the list of blobs eligible for deletion.

With the output from the *mark* phase in hand, the registry starts the *sweep* phase, where it will loop over all blobs identified as eligible for deletion and delete them from the storage backend, one by one.

Doing this for a huge registry may require multiple hours/days to complete, during which the registry must remain in read-only mode. This is not feasible for platforms with tight availability requirements, such as GitLab.com.

#### Performance

Due to the current architecture and its reliance on the (possibly remote) storage backend to store repository and image metadata, even the most basic operations, such as listing repositories or tags, can become prohibitively slow, and it only gets worse as the registry grows in size.

For example, to be able to tell which repositories exist, the registry has to walk through all folders in the storage backend and identify repositories in them. Only when all folders that exist have been visited, the registry can then reply to the client with the list of repositories. If using a remote storage backend (such as GCS or S3), performance becomes even worse, as for each visited folder multiple HTTP requests are required to list and inspect their contents.

#### Insights

For similar reasons as highlighted above, currently, it's not feasible to extract valuable information from the registry, such as how much space a repository is using (e.g. to enforce quotas), which repositories are using the most space, which ones are more active, detailed push/pull metrics per image or tag, etc. Not having access to these insights and metrics strongly weakens the ability to make informed decisions in regards to the product strategy.

#### Additional Features

Due to the metadata limitations, it's currently not feasible to implement valuable features such as [pagination](https://gitlab.com/gitlab-org/container-registry/-/issues/13#note_271769891), filtering and sorting for HTTP API, and more advanced features such as the ability to [distinguish between Docker and Helm charts images](https://gitlab.com/gitlab-org/gitlab/issues/38047).

Because of all these constraints, we decided to [freeze the development of new features](https://gitlab.com/gitlab-org/container-registry/-/issues/44) until we have a solution in place to overcome all these foundational limitations.

## New Architecture

To overcome all challenges described above, we started an effort to migrate the registry metadata (the list of blobs, repositories, and which manifest/layers are referenced/linked in each one of them) from the storage backend into a PostgreSQL database.

The ultimate goal of the new architecture is to enable online garbage collection ([&2313](https://gitlab.com/groups/gitlab-org/-/epics/2313)), but once the database is in place, we will also be able to implement all features that have been blocked by the metadata limitations. The performance of the existing API should drastically increase as well.

The introduction of a database will affect the registry architecture, as we will have one more component involved:

``mermaid
graph LR
   C((Client)) -- HTTP request --> R(Container Registry) -- Upload/download blobs --> B(Storage Backend)
   R -- Write/read metadata --> D[(Database)]
``

With a database in place, the registry will no longer use the storage backend to write and read metadata. Instead, metadata will be stored and manipulated on the PostgreSQL database. The storage backend will then be used only for uploading and downloading blobs.

### Database

For GitLab.com, the registry database will be on a separate dedicated cluster. For self-managed instances, the registry database should reside in the same instance as the GitLab database. Please see [#93](https://gitlab.com/gitlab-org/container-registry/-/issues/93) and [gitlab-com/gl-infra/infrastructure#10109](https://gitlab.com/gitlab-com/gl-infra/infrastructure/-/issues/10109) for additional context.

The design and development of the registry database adhere to the GitLab [database guidelines](https://docs.gitlab.com/ee/development/database/). Being a Go application, the required tooling to support the database will have to be developed, such as for running database migrations.

Support for running *online* migrations is already supported by the registry CLI, as described in the [documentation](https://gitlab.com/gitlab-org/container-registry/-/blob/master/docs-gitlab/database-migrations.md). Apart from online migrations, [*post deployment* migrations](https://docs.gitlab.com/ee/development/post_deployment_migrations.html) are also a requirement to be implemented as outlined in [container-registry#220](https://gitlab.com/gitlab-org/container-registry/-/issues/220).

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

These are reason why these changes are needed

- Ensure the smooth deployment of the GitLab Container Registry
- Reduce the total time to remediation for any future registry incidents.
- Ensure there is a smooth migration from registry 2.x to 3.0.

## Iterations

1. ✓ Design metadata database schema;
1. ✓ Add support for managing metadata using the database;
1. Design plans and tools to facilitate the migration of small, medium and large repositories (in progress);
1. Implement online garbage collection (in progress);
1. Create database clusters in staging and production for GitLab.com;
1. Create automated deployment pipeline for GitLab.com;
1. Deployment and gradual migration of the existing registry for GitLab.com;
1. Rollout support for the metadata database to self-managed installs.

A more detailed list of all tasks, as well as periodic progress updates can be found in the epic [&2313](https://gitlab.com/groups/gitlab-org/-/epics/2313).

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
