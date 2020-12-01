---
type: howto
stage: Fulfillment
group: Fulfillment
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#designated-technical-writers
---

# Storage usage quota

> [Introduced](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/13294) in [GitLab Starter](https://about.gitlab.com/pricing/) 12.0.
> Moved to GitLab Free.

Each project has a storage limit of 10 GiB by default. To help manage storage, an owner can
see the total storage used by each project. From the namespace's page go to **Settings > Usage Quotas**
and select the **Storage** tab. The Usage Quotas statistics are updated every 90 minutes.

If your namespace shows `N/A` as the total storage usage, push a commit to any project in that
namespace to trigger a recalculation.

A stacked bar graph shows the proportional storage used for the namespace, including a total per
storage item. Click on the project's title to see a breakdown per storage item.

![Group storage usage quota](img/group_storage_usage_quota.png)

## Storage usage statistics **(BRONZE ONLY)**

> - [Introduced](https://gitlab.com/gitlab-org/gitlab/-/issues/247831) in GitLab 13.7.
> - It's [deployed behind a feature flag](../../../user/feature_flags.md), enabled by default.
> - It's enabled on GitLab.com.
> - It's recommended for production use.

CAUTION: **Warning:**
This feature might not be available to you. Check the **version history** note above for details.

The following storage usage statistics are available to an owner:

- Total namespace storage used: Total amount of storage used across projects in this namespace.
- Total excess storage used: Total amount of storage used that exceeds their allocated storage.
- Purchased storage available: Total storage that has been purchased but is not yet used.

## Excess storage usage **(BRONZE ONLY)**

Each repository has a storage limit of 10 GiB by default. When a project exceeds that limit it is
locked. You cannot push changes to a locked project.

The **Storage** tab of the **Usage Quotas** page indicates projects that are _near_ their limit, and
projects which have exceeded the limit and so are locked. Locked projects are indicated with an
information icon (**{information-o}** ) beside their name.

To unlock a project you must [purchase more storage](../subscriptions/gitlab_com/index.md#buy-more-storage) for the namespace. When the purchase is
completed, locked projects are automatically unlocked.
