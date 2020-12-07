---
stage: Configure
group: Configure
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#designated-technical-writers
---

# Kubernetes Agent repository overview **(PREMIUM ONLY)**

## `build`

Contains various files for the build process.

### `build/deployment`

Contains a [Kustomize](https://kustomize.io/) package to install `agentk`.

## `cmd`

Contains commands - binaries that this repository produces. They are:

- `kas` is the GitLab Kubernetes Agent Server binary.
- `agentk` is the GitLab Kubernetes Agent binary.

Each of these directories contain application bootstrap code for reading configuration, applying defaults to it, constructing the dependency graph of objects that constitute the program, and finally running it.

## `examples`

Contains Git submodules to the example projects.

## `internal`

Contains the main code of both `gitlab-kas` and `agentk` as well as various supporting building blocks.

## `it`

Contains scaffolding for integration tests. Unused at the moment.

## `pkg`

Contains exported packages.

### `pkg/agentcfg`

Contains protobuf definitions of the `agentk` configuration file.

### `pkg/kascfg`

Contains protobuf definitions of the `gitlab-kas` configuration file. There is also an example of that configuration file along with the test for it. The test ensures that the configuration file example is in sync with the protobuf definitions of the file and defaults, that are applied when the file is loaded.
