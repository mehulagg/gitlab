---
stage: Package
group: Package
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#designated-technical-writers
---

# GitLab Container Registry

> - [Introduced](https://gitlab.com/gitlab-org/gitlab-foss/-/merge_requests/4040) in GitLab 8.8.
> - Docker Registry manifest `v1` support was added in GitLab 8.9 to support Docker
>   versions earlier than 1.10.
> - Starting in GitLab 8.12, if you have two-factor authentication enabled in your account, you need
>   to pass a [personal access token](../../profile/personal_access_tokens.md) instead of your password to
>   sign in to the Container Registry.
> - Support for multiple level image names was added in GitLab 9.1.
> - The group-level Container Registry was [introduced](https://gitlab.com/gitlab-org/gitlab/-/issues/23315) in GitLab 12.10.
> - Searching by image repository name was [introduced](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/31322) in GitLab 13.0.

With the Docker Container Registry integrated into GitLab, every GitLab project can
have its own space to store its Docker images.

You can read more about Docker Registry at <https://docs.docker.com/registry/introduction/>.

This document is the user guide. To learn how to enable the Container
Registry for your GitLab instance, visit the
[administrator documentation](../../../administration/packages/container_registry.md).

## View the Container Registry

You can view the Container Registry for a project or group.

1. Go to your project or group.
1. Go to **Packages & Registries > Container Registry**.

You can search, sort, filter, and [delete](#delete-images-from-within-gitlab) containers on this page.

CAUTION: **Warning:**
If a project is public, so is the Container Registry.

## Use images from the Container Registry

To download and run a container image hosted in the GitLab Container Registry:

1. Copy the link to your container image:
   - Go to your project or group's **Packages & Registries > Container Registry**
     and find the image you want.
   - Next to the image name, click the **Copy** button.

    ![Container Registry image URL](img/container_registry_hover_path_13_4.png)

1. Use `docker run` with the image link:

   ```shell
   docker run [options] registry.example.com/group/project/image [arguments]
   ```

For more information on running Docker containers, visit the
[Docker documentation](https://docs.docker.com/engine/userguide/intro/).

### Image naming convention

Images follow this naming convention:

```plaintext
<registry URL>/<namespace>/<project>/<image>
```

There are three different ways to refer to images:

```plaintext
registry.example.com/namespace/project:some-tag
```

```plaintext
registry.example.com/namespace/project/image:latest
```

```plaintext
registry.example.com/namespace/project/my/image:rc1
```

## Build and push images to the Container Registry

You can build and push images to the Container Registry:

- By [using Docker commands](#build-and-push-by-using-docker-commands).
- By [using GitLab CI/CD](#build-and-push-by-using-gitlab-cicd).

### Build and push by using Docker commands

To build and push to the Container Registry, you can use Docker commands.

#### Authenticate with the Container Registry

If the project is not public, you must authenticate with the Container Registry
before you can build and push images.

Only members of the project can access a project's Container Registry.

To authenticate, you can use:

- A [personal access token](../../profile/personal_access_tokens.md).
- A [deploy token](../../project/deploy_tokens/index.md).

Both of these require the minimum scope to be:

- For read (pull) access, `read_registry`.
- For write (push) access, `write_registry`.

To authenticate, run the `docker` command. For example:

   ```shell
   docker login registry.example.com -u <username> -p <token>
   ```

#### Build and push images

To build and push to the Container Registry:

1. Authenticate with the Container Registry. 

1. Run the command to build or push. For example, to build: 

   ```shell
   docker build -t registry.example.com/group/project/image .
   ```

   Or to push:

   ```shell
   docker push registry.example.com/group/project/image
   ```

You can also view these commands by going to your project's **Packages & Registries > Container Registry**.

NOTE: **Note:**
There is a soft (10GB) size restriction for the Container Registry on GitLab.com,
as part of the [repository size limit](../../project/repository/index.md).

### Build and push by using GitLab CI/CD

To build and push images to the Container Registry, you can use use [GitLab CI/CD](../../../ci/yaml/README.md).
Use it to create workflows and automate processes that involve testing, building,
and deploying your project from the Docker image you created.

#### Authenticate by using GitLab CI/CD

If the project is not public, you must authenticate with the Container Registry.
Only members of the project can access a project's Container Registry.

To use CI/CD to authenticate, you can use:

- The `CI_REGISTRY_USER` variable.

  This variable has read-write access to the Container Registry and is valid for
  one job only. Its password is also automatically created and assigned to `CI_REGISTRY_PASSWORD`.

  ```shell
  docker login -u $CI_REGISTRY_USER -p $CI_REGISTRY_PASSWORD $CI_REGISTRY
  ```

- A [CI job token](../../../ci/triggers/README.md#ci-job-token).

  Replace the `<username>` and `<access_token>` in the following example:

  ```shell
  docker login -u <username> -p <access_token> $CI_REGISTRY
  ```

- A [personal access token](../../profile/personal_access_tokens.md) or
  [deploy token](../../project/deploy_tokens/index.md#gitlab-deploy-token) with the minimum scope of:
  - For read (pull) access, `read_registry`.
  - For write (push) access, `write_registry`.

  ```shell
  docker login -u $CI_DEPLOY_USER -p $CI_DEPLOY_PASSWORD $CI_REGISTRY
  ```

#### Configure your `.gitlab-ci.yml` file

You can configure your `.gitlab-ci.yml` file to build and push images to the Container Registry.

- If multiple jobs require authentication, put the authentication command in the `before_script`.
- Before building, use `docker build --pull` to fetch changes to base images. It takes slightly
  longer, but it ensures your image is up-to-date.
- Before each `docker run`, do an explicit `docker pull` to fetch
  the image that was just built. This is especially important if you are
  using multiple runners that cache images locally.   

  If you use the Git SHA in your image tag, each job is unique and you
  should never have a stale image. However, it's still possible to have a
  stale image if you re-build a given commit after a dependency has changed.
- Don't build directly to the `latest` tag because multiple jobs may be
  happening simultaneously.

#### CI/CD example with Docker-in-Docker

If you're using Docker-in-Docker on your runners, follow this `.gitlab-ci.yml`
example:

```yaml
build:
  image: docker:19.03.12
  stage: build
  services:
    - docker:19.03.12-dind
  script:
    - docker login -u $CI_REGISTRY_USER -p $CI_REGISTRY_PASSWORD $CI_REGISTRY
    - docker build -t $CI_REGISTRY/namespace/project/image:latest .
    - docker push $CI_REGISTRY/namespace/project/image:latest
```

<hr>

Steve--This was pasted from a topic below. That topic was also about docker-in-docker.
Can you help me combine them, if possible?

1. Update the `image` and `service` to point to your registry.
1. Add a service [alias](../../../ci/yaml/README.md#servicesalias).

   For example:

   ```yaml
   build:
     image: $CI_REGISTRY/namespace/project/docker:19.03.12
     services:
       - name: $CI_REGISTRY/namespace/project/docker:19.03.12-dind
         alias: docker
     stage: build
     script:
       - docker build -t my-docker-image .
       - docker run my-docker-image /script/to/run/tests
   ```

If you do not set the service alias, the `docker:19.03.12` image is unable to find the
`dind` service, and an error occurs:

```plaintext
error during connect: Get http://docker:2376/v1.39/info: dial tcp: lookup docker on 192.168.0.1:53: no such host
```

<hr>

You can also use [other variables](../../../ci/variables/README.md) to avoid hard-coding:

```yaml
build:
  image: docker:19.03.12
  stage: build
  services:
    - docker:19.03.12-dind
  variables:
    IMAGE_TAG: $CI_REGISTRY_IMAGE:$CI_COMMIT_REF_SLUG
  script:
    - docker login -u $CI_REGISTRY_USER -p $CI_REGISTRY_PASSWORD $CI_REGISTRY
    - docker build -t $IMAGE_TAG .
    - docker push $IMAGE_TAG
```

Here, `$CI_REGISTRY_IMAGE` is resolved to the address of the Container Registry for this project.
Because `$CI_COMMIT_REF_NAME` resolves to the branch or tag name,
and your branch name can contain forward slashes (for example, `feature/my-feature`), it is
safer to use `$CI_COMMIT_REF_SLUG` as the image tag. This is because image tags
cannot contain forward slashes. We also declare our own variable, `$IMAGE_TAG`.
Combining the two values saves additional lines in the `script` section.

#### CI/CD example with parallel tests

This example splits the tasks into four pipeline stages,
including two tests that run in parallel. The `build` is stored in the container
registry and used by subsequent stages, downloading the image
when needed. Changes to `master` also get tagged as `latest` and deployed using
an application-specific deploy script:

```yaml
image: docker:19.03.12
services:
  - docker:19.03.12-dind

stages:
  - build
  - test
  - release
  - deploy

variables:
  # Use TLS https://docs.gitlab.com/ee/ci/docker/using_docker_build.html#tls-enabled
  DOCKER_HOST: tcp://docker:2376
  DOCKER_TLS_CERTDIR: "/certs"
  CONTAINER_TEST_IMAGE: $CI_REGISTRY_IMAGE:$CI_COMMIT_REF_SLUG
  CONTAINER_RELEASE_IMAGE: $CI_REGISTRY_IMAGE:latest

before_script:
  - docker login -u $CI_REGISTRY_USER -p $CI_REGISTRY_PASSWORD $CI_REGISTRY

build:
  stage: build
  script:
    - docker build --pull -t $CONTAINER_TEST_IMAGE .
    - docker push $CONTAINER_TEST_IMAGE

test1:
  stage: test
  script:
    - docker pull $CONTAINER_TEST_IMAGE
    - docker run $CONTAINER_TEST_IMAGE /script/to/run/tests

test2:
  stage: test
  script:
    - docker pull $CONTAINER_TEST_IMAGE
    - docker run $CONTAINER_TEST_IMAGE /script/to/run/another/test

release-image:
  stage: release
  script:
    - docker pull $CONTAINER_TEST_IMAGE
    - docker tag $CONTAINER_TEST_IMAGE $CONTAINER_RELEASE_IMAGE
    - docker push $CONTAINER_RELEASE_IMAGE
  only:
    - master

deploy:
  stage: deploy
  script:
    - ./deploy.sh
  only:
    - master
```

This example explicitly calls `docker pull`. If you prefer to implicitly pull the
built image using `image:`, and use either the [Docker](https://docs.gitlab.com/runner/executors/docker.html)
or [Kubernetes](https://docs.gitlab.com/runner/executors/kubernetes.html) executor,
make sure that [`pull_policy`](https://docs.gitlab.com/runner/executors/docker.html#how-pull-policies-work)
is set to `always`.

## Delete images

You can delete images from your Container Registry in multiple ways.

CAUTION: **Warning:**
Deleting images is a destructive action and can't be undone. To restore
a deleted image, you must rebuild and re-upload it.

NOTE: **Note:**
Administrators should review how to
[garbage collect](../../../administration/packages/container_registry.md#container-registry-garbage-collection)
the deleted images.

### Delete images from within GitLab

To delete images from within GitLab:

1. Navigate to your project's or group's **Packages & Registries > Container Registry**.
1. From the **Container Registry** page, you can select what you want to delete,
   by either:

   - Deleting the entire repository, and all the tags it contains, by clicking
     the red **{remove}** **Trash** icon.
   - Navigating to the repository, and deleting tags individually or in bulk
     by clicking the red **{remove}** **Trash** icon next to the tag you want
     to delete.

1. In the dialog box, click **Remove tag**.

### Delete images using the API

If you want to automate the process of deleting images, GitLab provides an API. For more
information, see the following endpoints:

- [Delete a Registry repository](../../../api/container_registry.md#delete-registry-repository)
- [Delete an individual Registry repository tag](../../../api/container_registry.md#delete-a-registry-repository-tag)
- [Delete Registry repository tags in bulk](../../../api/container_registry.md#delete-registry-repository-tags-in-bulk)

### Delete images using GitLab CI/CD

CAUTION: **Warning:**
GitLab CI/CD doesn't provide a built-in way to remove your images, but this example
uses a third-party tool called [reg](https://github.com/genuinetools/reg)
that talks to the GitLab Registry API. You are responsible for your own actions.
For assistance with this tool, see
[the issue queue for reg](https://github.com/genuinetools/reg/issues).

The following example defines two stages: `build`, and `clean`. The
`build_image` job builds the Docker image for the branch, and the
`delete_image` job deletes it. The `reg` executable is downloaded and used to
remove the image matching the `$CI_PROJECT_PATH:$CI_COMMIT_REF_SLUG`
[environment variable](../../../ci/variables/predefined_variables.md).

To use this example, change the `IMAGE_TAG` variable to match your needs:

```yaml
stages:
  - build
  - clean

build_image:
  image: docker:19.03.12
  stage: build
  services:
    - docker:19.03.12-dind
  variables:
    IMAGE_TAG: $CI_REGISTRY_IMAGE:$CI_COMMIT_REF_SLUG
  script:
    - docker login -u $CI_REGISTRY_USER -p $CI_REGISTRY_PASSWORD $CI_REGISTRY
    - docker build -t $IMAGE_TAG .
    - docker push $IMAGE_TAG
  only:
    - branches
  except:
    - master

delete_image:
  image: docker:19.03.12
  stage: clean
  services:
    - docker:19.03.12-dind
  variables:
    IMAGE_TAG: $CI_PROJECT_PATH:$CI_COMMIT_REF_SLUG
    REG_SHA256: ade837fc5224acd8c34732bf54a94f579b47851cc6a7fd5899a98386b782e228
    REG_VERSION: 0.16.1
  before_script:
    - apk add --no-cache curl
    - curl --fail --show-error --location "https://github.com/genuinetools/reg/releases/download/v$REG_VERSION/reg-linux-amd64" --output /usr/local/bin/reg
    - echo "$REG_SHA256  /usr/local/bin/reg" | sha256sum -c -
    - chmod a+x /usr/local/bin/reg
  script:
    - /usr/local/bin/reg rm -d --auth-url $CI_REGISTRY -u $CI_REGISTRY_USER -p $CI_REGISTRY_PASSWORD $IMAGE_TAG
  only:
    - branches
  except:
    - master
```

TIP: **Tip:**
You can download the latest `reg` release from
[the releases page](https://github.com/genuinetools/reg/releases), then update
the code example by changing the `REG_SHA256` and `REG_VERSION` variables
defined in the `delete_image` job.

### Delete images by using a cleanup policy

You can create a per-project [cleanup policy](#cleanup-policy) to ensure older tags and images are regularly removed from the
Container Registry.

## Cleanup policy

> - [Introduced](https://gitlab.com/gitlab-org/gitlab/-/issues/15398) in GitLab 12.8.
> - [Renamed](https://gitlab.com/gitlab-org/gitlab/-/issues/218737) from "expiration policy" to "cleanup policy" in GitLab 13.2.

The cleanup policy is a scheduled job you can use to remove tags from the Container Registry.
For the project where it's defined, tags matching the regex pattern are removed.
The underlying layers and images remain.

To delete the underlying layers and images that aren't associated with any tags, administrators can use
[garbage collection](../../../administration/packages/container_registry.md#removing-unused-layers-not-referenced-by-manifests) with the `-m` switch.

### Enable the cleanup policy

Cleanup policies can be run on all projects, with these exceptions:

- For GitLab.com, the project must have been created after 2020-02-22.
  Support for projects created earlier
  [is planned](https://gitlab.com/gitlab-org/gitlab/-/issues/196124).
- For self-managed GitLab instances, the project must have been created
  in GitLab 12.8 or later. However, an administrator can enable the cleanup policy
  for all projects (even those created before 12.8) in
  [GitLab application settings](../../../api/settings.md#change-application-settings)
  by setting `container_expiration_policies_enable_historic_entries` to true.
  Alternatively, you can execute the following command in the [Rails console](../../../administration/troubleshooting/navigating_gitlab_via_rails_console.md#starting-a-rails-console-session):

  ```ruby
  ApplicationSetting.last.update(container_expiration_policies_enable_historic_entries: true)
  ```

  There are performance risks with enabling it for all projects, especially if you
  are using an [external registry](./index.md#use-with-external-container-registries).

### How the cleanup policy works

The cleanup policy collects all tags in the Container Registry and excludes tags
until only the tags to be deleted remain.

The cleanup policy:

1. Collects all tags for a given repository in a list.
1. Excludes the tag named `latest` from the list.
1. Evaluates the `name_regex` (tags to expire), excluding non-matching names from the list.
1. Excludes any tags that do not have a manifest (not part of the options in the UI).
1. Orders the remaining tags by `created_date`.
1. Excludes from the list the N tags based on the `keep_n` value (Number of tags to retain).
1. Excludes from the list the tags more recent than the `older_than` value (Expiration interval).
1. Excludes from the list any tags matching the `name_regex_keep` value (tags to preserve).
1. Finally, the remaining tags in the list are deleted from the Container Registry.

CAUTION: **Warning:**
On GitLab.com, the execution time for the cleanup policy is limited, and some of the tags may remain in
the Container Registry after the policy runs. The next time the policy runs, the remaining tags are included,
so it may take multiple runs for all tags to be deleted.

### Create a cleanup policy

You can create a cleanup policy in [the API](#use-the-cleanup-policy-api) or the UI.

To create a cleanup policy in the UI:

1. For your project, go to **Settings > CI/CD**.
1. Expand the **Cleanup policy for tags** section.
1. Complete the fields.

   | Field                                                                     | Description                                                                                                       |
   |---------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------------------------|
   | **Cleanup policy**                                                        | Turn the policy on or off.                                                                                        |
   | **Expiration interval**                                                   | How long tags are exempt from being deleted.                                                                      |
   | **Expiration schedule**                                                   | How often the policy should run.                                                                                  |
   | **Number of tags to retain**                                              | How many tags to _always_ keep for each image.                                                                    |
   | **Tags with names matching this regex pattern expire:**              | The regex pattern that determines which tags to remove. For all tags, use `.*`. See other [regex pattern examples](#regex-pattern-examples). |
   | **Tags with names matching this regex pattern are preserved:**        | The regex pattern that determines which tags to preserve. The `latest` tag is always preserved. For all tags, use `.*`. See other [regex pattern examples](#regex-pattern-examples). |

1. Click **Set cleanup policy**.

Depending on the interval you chose, the policy is scheduled to run.

NOTE: **Note:**
If you edit the policy and click **Set cleanup policy** again, the interval is reset.

### Regex pattern examples

Cleanup policies use regex patterns to determine which tags should be preserved or removed, both in the UI and the API.

Here are examples of regex patterns you may want to use:

- Match all tags:

  ```plaintext
  .*
  ```

- Match tags that start with `v`:

  ```plaintext
  v.+
  ```

- Match tags that contain `master`:

  ```plaintext
  master
  ```

- Match tags that either start with `v`, contain `master`, or contain `release`:

  ```plaintext
  (?:v.+|master|release)
  ```

### Use the cleanup policy API

You can set, update, and disable the cleanup policies using the GitLab API.

Examples:

- Select all tags, keep at least 1 tag per image, clean up any tag older than 14 days, run once a month, preserve any images with the name `master` and the policy is enabled:

  ```shell
  curl --request PUT --header 'Content-Type: application/json;charset=UTF-8' --header "PRIVATE-TOKEN: <your_access_token>" --data-binary '{"container_expiration_policy_attributes":{"cadence":"1month","enabled":true,"keep_n":1,"older_than":"14d","name_regex":"","name_regex_delete":".*","name_regex_keep":".*-master"}}' 'https://gitlab.example.com/api/v4/projects/2'
  ```

See the API documentation for further details: [Edit project](../../../api/projects.md#edit-project).

### Use with external container registries

When using an [external container registry](./../../../administration/packages/container_registry.md#use-an-external-container-registry-with-gitlab-as-an-auth-endpoint),
running a cleanup policy on a project may have some performance risks.
If a project runs a policy to remove thousands of tags
the GitLab background jobs may get backed up or fail completely.
It is recommended you only enable container cleanup
policies for projects that were created before GitLab 12.8 if you are confident the number of tags
being cleaned up is minimal.

### Troubleshooting cleanup policies

If you see the following message:

"Something went wrong while updating the cleanup policy."

Check the regex patterns to ensure they are valid.

You can use [Rubular](https://rubular.com/) to check your regex.
View some common [regex pattern examples](#regex-pattern-examples).

## Use the Container Registry to store Helm Charts

With the launch of [Helm v3](https://helm.sh/docs/topics/registries/),
you can use the Container Registry to store Helm Charts. However, due to the way metadata is passed
and stored by Docker, it is not possible for GitLab to parse this data and meet performance standards.
[This epic](https://gitlab.com/groups/gitlab-org/-/epics/2313) updates the architecture of the Container Registry to support Helm Charts.

[Read more about the above challenges](https://gitlab.com/gitlab-org/gitlab/-/issues/38047#note_298842890).

## Limitations

- Moving or renaming existing Container Registry repositories is not supported
once you have pushed images, because the images are signed, and the
signature includes the repository name. To move or rename a repository with a
Container Registry, you must delete all existing images.
- Prior to GitLab 12.10, any tags that use the same image ID as the `latest` tag
are not deleted by the cleanup policy.

## Disable the Container Registry for a project

The Container Registry is enabled by default. 

You can, however, remove the Container Registry for a project:

1. Go to your project's **Settings > General** page.
1. Expand the **Visibility, project features, permissions** section
   and disable **Container Registry**.
1. Click **Save changes**.

The **Packages & Registries > Container Registry** entry is removed from the project's sidebar.

## Troubleshooting the GitLab Container Registry

### Docker connection error

A Docker connection error can occur when there are special characters in either the group,
project or branch name. Special characters can include:

- Leading underscore
- Trailing hyphen/dash

To get around this, you can [change the group path](../../group/index.md#changing-a-groups-path),
[change the project path](../../project/settings/index.md#renaming-a-repository) or change the branch
name.

You may also get a `404 Not Found` or `Unknown Manifest` message if you are using
a Docker Engine version earlier than 17.12. Later versions of Docker Engine use
[the v2 API](https://docs.docker.com/registry/spec/manifest-v2-2/).

The images in your GitLab Container Registry must also use the Docker v2 API.
For information on how to update your images, see the [Docker help](https://docs.docker.com/registry/spec/deprecated-schema-v1).

### Troubleshoot as a GitLab server admin

Troubleshooting the GitLab Container Registry, most of the times, requires
administrator access to the GitLab server.

[Read how to troubleshoot the Container Registry](../../../administration/packages/container_registry.md#troubleshooting).

### Unable to change path or transfer a project

If you try to change a project's path or transfer a project to a new namespace,
you may receive one of the following errors:

- "Project cannot be transferred, because tags are present in its container registry."
- "Namespace cannot be moved because at least one project has tags in container registry."

This issue occurs when the project has images in the Container Registry.
You must delete or move these images before you can change the path or transfer
the project.

The following procedure uses these sample project names:

- For the current project: `gitlab.example.com/org/build/sample_project/cr:v2.9.1`
- For the new project: `gitlab.example.com/new_org/build/new_sample_project/cr:v2.9.1`

Use your own URLs to complete the following steps:

1. Download the Docker images on your computer:

   ```shell
   docker login gitlab.example.com
   docker pull gitlab.example.com/org/build/sample_project/cr:v2.9.1
   ```

1. Rename the images to match the new project name:

   ```shell
   docker tag gitlab.example.com/org/build/sample_project/cr:v2.9.1 gitlab.example.com/new_org/build/new_sample_project/cr:v2.9.1
   ```

1. Delete the images in both projects by using the [UI](#delete-images) or [API](../../../api/packages.md#delete-a-project-package).
   There may be a delay while the images are queued and deleted.
1. Change the path or transfer the project by going to **Settings > General**
   and expanding **Advanced**.
1. Restore the images:

   ```shell
   docker push gitlab.example.com/new_org/build/new_sample_project/cr:v2.9.1
   ```

Follow [this issue](https://gitlab.com/gitlab-org/gitlab/-/issues/18383) for details.
