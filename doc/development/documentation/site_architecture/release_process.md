---
stage: none
group: unassigned
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#assignments
---

# Monthly release process

When a new GitLab version is released on the 22nd, we need to release the published documentation
for the new version.

This should be done as soon as possible after the GitLab version is announced, so that:

- The published documentation reflects that the new GitLab version is available. For example, that
  there is a specific set of GitLab 13.9 documentation.
- The documentation being developed after the 22nd is for the next version. For example, that the
  documentation in development is regarded as GitLab `13.10-pre`.

Each documentation release:

- Is branched.
- Has a Docker image that contains a build of that branch.

For example:

- For [GitLab 13.9](https://docs.gitlab.com/13.9/index.html), the
  [stable branch](https://gitlab.com/gitlab-org/gitlab-docs/-/tree/13.9) and Docker image:
  [`registry.gitlab.com/gitlab-org/gitlab-docs:13.9`](https://gitlab.com/gitlab-org/gitlab-docs/container_registry/631635).
- For [GitLab 13.8](https://docs.gitlab.com/13.8/index.html), the
  [stable branch](https://gitlab.com/gitlab-org/gitlab-docs/-/tree/13.8) and Docker image:
  [`registry.gitlab.com/gitlab-org/gitlab-docs:13.8`](https://gitlab.com/gitlab-org/gitlab-docs/container_registry/631635).
- For [GitLab 13.7](https://docs.gitlab.com/13.7/index.html), the
  [stable branch](https://gitlab.com/gitlab-org/gitlab-docs/-/tree/13.7) and Docker image:
  [`registry.gitlab.com/gitlab-org/gitlab-docs:13.7`](https://gitlab.com/gitlab-org/gitlab-docs/container_registry/631635).

Releasing documentation involves:

1. [Adding the charts version](#add-chart-version), so that the documentation is built using the
   [version of the charts project that coincides](https://docs.gitlab.com/charts/installation/version_mappings.html)
   with the GitLab release. This step may have been completed already.
1. [Creating a stable branch and Docker image](#create-stable-branch-and-docker-image-for-release) for the new version.
1. [Creating a release merge request](#create-release-merge-request) for the new version, which
   updates the version dropdown menu for the current documentation and adds the release to the
   Docker configuration. For example, the
   [release merge request for 13.9](https://gitlab.com/gitlab-org/gitlab-docs/-/merge_requests/1555).
1. [Updating the three online versions](#update-dropdown-for-online-versions), so that they display the new release on their
   version dropdown menus. For example:
   - The merge request to [update the 13.9 version dropdown menu for the 13.9 release](https://gitlab.com/gitlab-org/gitlab-docs/-/merge_requests/1556).
   - The merge request to [update the 13.8 version dropdown menu for the 13.9 release](https://gitlab.com/gitlab-org/gitlab-docs/-/merge_requests/1557).
   - The merge request to [update the 13.7 version dropdown menu for the 13.9 release](https://gitlab.com/gitlab-org/gitlab-docs/-/merge_requests/1558).
1. [Merging the release merge request and run the necessary Docker image builds](#merge-release-merge-request-and-run-docker-image-builds).

## Add chart version

To add a new charts version for the release:

1. Make sure you're in the root path of the `gitlab-docs` repository.
1. Open `content/_data/chart_versions.yaml` and add the new stable branch version using the
   [version mapping]((https://docs.gitlab.com/charts/installation/version_mappings.html)). Only the
   `major.minor` version is needed.
1. Create a new merge request and merge it.

NOTE:
It can be handy to create the future mappings since they are pretty much known. In that case, when a
new GitLab version is released, you don't have to repeat this first step.

## Create stable branch and Docker image for release

To create a stable branch and Docker image for the release:

1. Make sure you're in the root path of the `gitlab-docs` repository.
1. Run the Rake task to create the single version. For example, to cut the 13.9 release:

   ```shell
   ./bin/rake "release:single[13.9]"
   ```

    A branch for the release is created, a new `Dockerfile.13.9` is created, and `.gitlab-ci.yml`
    has branches variables updated into a new branch. These files are automatically committed.

1. Push the newly created branch, but **don't create a merge request**. After you push, the
   `image:docs-single` job creates a new Docker image tagged with the name of the branch you created
   earlier.

The branch pipeline is uploads the Docker image and it is listed in the `registry` environment
folder at <https://gitlab.com/gitlab-org/gitlab-docs/-/environments/folders/registry>. For example,
the [branch pipeline](https://gitlab.com/gitlab-org/gitlab-docs/-/pipelines/260288747) for GitLab
13.9 documentation.

Optionally, you can test locally by:

1. Building the image and running it. For example, for GitLab 13.9 documentation:

   ```shell
   docker build -t docs:12.0 -f Dockerfile.13.9 .
   docker run -it --rm -p 4000:4000 docs:13.9
   ```

1. Visiting <http://localhost:4000/13.9/> to see if everything works correctly.

## Create release merge request

To create the release merge request for the release:

1. Make sure you're in the root path of the `gitlab-docs` repository.
1. Create a branch `release-X-Y`. For example:

   ```shell
   git checkout master
   git checkout -b release-13-9
   ```

1. Edit `content/_data/versions.yaml` and rotate the versions to reflect the new changes:

   - `online`: The 3 latest stable versions.
   - `offline`: All the previous versions offered as an offline archive.

1. Update the `:latest` and `:archives` Docker images:

   The following two Dockerfiles must be updated:

   1. `dockerfiles/Dockerfile.archives` - Add the latest version at the top of the list.
   1. `Dockerfile.master` - Rotate the versions (oldest gets removed and latest is added at the top
      of the list).

1. Commit and push to create the merge request. For example:

   ```shell
   git add content/ Dockerfile.master dockerfiles/Dockerfile.archives
   git commit -m "Release 13.9"
   git push origin release-13-9
   ```

Do not merge the release merge request yet.

NOTE:
This step is to be [automated](https://gitlab.com/gitlab-org/gitlab-docs/-/issues/750).

## Update dropdown for online versions

To update`content/_data/versions.yaml` for all online versions (stable branches `X.Y` of the
`gitlab-docs` project):

1. Run the Rake task that creates all of the necessary merge requests to update the dropdowns. For
   example, for the 13.9 release:

   ```shell
   git checkout release-13-9
   ./bin/rake release:dropdowns
   ```

   These merge requests are set to automatically merge.

1. [Visit the merge requests page](https://gitlab.com/gitlab-org/gitlab-docs/-/merge_requests?label_name%5B%5D=release)
   to check that their pipelines pass, and once all are merged, proceed to the following and final
   step.

## Merge release merge request and run Docker image builds

The dropdown merge requests should now be merged into their respective stable branches, which
triggers another pipeline. At this point, you need to only wait for the pipelines the pipelines and
make sure they don't fail:

1. Check the [pipelines page](https://gitlab.com/gitlab-org/gitlab-docs/pipelines)
   and make sure all stable branches have green pipelines.
1. After all the pipelines of the online versions succeed, merge the
   [release merge request](#create-release-merge-request).
1. Finally, run the
   [`Build docker images weekly` pipeline](https://gitlab.com/gitlab-org/gitlab-docs/pipeline_schedules)
   that builds the `:latest` and `:archives` Docker images.

Once the scheduled pipeline succeeds, the docs site is deployed with all new versions online.
