---
stage: Verify
group: Continuous Integration
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#assignments
comments: false
type: index
---

# Docker integration

Use GitLab CI/CD with [Docker](https://www.docker.com).

- [Run your CI/CD jobs in a Docker container](using_docker_images.md).

  With GitLab CI/CD, you can create jobs to do things like testing, building, or publishing
  an application. These jobs can run in Docker containers. For example, you can tell 
  GitLab CI/CD to use a Node image that's hosted on Docker Hub or in the GitLab Container Registry.
  When your job runs, it runs in a container that was generated from the image.
  The container has all the Node dependencies you need to build your app.

- [Use GitLab CI/CD to build Docker images](using_docker_build.md).

  You can use GitLab CI/CD to do things like creating Docker images and publishing
  them to a container registry. There are a few different ways to do this.

- [Use GitLab CI/CD to build Docker images with kaniko](using_kaniko.md).

  You can use GitLab CI/CD to do things like creating Docker images and publishing
  them to a container registry. One option for doing this is to use kaniko.
