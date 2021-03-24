---
stage: Package
group: Package
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#assignments
---

# Conan API

This is the API documentation for [Conan Packages](../user/packages/conan_repository/index.md).

This API is used by the [Conan package manager client](https://docs.conan.io/en/latest/)
and is generally not meant for manual consumption.

## Instance Level Routes

### Ping

> Introduced in GitLab 12.2.

Ping the GitLab Conan repository to verify availability

```plaintext
GET /packages/conan/v1/ping
```

```shell
curl "https://gitlab.example.com/api/v4/packages/conan/v1/ping"
```

Example response:

```json
""
```

### Search

> Introduced in GitLab 12.4.

Search the instance for Conan packages by name

```plaintext
GET /packages/conan/v1/conans/search
```

| Attribute | Type | Required | Description |
| --------- | ---- | -------- | ----------- |
| `q`       | string | yes | Search query. `*` can be used as a wildcard |

```shell
curl -u <username>:<personal_access_token> "https://gitlab.example.com/api/v4/packages/conan/v1/conans/search?q=Hello*"
```

Example response:

```json
{
  "results": [
    "Hello/0.1@foo+conan_test_prod/beta",
    "Hello/0.1@foo+conan_test_prod/stable",
    "Hello/0.2@foo+conan_test_prod/beta",
    "Hello/0.3@foo+conan_test_prod/beta",
    "Hello/0.1@foo+conan-reference-test/stable",
    "HelloWorld/0.1@baz+conan-reference-test/beta"
    "hello-world/0.4@buz+conan-test/alpha"
  ]
}
```

### Authenticate

> [Introduced](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/9667) in GitLab 12.2.

Returns a JWT to be used for Conan requests in a Bearer header:

```shell
"Authorization: Bearer <token>
```

This token is automatically used by the
Conan package manager client.

```plaintext
GET /packages/conan/v1/users/authenticate
```

```shell
curl -u <username>:<personal_access_token> "https://gitlab.example.com/packages/conan/v1/users/authenticate
```

Example response:

```shell
eyJhbGciOiJIUzI1NiIiheR5cCI6IkpXVCJ9.eyJhY2Nlc3NfdG9rZW4iOjMyMTQyMzAsqaVzZXJfaWQiOjQwNTkyNTQsImp0aSI6IjdlNzBiZTNjLWFlNWQtNDEyOC1hMmIyLWZiOThhZWM0MWM2OSIsImlhd3r1MTYxNjYyMzQzNSwibmJmIjoxNjE2NjIzNDMwLCJleHAiOjE2MTY2MjcwMzV9.QF0Q3ZIB2GW5zNKyMSIe0HIFOITjEsZEioR-27Rtu7E
```

### Check Credentials

> Introduced in GitLab 12.4.

Checks the validity of Basic Auth credentials or a Conan JWT generated from [`/authenticate`](#authenticate).

```plaintext
GET /packages/conan/v1/users/check_credentials
```

```shell
curl --header "Authorization: Bearer <authenticate_token>" "https://gitlab.example.com/api/v4/packages/conan/v1/users/check_credentials
```

Example response:

```shell
ok
```

### Recipe Snapshot

> Introduced in GitLab 12.5.

This returns the snapshot of the recipe files for the specified Conan recipe.

The snapshot is a list of filenames with their associated md5 hash.

```plaintext
GET /packages/conan/v1/conans/:package_name/:package_version/:package_username/:package_channel
```

| Attribute | Type | Required | Description |
| --------- | ---- | -------- | ----------- |
| `package_name`      | string | yes | Name of a package |
| `package_version`   | string | yes | Version of a package |
| `package_username`  | string | yes | Conan username of a package. This is the `+` separated full-path of your project. |
| `package_channel`   | string | yes | Channel of a package |

```shell
curl --header "Authorization: Bearer <authenticate_token>" "https://gitlab.example.com/api/v4/packages/conan/v1/conans/my-package/1.0/my-group+my-project/stable"
```

Example response:

```json
{
  "conan_sources.tgz": "eadf19b33f4c3c7e113faabf26e76277",
  "conanfile.py": "25e55b96a28f81a14ba8e8a8c99eeace",
  "conanmanifest.txt": "5b6fd77a2ba14303ce4cdb08c87e82ab"
}
```

### Package Snapshot

### Recipe Digest

### Package Digest

### Recipe Download URLs

### Package Download URLs

### Recipe Upload URLs

### Package Upload URLs

### Delete a Package

### Download a Recipe file

### Authorize workhorse upload of a Recipe file

### Upload a Recipe file

### Download a Package file

### Authorize workhorse upload of a Package file

### Upload a Package file
