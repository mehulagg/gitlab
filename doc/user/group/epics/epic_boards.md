---
stage: Plan
group: Product Planning
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#assignments
---

# Epic Boards **(PREMIUM)**

> - [Introduced](https://gitlab.com/groups/gitlab-org/-/epics/2864) in GitLab 13.10.
> - [Deployed behind a feature flag](../../feature_flags.md), disabled by default.
> - [Enabled by default](https://gitlab.com/gitlab-org/gitlab/-/issues/290039) in GitLab 14.0.
> - Enabled on GitLab.com.
> - Recommended for production use.
> - For GitLab self-managed instances, GitLab administrators can opt to [disable it](../../../administration/feature_flags.md).

Epic boards build on the existing [epic tracking functionality](index.md) and
[labels](../../project/labels.md). Your epics appear as cards in vertical lists, organized by their assigned
labels.

To view an epic board, in a group, select **Epics > Boards**.

![GitLab epic board - Premium](img/epic_board_v13_10.png)

## Create an epic board

To create a new epic board:

1. Go to your group and select **Epics > Boards**.
1. In the upper left corner, select the dropdown with the current board name.
1. Select **Create new board**.
1. Enter the new board's title.
1. Optional. To hide the Open or Closed lists, clear the **Show the Open list** and
   **Show the Closed list** checkboxes.
1. Optional. Set board scope:
   1. Next to **Scope**, select **Expand**.
   1. Next to **Labels**, select **Edit** and select the labels to use as board scope.
1. Select **Create board**.

You've created an epic board. Now you can [add some lists](#create-a-new-list).
To change these options later, [edit the board](#edit-the-scope-of-an-epic-board).

<!-- TODO: This is not in the product
## Delete an epic board

To delete the active epic board:

1. Select the dropdown with the current board name in the upper left corner of the Epic Boards page.
1. Select **Delete board**.
1. Select **Delete**. -->

## Actions you can take on an epic board

- [Create a new list](#create-a-new-list).
- [Remove an existing list](#remove-a-list).
<!-- - [Filter epics](#filter-epics). -->
- Create workflows, like when using [issue boards](../../project/issue_board.md#create-workflows).
- [Move epics and lists](#move-epics-and-lists).
- Change epic labels (by dragging an epic between lists).
- Configure the scope of the board.
- Close an epic (by dragging it to the **Closed** list).

### Create a new list

Prerequisites:
<!-- TODO: Add this to permissions.md -->
- A minimum of [Reporter](../../permissions.md) access to a group in GitLab.

To create a new list:

1. Go to your group and select **Epics > Boards**.
1. In the upper-right corner, select **Create list**.
1. In the **New list** column expand the **Select a label** dropdown and select the label to use as
   list scope.
1. Select **Add to board**.

### Remove a list

Removing a list doesn't have any effect on epics and labels, as it's just the
list view that's removed. You can always create it again later if you need.

Prerequisites:
<!-- TODO: Add this to permissions.md -->
- A minimum of [Reporter](../../permissions.md) access to a group in GitLab.

To remove a list from an epic board:

1. On the top of the list you want to remove, select the **List settings** icon (**{settings}**).
   The list settings sidebar opens on the right.
1. Select **Remove list**. A confirmation dialog appears.
1. Select **OK**.

<!-- TODO: This is not yet in the product
### Filter epics

Use the filters on top of your epic board to show only
the results you want. It's similar to the filtering used in the epic list,
as the metadata from the epics and labels is re-used in the epic board.

You can filter by the following:

- Assignee
- Author
- Epic
- Iteration
- Label
- Milestone
- My Reaction
- Release
- Weight -->

### Move epics and lists

You can move epics and lists by dragging them.

Prerequisites:
<!-- TODO: Add this to permissions.md -->
- A minimum of [Reporter](../../permissions.md) access to a group in GitLab.

To move an epic, select the epic card and drag it to another position within its current list or
onto that list. Learn about possible effects in [Dragging epics between lists](#dragging-epics-between-lists).

To move a list, select its top bar, and drag it horizontally.
You can't move the **Open** and **Closed** lists, but you can hide them when editing an epic board.

#### Dragging epics between lists

When you drag epics between lists, different behavior occurs depending on the source list and the
target list.

|                              | To Open          | To Closed    | To label B list                   | To assignee Bob list              |
| ---------------------------- | ---------------- | ------------ | --------------------------------- | --------------------------------- |
| **From Open**                | -                | Issue closed | Label B added                     | Bob assigned                      |
| **From Closed**              | Issue reopened   | -            | Issue reopened and label B added  | Issue reopened and Bob assigned   |
| **From label A list**        | Label A removed  | Issue closed | Label A removed and label B added | Bob assigned                      |
| **From assignee Alice list** | Alice unassigned | Issue closed | Label B added                     | Alice unassigned and Bob assigned |

