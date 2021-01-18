---
stage: Release
group: Release
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#assignments
type: reference, api
---

# DORA4 Analytics Group API **(ULTIMATE ONLY)**

> [Introduced](https://gitlab.com/gitlab-org/gitlab/-/issues/291747) in [GitLab Ultimate](https://about.gitlab.com/pricing/) 13.9.

All methods require reporter authorization.

## List group deployment frequencies

Get a list of all group deployment frequencies:

```plaintext
GET /groups/:id/analytics/deployment_frequency?environment=:environment&from=:from&to=:to&interval=:interval
```

Attributes:

| Attribute    | Type   | Required | Description           |
|--------------|--------|----------|-----------------------|
| `id`         | string | yes      | The ID of the group. |

Parameters:

| Parameter    | Type   | Required | Description           |
|--------------|--------|----------|-----------------------|
| `environment`| string | yes      | The name of the environment to filter by. |
| `from`       | string | yes      | Datetime range to start from. Inclusive, ISO 8601 format (`YYYY-MM-DDTHH:MM:SSZ`). |
| `to`         | string | no       | Datetime range to end at. Exclusive, ISO 8601 format (`YYYY-MM-DDTHH:MM:SSZ`). |
| `interval`   | string | no       | The bucketing interval (`all`, `monthly`, `daily`). |

Example request:

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" "https://gitlab.example.com/api/v4/groups/:id/analytics/deployment_frequency?environment=:environment&from=:from&to=:to&interval=:interval"
```

Example response:

```json
[
  {
    "from": "2017-01-01",
    "to": "2017-01-02",
    "value": 106
  },
  {
    "from": "2017-01-02",
    "to": "2017-01-03",
    "value": 55
  }
]
```
