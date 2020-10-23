# Group and project members API

## Valid access levels

The access levels are defined in the `Gitlab::Access` module. Currently, these levels are recognized:

- No access (`0`)
- Guest (`10`)
- Reporter (`20`)
- Developer (`30`)
- Maintainer (`40`)
- Owner (`50`) - Only valid to set for groups

CAUTION: **Caution:**
Due to [an issue](https://gitlab.com/gitlab-org/gitlab/-/issues/219299),
projects in personal namespaces will not show owner (`50`) permission
for owner.

 ## List all pending invitations to a group or project

 Gets a list of invited group or project members viewable by the authenticated user.
 Returns only direct members and not inherited members through ancestors groups.

 This function takes pagination parameters `page` and `per_page` to restrict the list of users.

 ```plaintext
 GET /groups/:id/invitations
 GET /projects/:id/invitations
 ```

 | Attribute | Type | Required | Description |
 | --------- | ---- | -------- | ----------- |
 | `id`      | integer/string | yes | The ID or [URL-encoded path of the project or group](README.md#namespaced-path-encoding) owned by the authenticated user |
 | `query`   | string | no     | A query string to search for invited members |

 ```shell
 curl --header "PRIVATE-TOKEN: <your_access_token>" "https://gitlab.example.com/api/v4/groups/:id/invitations"
 curl --header "PRIVATE-TOKEN: <your_access_token>" "https://gitlab.example.com/api/v4/projects/:id/invitations"
 ```

 Example response:

 ```json
 [
   {
     "id": 1,
     "invite_email": "member@example.org",
     "invite_token": "------",
     "invited_at": "2020-10-22T14:13:35Z",
     "expires_at": "2020-11-22T14:13:35Z",
     "username": "Raymond Smith",
     "access_level": 30,
     "group_saml_identity": null
   },
]
```

## Invite a member by email to a group or project

Invites a member by email to a group or project.

```plaintext
POST /groups/:id/invitations
POST /projects/:id/invitations
```

| Attribute | Type | Required | Description |
| --------- | ---- | -------- | ----------- |
| `id`      | integer/string | yes | The ID or [URL-encoded path of the project or group](README.md#namespaced-path-encoding) owned by the authenticated user |
| `email` | integer/string | yes | The email of the new member or multiple emails separated by commas |
| `access_level` | integer | yes | A valid access level |
| `expires_at` | string | no | A date string in the format YEAR-MONTH-DAY |

```shell
curl --request POST --header "PRIVATE-TOKEN: <your_access_token>" --data "email=test@example.com&access_level=30" "https://gitlab.example.com/api/v4/groups/:id/invitations"
curl --request POST --header "PRIVATE-TOKEN: <your_access_token>" --data "email=test@example.com&access_level=30" "https://gitlab.example.com/api/v4/projects/:id/invitations"
```

Example responses:

When all emails were successfully invited:

```json
{  "status":  "success"  }
```

When there was any error inviting emails as new members:

```json
{
  "status": "error",
  "message": {
               "test@example.com": "Already invited",
               "test2@example.com": "Member already exsists"
             }
}
```
