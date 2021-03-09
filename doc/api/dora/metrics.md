---
stage: Release
group: Release
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#assignments
type: reference, api
---

# DevOps Research and Assessment (DORA) key metrics API **(ULTIMATE)**

> [Introduced](https://gitlab.com/gitlab-org/gitlab/-/issues/279039) in [GitLab Ultimate](https://about.gitlab.com/pricing/) 13.10.

All methods require reporter authorization.

## Get project-level DORA metrics

Get project-level DORA metrics.

```plaintext
GET /projects/:id/dora/metrics
```

| Attribute          | Type           | Required | Description                      |
|--------------      |--------        |----------|-----------------------           |
| `id`               | integer/string | yes      | The ID or [URL-encoded path of the project](README.md#namespaced-path-encoding) owned by the authenticated user. |
| `metric`           | string         | yes      | The [metric name](../../user/analytics/ci_cd_analytics.md#supported-metrics-in-gitlab).  |
| `after`            | string         | no       | Date range to start from. ISO 8601 Date format e.g. `2021-03-01`. Default is 3 months ago. |
| `before`           | string         | no       | Date range to end at. ISO 8601 Date format e.g. `2021-03-01`. Default is the current date. |
| `interval`         | string         | no       | The bucketing interval. One of `all`, `monthly` or `daily`. Default is `daily`.   |
| `environment_tier` | string         | no       | The tier of [the environment](link). Default is `production`.                     |

Example request:

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" "https://gitlab.example.com/api/v4/projects/1/dora/metrics?metric=deployment_frequency"
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

## Get group-level DORA metrics

> [Introduced](https://gitlab.com/gitlab-org/gitlab/-/issues/279039) in [GitLab Ultimate](https://about.gitlab.com/pricing/) 13.10.

Get group-level DORA metrics.

```plaintext
GET /groups/:id/dora/metrics
```

| Attribute          | Type           | Required | Description                      |
|--------------      |--------        |----------|-----------------------           |
| `id`               | integer/string | yes      | The ID or [URL-encoded path of the project](README.md#namespaced-path-encoding) owned by the authenticated user. |
| `metric`           | string         | yes      | The [metric name](../../user/analytics/ci_cd_analytics.md#supported-metrics-in-gitlab).  |
| `after`            | string         | no       | Date range to start from. ISO 8601 Date format e.g. `2021-03-01`. Default is 3 months ago. |
| `before`           | string         | no       | Date range to end at. ISO 8601 Date format e.g. `2021-03-01`. Default is the current date. |
| `interval`         | string         | no       | The bucketing interval. One of `all`, `monthly` or `daily`. Default is `daily`.   |
| `environment_tier` | string         | no       | The tier of [the environment](link). Default is `production`.                     |

Example request:

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" "https://gitlab.example.com/api/v4/groups/1/dora/metrics?metric=deployment_frequency"
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
