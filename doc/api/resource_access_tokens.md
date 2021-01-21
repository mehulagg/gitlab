---
stage: Manage
group: Access
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#assignments
---

# Resource access tokens API

You can read more about [resource access tokens](../user/project/settings/project_access_tokens.md).

## List resource access tokens

> - [Introduced](https://gitlab.com/gitlab-org/gitlab/-/issues/238991) in GitLab 13.9.

Get a list of resource access tokens.

```plaintext
GET /:id/access_tokens
```

| Attribute | Type    | required | Description         |
|-----------|---------|----------|---------------------|
| `id` | integer/string | yes | The ID of the project or group |

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" "https://gitlab.example.com/api/v4/projects/<project_id>/access_tokens"
```

```json
[
   {
      "user_id" : 141,
      "scopes" : [
         "api"
      ],
      "name" : "token",
      "expires_at" : "2021-01-31",
      "id" : 42,
      "active" : true,
      "created_at" : "2021-01-20T22:11:48.151Z",
      "revoked" : false
   }
]
```

## Create a resource access token

> - [Introduced](https://gitlab.com/gitlab-org/gitlab/-/issues/238991) in GitLab 13.9.

Create a resource access token. 

```plaintext
POST /:id/access_tokens
```

| Attribute | Type    | required | Description         |
|-----------|---------|----------|---------------------|
| `name` | String | yes | The name of the resource access token  |
| `scopes` | Array[String] | yes | The scopes of the resource access token |
| `expires_at` | Date | no | The expiration date of the resource access token |

```shell
curl --request POST --header "PRIVATE-TOKEN: <your_access_token>" \
--header "Content-Type:application/json" \
--data '{ "name":"test_token", "scopes":["api", "read_repository"], "expires_at":"2021-01-31" }' \
"http://127.0.0.1:3000/api/v4/projects/20/access_tokens"
```

```json
{
   "scopes" : [
      "api",
      "read_repository"
   ],
   "active" : true,
   "name" : "test",
   "revoked" : false,
   "created_at" : "2021-01-21T19:35:37.921Z",
   "user_id" : 166,
   "id" : 58,
   "expires_at" : "2021-01-31"
}
```

## Revoke a resource access token

> - [Introduced](https://gitlab.com/gitlab-org/gitlab/-/issues/238991) in GitLab 13.9.

Revoke a resource access token.

```plaintext
DELETE /:id/access_tokens/:token_id
```

| Attribute | Type    | required | Description         |
|-----------|---------|----------|---------------------|
| `id` | integer/string | yes | The ID of the project or group  |
| `token_id` | integer/string | yes | The ID of the resource access token |

```shell
curl --request DELETE --header "PRIVATE-TOKEN: <your_access_token>" "https://gitlab.example.com/api/v4/projects/<project_id>/access_tokens/<token_id>"
```

### Responses

- `204: No Content` if successfully revoked.
- `400 Bad Request` if not revoked successfully.
