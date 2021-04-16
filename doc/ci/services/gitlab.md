---
stage: Verify
group: Runner
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#assignments
type: reference
---

# Use GitLab as a microservice

Because so many applications depend on accessing JSON APIs, eventually you might need
API access for your tests to run. The following example shows how to access GitLab as
a microservice, so it is accessible for API clients.

1. Configure a [runner](../runners/README.md) with the Docker or Kubernetes executor.
1. In your `.gitlab-ci.yml` add:

   ```yaml
   services:
     - name: gitlab/gitlab-ce:latest
       alias: gitlab

   variables:
     GITLAB_HTTPS: "false"             # ensure that plain http works
     GITLAB_ROOT_PASSWORD: "password"  # to access the api with user root:password
   ```

1. To set values for the `GITLAB_HTTPS`, `GITLAB_ROOT_PASSWORD`,
   [assign them to a variable in the user interface](../variables/README.md#project-cicd-variables).
   Then assign that variable to the corresponding variable in your
   `.gitlab-ci.yml` file.
   
Then, from your the `script:` keyword, the API is available at `http://gitlab/api/v4`.

For more information about why `gitlab` is used for the `Host`, see
[How services are linked to the job](../docker/using_docker_images.md#extended-docker-configuration-options).

You can also use any other Docker image available on [Docker Hub](https://hub.docker.com/u/gitlab).

The `gitlab` image can accept environment variables. For more details,
see the [Omnibus documentation](../../install/README.md).
