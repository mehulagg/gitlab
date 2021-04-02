---
stage: Growth
group: Product Intelligence
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#assignments
---

# Metrics Dictionary Guide

This guide describes Metrics Dictionary and how it's implemented

## Metrics Definition and validation

We are using [JSON Schema](https://gitlab.com/gitlab-org/gitlab/-/blob/master/config/metrics/schema.json) to validate the metrics definition.

This process is meant to ensure consistent and valid metrics defined for Usage Ping. All metrics *must*:

- Comply with the defined [JSON schema](https://gitlab.com/gitlab-org/gitlab/-/blob/master/config/metrics/schema.json).
- Have a unique `key_path` .
- Have an owner.

All metrics are stored in YAML files:

- [`config/metrics`](https://gitlab.com/gitlab-org/gitlab/-/tree/master/config/metrics)

Each metric is defined in a separate YAML file consisting of a number of fields:

| Field               | Required | Additional information                                         |
|---------------------|----------|----------------------------------------------------------------|
| `key_path`          | yes      | JSON key path for the metric, location in Usage Ping payload.  |
| `name`              | no       | Metric name suggestion, that can be used to replace last part of `key_path` | 
| `description`       | yes      |                                                                |
| `product_section`   | yes      | The [section](https://gitlab.com/gitlab-com/www-gitlab-com/-/blob/master/data/sections.yml). |
| `product_stage`     | no       | The [stage](https://gitlab.com/gitlab-com/www-gitlab-com/blob/master/data/stages.yml) for the metric. |
| `product_group`     | yes      | The [group](https://gitlab.com/gitlab-com/www-gitlab-com/blob/master/data/stages.yml) that owns the metric. |
| `product_category`  | no       | The [product category](https://gitlab.com/gitlab-com/www-gitlab-com/blob/master/data/categories.yml) for the metric. |
| `value_type`        | yes      | `string`; one of [`string`, `number`, `boolean`, `object`](https://json-schema.org/understanding-json-schema/reference/type.html).                                                     |
| `status`            | yes      | `string`; [status](#metric-statuses) of the metric, may be set to `data_available`, `implemented`, `not_used`, `deprecated`. |
| `time_frame`        | yes      | `string`; may be set to a value like `7d`, `28d`, `all`, `none`. |
| `data_source`       | yes      | `string`; may be set to a value like `database`, `redis`, `redis_hll`, `prometheus`, `ruby`. |
| `distribution`      | yes      | `array`; may be set to one of `ce, ee` or `ee`. The [distribution](https://about.gitlab.com/handbook/marketing/strategic-marketing/tiers/#definitions) where the tracked feature is available.  |
| `tier`              | yes      | `array`; may be set to one of `free, premium, ultimate`, `premium, ultimate` or `ultimate`. The [tier]( https://about.gitlab.com/handbook/marketing/strategic-marketing/tiers/) where the tracked feature is available. |
| `milestone`         | no       | The milestone when the metric is introduced. |
| `milestone_removed` | no       | The milestone when the metric is removed. |
| `introduced_by_url` | no       | The URL to the Merge Request that introduced the metric. |
| `skip_validation`   | no       | This should **not** be set. [Used for imported metrics until we review, update and make them valid](https://gitlab.com/groups/gitlab-org/-/epics/5425). |

### Metric statuses

Metric definitions can have one of the following statuses:

- `data_available`: Metric data is available and used in a Sisense dashboard.
- `implemented`: Metric is implemented but data is not yet available. This is a temporary
  status for newly added metrics awaiting inclusion in a new release.
- `not_used`: Metric is not used in any dashboard.
- `deprecated`: Metric is deprecated and possibly planned to be removed.

### Metric name

In order to improve metric discoverability by wider audience each metric that 
has with instrumentation added at appointed `key_path` will get `name` attribute 
filled with the name suggestion, corresponding to the metric `data_source` and instrumentation.

Metric name suggestions can contains two types of elements:
1. User input prompts - enclosed by `<>`, this pieces are expected to be replaced by users
creating metrics YAML file
1. Fixed suggestion - plain text parts that are generated according to well defined algorithm, based on underlying instrumentation and should not be changed

### Metric name suggestion examples

**Metric with `data_source: database`**

For metric instrumented with SQL
```sql
SELECT COUNT(DISTINCT user_id) FROM clusters WHERE clusters.management_project_id IS NOT NULL
```
Suggested name would look like:
`count_distinct_user_id_from_<adjective describing: '(clusters.management_project_id IS NOT NULL)'>_clusters`

Part `<adjective describing: '(clusters.management_project_id IS NOT NULL)'>` is a prompt that is expected to be replaced with adjective that best represent filter conditions,
for example `project_managment`. So final metric name, would look like: `count_distinct_user_id_from_project_managment_clusters`

For metric instrumented with SQL 
```sql
SELECT COUNT(DISTINCT clusters.user_id) 
FROM clusters_applications_helm 
INNER JOIN clusters ON clusters.id = clusters_applications_helm.cluster_id 
WHERE clusters_applications_helm.status IN (3, 5)
```
Suggested name would look like:
`count_distinct_user_id_from_<adjective describing: '(clusters_applications_helm.status IN (3, 5))'>_clusters_<with>_<adjective describing: '(clusters_applications_helm.status IN (3, 5))'>_clusters_applications_helm`

Part `<adjective describing: '(clusters_applications_helm.status IN (3, 5))'>` is a prompt that is expected to be replaced with adjective that best represent filter conditions.
In above example, in first place prompt is not relevant, and user can decided to skip it all together, while it's second occurrence corresponds with `available` scope defined in `Clusters::Concerns::ApplicationStatus`
and it can be used as right adjective to replace prompt. 

Part `<with>` represents suggested conjunction for joined relation suggested name. Person documenting metric can use it by simple removing surrounding `<>` or decided to use different conjunction for example `having` or `including` etc.

Final metric name, could look like: `count_distinct_user_id_from_clusters_with_available_clusters_applications_helm`

**Metric with `data_source: redis` or `redis_hll`**

For metrics instrumented with Redis based counter suggested name would include only single prompt that should be replaced
by person working with metrics YAML.

Prompt: `<please fill metric name, suggested format is: who_is_doing_what eg: users_creating_epics>`

It is recommended that metric name would follow format of `who_is_doing_what` eg: `user_creating_epics`, `users_triggering_security_scans` etc.

**Metric with `data_source: prometheus` or `ruby`**

For metrics instrumented with Prometheus or Ruby suggested name would include only single prompt that should be replaced
by person working with metrics YAML.

Prompt: `<please fill metric name>`
 

### Example YAML metric definition

The linked [`uuid`](https://gitlab.com/gitlab-org/gitlab/-/blob/master/config/metrics/license/uuid.yml)
YAML file includes an example metric definition, where the `uuid` metric is the GitLab
instance unique identifier.

```yaml
key_path: uuid
description: GitLab instance unique identifier
product_category: collection
product_section: growth
product_stage: growth
product_group: group::product intelligence
value_type: string
status: data_available
milestone: 9.1
introduced_by_url: https://gitlab.com/gitlab-org/gitlab/-/merge_requests/1521
time_frame: none
data_source: database
distribution:
- ce
- ee
tier:
- free
- premium
- ultimate
```

## Create a new metric definition

The GitLab codebase provides a dedicated [generator](https://gitlab.com/gitlab-org/gitlab/-/blob/master/lib/generators/gitlab/usage_metric_definition_generator.rb) to create new metric definitions.

For uniqueness, the generated file includes a timestamp prefix, in ISO 8601 format.

The generator takes the key path argument and 2 options and creates the metric YAML definition in corresponding location:

- `--ee`, `--no-ee` Indicates if metric is for EE.
- `--dir=DIR` indicates the metric directory. It must be one of: `counts_7d`, `7d`, `counts_28d`, `28d`, `counts_all`, `all`, `settings`, `license`.

```shell
bundle exec rails generate gitlab:usage_metric_definition counts.issues --dir=7d
create  config/metrics/counts_7d/issues.yml
```

NOTE:
To create a metric definition used in EE, add the `--ee` flag.

```shell
bundle exec rails generate gitlab:usage_metric_definition counts.issues --ee --dir=7d
create  ee/config/metrics/counts_7d/issues.yml
```

## Metrics added dynamic to Usage Ping payload

The [Redis HLL metrics](index.md#known-events-are-added-automatically-in-usage-data-payload) are added automatically to Usage Ping payload.

A YAML metric definition is required for each metric. A dedicated generator is provided to create metric definitions for Redis HLL events.

The generator takes `category` and `event` arguments, as the root key will be `redis_hll_counters`, and creates two metric definitions for weekly and monthly timeframes:

```shell
bundle exec rails generate gitlab:usage_metric_definition:redis_hll issues i_closed
create  config/metrics/counts_7d/i_closed_weekly.yml
create  config/metrics/counts_28d/i_closed_monthly.yml
```
