---
stage: Monitor
group: Health
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#assignments
---

# On-call Schedule Management **(ULTIMATE)**

> [Introduced](https://gitlab.com/groups/gitlab-org/-/epics/4544) in [GitLab Ultimate](https://about.gitlab.com/pricing/) 13.10.

Most businesses are becoming tech companies where they have a software service that they provide to their customers. Software services do not get "turned off" at the end of the business day - customers expect 24/7 reliable availability. When things go wrong, you need a team (or multiple!) that can quickly and effectively respond to service outages.

If you have at least Maintainer [permissions](../../user/permissions.md), to create an
schedule, you have one option to do this manually.

## Schedule Creation

> [Introduced](https://gitlab.com/gitlab-org/gitlab/-/issues/230857) in GitLab 13.10.

1. Go to **Operations > On-call Schedules**, and select **Add a schedule**.

   ![Schedule Empty State](img/oncall_schedule_empty_state_v13_10.png)

1. In the **Add a schedule** modal, enter a schedule **name**, **description** and select a **timezone**.

    ![Schedule Create](img/oncall_schedule_create_v13_10.png)

1. You have now created an empty schedule with no rotations. This will render the below empty state prompting you to create rotations.

   ![Schedule Empty Grid](img/oncall_schedule_empty_grid_v13_10.png)

### Schedule Update

> [Introduced](https://gitlab.com/gitlab-org/gitlab/-/issues/262849) in GitLab 13.10.

1. Go to **Operations > On-call Schedules**, and select **Pencil** icon on the top right of the schedule card across from the schedule name.
1. In the **Edit a schedule** modal, update your schedule **name**, **description** and select a new **timezone** if needed.
1. Click the **Edit schedule** button to save your changes.

   ![Schedule Edit](img/oncall_schedule_edit_schedule_v13_10.png)

### Schedule Deletion

> [Introduced](https://gitlab.com/gitlab-org/gitlab/-/issues/262850) in GitLab 13.10.

1. Go to **Operations > On-call Schedules**, and select **Trash can** icon on the top right of the schedule card.
1. In the **Delete Schedule** modal, click the **Delete schedule** button to save your changes and delete the current schedule.

   ![Schedule Delete](img/oncall_schedule_delete_schedule_v13_10.png)

## Rotation Creation

> [Introduced](https://gitlab.com/gitlab-org/gitlab/-/issues/262857) in GitLab 13.10.

1. Go to **Operations > On-call Schedules**, and click the **Add a rotation** button on the top right of the current schedule.
1. In the **Add a rotation** modal, enter a **Name**, select your needed **Participants**, enter the **Rotation length** and finally the **Starts on** time/date.
1. Rotations can also be enabled to have fixed **Start/End** dates which can be enabled via the toggle and the end of the modal.
1. Rotations can also be enabled to be restricted to **Time intervals** which can be enabled via the toggle and the end of the modal.

   ![Schedule Add Rotation](img/oncall_schedule_add_rotation_v13_10.png)

| Modal Option | Value | Type | 
| ------ | ------ | ------ |
| Name | The name of the rotation to create | `String` | 
| Participants | The selection of users to assign to the rotation | `User`  |
| Rotation length value | The length each participant is on call | `Number` |
| Rotation length type | The time unit for the duration length | `Hours / Days / Weeks` |
| Starts on date | The start date of the rotation | `Date` |
| Starts on time | The start time for each shift within the rotation | `Time` |

### Rotation Start/End Date

> [Introduced](https://gitlab.com/gitlab-org/gitlab/-/issues/262858) in GitLab 13.10.

1. Go to **Operations > On-call Schedules**, and click the **Add a rotation** button on the top right of the current schedule.
1. In the **Add a rotation** modal toggle the **Enable end date** option and then select a start/end date for the rotation being created.

  ![Schedule Rotation Start/End Date](img/oncall_schedule_start_end_date_v13_10.png)

### Rotation Time Intervals

> [Introduced](https://gitlab.com/gitlab-org/gitlab/-/issues/262859) in GitLab 13.10.

1. Go to **Operations > On-call Schedules**, and click the **Add a rotation** button on the top right of the current schedule.
1. In the **Add a rotation** modal toggle the **Restrict to time intervals** option and then select a start/end time for each rotation shift to be restricted to.

  ![Schedule Rotation Time Interval](img/oncall_schedule_time_interval_v13_10.png)

## Schedule Rotation Views(Daily, Hourly)

> [Introduced](https://gitlab.com/gitlab-org/gitlab/-/issues/262860) in GitLab 13.10.

1. On-call Schedules can be viewed in two formats currently, `1 day` at a time or `2 weeks` at a time. 
1. To swap views please use the toggle in the top right of the schedule card. 
1. By default, `2 weeks` are selected. 
1. Rotation shift participants can be hovered over to view their individual shift details(Starts on/Ends On/Name).

**2 Week Grid View**

  ![2 Week Grid View](img/oncall_schedule_weekly_grid.png)

**1 Day Grid View**

   ![1 Day Grid View](img/oncall_schedule_day_grid_v13_10.png)

### Rotation Edit

> [Introduced](https://gitlab.com/gitlab-org/gitlab/-/issues/262862) in GitLab 13.10.

1. Go to **Operations > On-call Schedules**, and select **Pencil** icon on the right of the rotation title that you want to update.
1. In the **Edit Rotation** modal, click the **Edit rotation** button.

### Rotation Deletion

> [Introduced](https://gitlab.com/gitlab-org/gitlab/-/issues/262863) in GitLab 13.10.

1. Go to **Operations > On-call Schedules**, and select **Trash Can** icon on the right of the rotation title that you want to delete.
1. In the **Delete Rotation** modal, click the **Delete rotation** button to save your changes and remove the currently selected rotation.

   ![Schedule Rotation Delete](img/oncall_schedule_delete_rotation_v13_10.png)
