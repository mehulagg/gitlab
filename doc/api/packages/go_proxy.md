---
stage: Package
group: Package
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#assignments
---

# Go Proxy API

This is the API documentation for [Go Packages](../../user/packages/go_proxy/index.md).

This API is behind a feature flag that is _disabled by default_.

[GitLab administrators with access to the GitLab Rails console](../../administration/feature_flags.md)
can enable it for your instance.

WARNING:
This API is used by the [Go client](https://maven.apache.org/)
and is generally not meant for manual consumption.

For instructions on how to work with the Go Proxy, see the [Go Proxy package documentation](../../user/packages/go_proxy/index.md).

NOTE:
These endpoints do not adhere to the standard API authentication methods.
See [Go Proxy package documentation](../../user/packages/go_proxy/index.md)
for details on which headers and token types are supported.

## List

> Introduced in GitLab 13.1.

Get all tagged versions for a given Go module

```plaintext
GET projects/:id/packages/go/:module_name/@v/list
```

| Attribute | Type | Required | Description |
| --------- | ---- | -------- | ----------- |
| `id`       | string | yes | The project ID or full path of a project. |
| `module_name`  | string | yes | The name of the Go module. |

```shell
curl --header "Private-Token: <personal_access_token>" "https://gitlab.example.com/api/v4/projects/1/packages/go/my-go-module/@v/list"
```

## Version metadata

> Introduced in GitLab 13.1.

Get all tagged versions for a given Go module

```plaintext
GET projects/:id/packages/go/:module_name/@v/:module_version.info
```

| Attribute | Type | Required | Description |
| --------- | ---- | -------- | ----------- |
| `id`       | string | yes | The project ID or full path of a project. |
| `module_name`  | string | yes | The name of the Go module. |
| `module_version`  | string | yes | The version of the Go module. |

```shell
curl --header "Private-Token: <personal_access_token>" "https://gitlab.example.com/api/v4/projects/1/packages/go/my-go-module/@v/1.0.0.info"
```

## Download module file

> Introduced in GitLab 13.1.

Fetch the `.mod` module file.

```plaintext
GET projects/:id/packages/go/:module_name/@v/:module_version.mod
```

| Attribute | Type | Required | Description |
| --------- | ---- | -------- | ----------- |
| `id`       | string | yes | The project ID or full path of a project. |
| `module_name`  | string | yes | The name of the Go module. |
| `module_version`  | string | yes | The version of the Go module. |

```shell
curl --header "Private-Token: <personal_access_token>" "https://gitlab.example.com/api/v4/projects/1/packages/go/my-go-module/@v/1.0.0.mod"
```

Write to a file:

```shell
curl --header "Private-Token: <personal_access_token>" "https://gitlab.example.com/api/v4/projects/1/packages/go/my-go-module/@v/1.0.0.mod" >> foo.mod
```

This will write to `foo.mod` in the current directory.

## Download module source

> Introduced in GitLab 13.1.

Fetch the `.zip` of the module source.

```plaintext
GET projects/:id/packages/go/:module_name/@v/:module_version.zip
```

| Attribute | Type | Required | Description |
| --------- | ---- | -------- | ----------- |
| `id`       | string | yes | The project ID or full path of a project. |
| `module_name`  | string | yes | The name of the Go module. |
| `module_version`  | string | yes | The version of the Go module. |

```shell
curl --header "Private-Token: <personal_access_token>" "https://gitlab.example.com/api/v4/projects/1/packages/go/my-go-module/@v/1.0.0.zip"
```

Write to a file:

```shell
curl --header "Private-Token: <personal_access_token>" "https://gitlab.example.com/api/v4/projects/1/packages/go/my-go-module/@v/1.0.0.zip" >> foo.zip
```

This will write to `foo.zip` in the current directory.
