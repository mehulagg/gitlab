---
stage: Configure
group: Configure
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#designated-technical-writers
---

# Kubernetes Agent repository overview **(PREMIUM ONLY)**

## `build`

Various files for the build process.

### `build/deployment`

A [`kpt`](https://googlecontainertools.github.io/kpt/) package that bundles some [Kustomize](https://kustomize.io/) layers and components. Can be used as is or to create a custom package to install `agentk`.

## `cmd`

Commands - binaries that this repository produces. They are:

- `kas` is the GitLab Kubernetes Agent Server binary.
- `agentk` is the GitLab Kubernetes Agent binary.

Each of these directories contain application bootstrap code for reading configuration, applying defaults to it, constructing the dependency graph of objects that constitute the program, and finally running it.

## `examples`

Git submodules for the example projects.

## `internal`

The main code of both `gitlab-kas` and `agentk` as well as various supporting building blocks.

### `internal/agentk`

Main `agentk` logic, including the API implementation for agent modules.

### `internal/api`

Structs that represent some important pieces of data.

### `internal/gitaly`

Stuff to work with Gitaly.

### `internal/gitlab`

GitLab REST client.

### `internal/kas`

API implementation for the server modules. Nothing else at the moment as all of the server logic is split into server modules. The bootstrapping "glue" that wires the modules together lives in `cmd/kas/kasapp`.

### `internal/module`

Modules that implement server and agent-side functionality. See [documentation on modules](TODO) for more information. 

### `internal/tool`

Various building blocks. `internal/tool/testing` contains mocks and helpers for testing. [`gomock`](https://pkg.go.dev/github.com/golang/mock) is used to generate mocks.

## `it`

Contains scaffolding for integration tests. Unused at the moment.

## `pkg`

Contains exported packages.

### `pkg/agentcfg`

Contains protobuf definitions of the `agentk` configuration file. This is what you can 

### `pkg/kascfg`

Contains protobuf definitions of the `gitlab-kas` configuration file. There is also an example of that configuration file along with the test for it. The test ensures that the configuration file example is in sync with the protobuf definitions of the file and defaults, that are applied when the file is loaded.
