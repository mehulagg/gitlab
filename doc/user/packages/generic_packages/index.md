---
stage: Package
group: Package
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#designated-technical-writers
---

# GitLab Generic Packages Repository **CORE**

> - [Introduced](https://gitlab.com/groups/gitlab-org/-/epics/4209) in GitLab 13.5.
> - It's [deployed behind a feature flag](../../../user/feature_flags.md), disabled by default.
> - It's disabled on GitLab.com.
> - It's able to be enabled or disabled per-project.
> - It's not recommended for production use.
> - To use it in GitLab self-managed instances, ask a GitLab administrator to [enable it](#enable-or-disable-generic-packages-registry).

CAUTION: **Warning:**
This feature might not be available to you. Check the **version history** note above for details.

With the GitLab Generic Packages Repository every project can have its own space to store arbitrary files, like for example release binaries.

## Enabling the Generic Packages Repository

NOTE: **Note:**
This option is available only if your GitLab administrator has
[enabled support for the Package Registry](../../../administration/packages/index.md).

After the Generic Packages Repository is enabled, it is available for all new projects
by default. To enable it for existing projects, or if you want to disable it:

1. Navigate to your project's **Settings > General > Visibility, project features, permissions**.
1. Find the Packages feature and enable or disable it.
1. Click on **Save changes** for the changes to take effect.

You should then be able to see the **Packages & Registries** section on the left sidebar.

## Authentication

Generic Packages API supports authentication with [personal access token](../../../api/README.md#personalproject-access-tokens)
and [GitLab CI job token](../../../api/README.md#gitlab-ci-job-token).

## Upload package file

Upload package file. If the package does not exist it will be created. You need API access to create package and upload package file.

```plaintext
PUT /projects/:id/packages/generic/:package_name/:package_version/:file_name
```

| Attribute          | Type            | Required | Description                                                                                                                      |
| -------------------| --------------- | ---------| -------------------------------------------------------------------------------------------------------------------------------- |
| `id`               | integer/string  | yes      | The ID or [URL-encoded path of the project](../README.md#namespaced-path-encoding).                                              |
| `package_name`     | string          | yes      | The package name. It can contain only lowercase letters (`a-z`), uppercase letter (`A-Z`), numbers (`0-9`), dots (`.`), hyphens (`-`), or underscores (`_`).
| `package_version`  | string          | yes      | The package version. It can contain only numbers (`0-9`), and dots (`.`). Must be in the format of `X.Y.Z`, i.e. should match `/\A\d+\.\d+\.\d+\z/` regular expresion.
| `file_name`        | string          | yes      | The file name. It can contain only lowercase letters (`a-z`), uppercase letter (`A-Z`), numbers (`0-9`), dots (`.`), hyphens (`-`), or underscores (`_`).

The file context should be provided in the request body.

Example request:

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
     --upload-file path/to/file.txt \
     https://gitlab.example.com/api/v4/projects/24/generic/my_package/0.0.1/file.txt
```

Example response:

```json
{
  "message":"201 Created"
}
```

## Download package file

Download package file. You need API access to download package file.

```plaintext
GET /projects/:id/packages/generic/:package_name/:package_version/:file_name
```

| Attribute          | Type            | Required | Description                                                                         |
| -------------------| --------------- | ---------| ------------------------------------------------------------------------------------|
| `id`               | integer/string  | yes      | The ID or [URL-encoded path of the project](../README.md#namespaced-path-encoding). |
| `package_name`     | string          | yes      | The package name.                                                                   |
| `package_version`  | string          | yes      | The package version.                                                                |
| `file_name`        | string          | yes      | The file name.                                                                      |

The file context will be served in the response body, response content type will be `application/octet-stream`.

Example request using personal access token:

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
     https://gitlab.example.com/api/v4/projects/24/generic/my_package/0.0.1/file.txt
```

## Using GitLab CI with Generic Packages Repository

To work with Generic Packages within [GitLab CI/CD](./../../../ci/README.md), you can use
`CI_JOB_TOKEN` in place of the personal access token in your commands.

For example:

```yaml
image: curlimages/curl:latest

stages:
  - upload
  - download

upload:
  stage: upload
  script:
    - 'curl --header "JOB-TOKEN: $CI_JOB_TOKEN" --upload-file path/to/file.txt ${CI_API_V4_URL}/projects/${CI_PROJECT_ID}/packages/generic/my_package/0.0.1/file.txt'

download:
  stage: download
  script:
    - 'wget --header="JOB-TOKEN: $CI_JOB_TOKEN" ${CI_API_V4_URL}/projects/${CI_PROJECT_ID}/packages/generic/my_package/0.0.1/file.txt'
```
### Enable or disable Generic Packages Registry

Generic Packages is under development and not ready for production use. It is
deployed behind a feature flag that is **disabled by default**.
[GitLab administrators with access to the GitLab Rails console](../../../administration/feature_flags.md)
can enable it.

To enable it:

```ruby
# For the instance
Feature.enable(:generic_packages)
# For a single project
Feature.enable(:generic_packages, Project.find(<project id>))
```

To disable it:

```ruby
# For the instance
Feature.disable(:generic_packages)
# For a single project
Feature.disable(:generic_packages, Project.find(<project id>))
```
