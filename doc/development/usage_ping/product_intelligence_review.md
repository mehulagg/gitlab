---
stage: Growth
group: Product Intelligence
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#assignments
---

# Product Intelligence Review Guidelines

This page includes introductory material for Product Intelligence review.

This page is specific to Product Intelligence reviews. Please refer to our
[code review guide](code_review.md) for broader advice and best
practices for code review in general.

## Resources for Product Intelligence reviewers

- [Usage Ping Guide](../usage_ping.md)
- [Snowplow Guide](../snowplow.md)
- [Metrics Dictionary](metrics_dictionary.md)

## General process

A Product Intelligence review is recommended whenever an application update touches Product Intelligence files.

- Changes that touch `usage_data*` files.
- Changes to the Metrics Dictionary including files in:
  - [`config/metrics`](https://gitlab.com/gitlab-org/gitlab/-/tree/master/config/metrics).
  - [`ee/config/metrics`](https://gitlab.com/gitlab-org/gitlab/-/tree/master/ee/config/metrics).
  - [`dictionary.md`](https://gitlab.com/gitlab-org/gitlab/-/blob/master/doc/development/usage_ping/dictionary.md).
  - [`schema.json`](https://gitlab.com/gitlab-org/gitlab/-/blob/master/config/metrics/schema.json).
- Changes to `tracking` files.
- Changes to Product Intelligence tooling for example [`Gitlab::UsageMetricDefinitionGenerator`](https://gitlab.com/gitlab-org/gitlab/-/blob/master/lib/generators/gitlab/usage_metric_definition_generator.rb)

### Roles and process

A Merge Request **author**'s role is to:

- Decide whether a Product Intelligence review is needed.
- If Product Intelligence review is needed add the `~product intelligence`, `~product intelligence::review pending`.
- Assign to one of the [engineers]((https://gitlab.com/groups/gitlab-org/growth/product-intelligence/engineers/-/group_members?with_inherited_permissions=exclude)) from Product Intelligence team for a review.
- Set the correct attributes in YAML metrics:
  - `product_section`, `product_stage`, `product_group`, `product_category`
  - Provide a clear description of the meric.
- Update [Metrics Dictionary](https://gitlab.com/gitlab-org/gitlab/-/blob/master/doc/development/usage_ping/dictionary.md) if it is needed
- Add a changelog according to [guidelines](../changelog.md).

A Product Intelligence **reviewer**'s role is to:

- Perform a first-pass review on the MR and suggest improvements to the author.
- Approve the MR and relabel the MR with ~"product intelligence::approved".

## Distributing review workload

Danger bot is adding the list of Product Intelligence changed files and pings the [`@gitlab-org/growth/product-intelligence/engineers`](https://gitlab.com/groups/gitlab-org/growth/product-intelligence/engineers/-/group_members?with_inherited_permissions=exclude) group for MR that are not a Draft.

Any of the engineers in the group could be assigned for the Product Intelligence review.

### How to review for Product Intelligence

- Check [metrics location](../usage_ping.md#1-naming-and-placing-the-metrics) in Usage Ping JSON payload.
- Add `~database` label and ask for [database review](../database_review.md) for metrics that are based on Database.
- For tracking using Redis HLL:
  - Check the Redis slot.
  - Check if a [feature flag is needed](../usage_ping.md#recommendations).
- Metrics YAML definitions:
  - Check the metric `description`.
  - Check the metrics `key_path`.
  - Check the `product_section`, `product_stage`, `product_group`, `product_category`, see [stages file](https://gitlab.com/gitlab-com/www-gitlab-com/blob/master/data/stages.yml).
  - Check the file location considering time frame or if it should be under `ee`.
  - Check the tiers.
