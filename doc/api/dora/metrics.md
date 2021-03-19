---
stage: Release
group: Release
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#assignments
type: reference, api
---

# DevOps Research and Assessment (DORA) key metrics API **(ULTIMATE)**

> [Introduced](https://gitlab.com/gitlab-org/gitlab/-/issues/279039) in [GitLab Ultimate](https://about.gitlab.com/pricing/) 13.10.

All methods require [reporter permissions and above](../../user/permissions.md).

## Get project-level DORA metrics

Get project-level DORA metrics.

```plaintext
GET /projects/:id/dora/metrics
```

| Attribute          | Type           | Required | Description                      |
|--------------      |--------        |----------|-----------------------           |
| `id`               | integer/string | yes      | The ID or [URL-encoded path of the project](../README.md#namespaced-path-encoding) can be accessed by the authenticated user. |
| `metric`           | string         | yes      | The [metric name](../../user/analytics/ci_cd_analytics.md#supported-metrics-in-gitlab). One of `deployment_frequency` or `lead_time_for_changes`.  |
| `start_date`       | string         | no       | Date range to start from. ISO 8601 Date format, for example `2021-03-01`. Default is 3 months ago. |
| `end_date`         | string         | no       | Date range to end at. ISO 8601 Date format, for example `2021-03-01`. Default is the current date. |
| `interval`         | string         | no       | The bucketing interval. One of `all`, `monthly` or `daily`. Default is `daily`.   |
| `environment_tier` | string         | no       | The [tier of the environment](../../ci/environments/index.md#deployment-tier-of-environments). Default is `production`.                     |

Example request:

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" "https://gitlab.example.com/api/v4/projects/1/dora/metrics?metric=deployment_frequency"
```

Example response:

```json
[
  { "2021-03-01": 3 },
  { "2021-03-02": 6 },
  { "2021-03-03": 0 },
  { "2021-03-04": 0 },
  { "2021-03-05": 0 },
  { "2021-03-06": 0 },
  { "2021-03-07": 0 },
  { "2021-03-08": 4 }
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
| `id`               | integer/string | yes      | The ID or [URL-encoded path of the project](../README.md#namespaced-path-encoding) can be accessed by the authenticated user. |
| `metric`           | string         | yes      | The [metric name](../../user/analytics/ci_cd_analytics.md#supported-metrics-in-gitlab). One of `deployment_frequency` or `lead_time_for_changes`.  |
| `start_date`       | string         | no       | Date range to start from. ISO 8601 Date format, for example `2021-03-01`. Default is 3 months ago. |
| `end_date`         | string         | no       | Date range to end at. ISO 8601 Date format, for example `2021-03-01`. Default is the current date. |
| `interval`         | string         | no       | The bucketing interval. One of `all`, `monthly` or `daily`. Default is `daily`.   |
| `environment_tier` | string         | no       | The [tier of the environment](../../ci/environments/index.md#deployment-tier-of-environments). Default is `production`.                     |

Example request:

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" "https://gitlab.example.com/api/v4/groups/1/dora/metrics?metric=deployment_frequency"
```

Example response:

```json
[
  { "2021-03-01": 3 },
  { "2021-03-02": 6 },
  { "2021-03-03": 0 },
  { "2021-03-04": 0 },
  { "2021-03-05": 0 },
  { "2021-03-06": 0 },
  { "2021-03-07": 0 },
  { "2021-03-08": 4 }
]
```
