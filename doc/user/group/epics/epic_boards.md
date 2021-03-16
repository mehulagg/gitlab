---
stage: Plan
group: Product Planning
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#assignments
---

# Epic Boards **(ULTIMATE)**

> - [Introduced](https://gitlab.com/groups/gitlab-org/-/epics/2864) in GitLab 13.10.
> - It's [deployed behind a feature flag](../../feature_flags.md), disabled by default.
> - It's disabled on GitLab.com.
> - It's not recommended for production use.
> - To use it in GitLab self-managed instances, ask a GitLab administrator to [enable it](../../../administration/feature_flags.md).

WARNING:
This feature might not be available to you. Check the **version history** note above for details.

The GitLab Epic Board is a software project management tool used to plan,
organize, and visualize a workflow for a feature or product release.

Epic boards build on the existing [epic tracking functionality](index.md) and
[labels](../../project/labels.md). Your epics appear as cards in vertical lists, organized by their assigned
labels.

![GitLab epic board - Ultimate](img/epic_board_v13_10.png)

## Create an epic board

To create a new epic board:

1. Click the dropdown with the current board name in the upper left corner of the Epic Boards page.
1. Click **Create new board**.
1. Enter the new board's name and click `Create`.

## Enable or disable Epic Boards

Epic Boards are under development and not ready for production use. It is
deployed behind a feature flag that is **disabled by default**.
[GitLab administrators with access to the GitLab Rails console](../../../administration/feature_flags.md)
can enable it.

To enable it:

```ruby
Feature.enable(:epic_boards)
```

To disable it:

```ruby
Feature.disable(:epic_boards)
```
