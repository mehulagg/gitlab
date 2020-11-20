---
stage: Manage
group: Optimize
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#designated-technical-writers
---

# Value Stream Analytics **(CORE)**

> - Introduced as Cycle Analytics prior to GitLab 12.3 at the project level.
> - [Introduced](https://gitlab.com/gitlab-org/gitlab/-/issues/12077) in [GitLab Premium](https://about.gitlab.com/pricing/) 12.3 at the group level.
> - [Renamed](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/23427) from Cycle Analytics to Value Stream Analytics in GitLab 12.8.

Value Stream Analytics measures the time spent to go from an
[idea to production](https://about.gitlab.com/blog/2016/08/05/continuous-integration-delivery-and-deployment-with-gitlab/#from-idea-to-production-with-gitlab)
(also known as cycle time) for each of your projects or groups. Value Stream Analytics displays the median time
spent in each stage defined in the process.

Value Stream Analytics is useful in order to quickly determine the velocity of a given
project. It points to bottlenecks in the development process, enabling management
to uncover, triage, and identify the root cause of slowdowns in the software development life cycle.

For information on how to contribute to the development of Value Stream Analytics, see our [contributor documentation](../../development/value_stream_analytics.md).

Project-level Value Stream Analytics is available via **Project > Analytics > Value Stream**.

Note: [Group-level Value Stream Analytics](../group/value_stream_analytics) is also available.

## Default stages

The stages tracked by Value Stream Analytics by default represent the [GitLab flow](../../topics/gitlab_flow.md). These stages can be customized in Group Level Value Stream Analytics.

- **Issue** (Tracker)
  - Time to schedule an issue (by milestone or by adding it to an issue board)
- **Plan** (Board)
  - Time to first commit
- **Code** (IDE)
  - Time to create a merge request
- **Test** (CI)
  - Time it takes GitLab CI/CD to test your code
- **Review** (Merge Request/MR)
  - Time spent on code review
- **Staging** (Continuous Deployment)
  - Time between merging and deploying to production

### Date ranges

> [Introduced](https://gitlab.com/gitlab-org/gitlab-foss/-/issues/36300) in GitLab 10.0.

GitLab provides the ability to filter analytics based on a date range. To filter results, select one of these options:

1. Last 7 days
1. Last 30 days (default)
1. Last 90 days

## How Time metrics are measured

The "Time" metrics near the top of the page are measured as follows:

- **Lead time**: median time from issue created to issue closed.
- **Cycle time**: median time from first commit to issue closed.

Note: A commit is associated with an issue by [crosslinking](../project/issues/crosslinking_issues.md) in the commit message or by manually linking the merge request containing the commit.

## How the stages are measured

Value Stream Analytics records stage time and data based on the project issues with the
exception of the staging stage, where only data deployed to
production are measured.

Specifically, if your CI is not set up and you have not defined a [production environment](#how-the-production-environment-is-identified), then you will not have any
data for this stage.

Each stage of Value Stream Analytics is further described in the table below.

| **Stage** | **Description** |
| --------- | --------------- |
| Issue     | Measures the median time between creating an issue and taking action to solve it, by either labeling it or adding it to a milestone, whatever comes first. The label will be tracked only if it already has an [Issue Board list](../project/issue_board.md) created for it. |
| Plan      | Measures the median time between the action you took for the previous stage, and pushing the first commit to the branch. The very first commit of the branch is the one that triggers the separation between **Plan** and **Code**, and at least one of the commits in the branch needs to contain the related issue number (e.g., `#42`). If none of the commits in the branch mention the related issue number, it is not considered to the measurement time of the stage. |
| Code      | Measures the median time between pushing a first commit (previous stage) and creating a merge request (MR) related to that commit. The key to keep the process tracked is to include the [issue closing pattern](../project/issues/managing_issues.md#closing-issues-automatically) to the description of the merge request (for example, `Closes #xxx`, where `xxx` is the number of the issue related to this merge request). If the closing pattern is not present, then the calculation takes the creation time of the first commit in the merge request as the start time. |
| Test      | Measures the median time to run the entire pipeline for that project. It's related to the time GitLab CI/CD takes to run every job for the commits pushed to that merge request defined in the previous stage. It is basically the start->finish time for all pipelines. |
| Review    | Measures the median time taken to review the merge request that has a closing issue pattern, between its creation and until it's merged. |
| Staging   | Measures the median time between merging the merge request with a closing issue pattern until the very first deployment to a [production environment](#how-the-production-environment-is-identified). If there isn't a production environment, this is not tracked. |

How this works, behind the scenes:

1. Issues and merge requests are grouped together in pairs, such that for each
   `<issue, merge request>` pair, the merge request has the [issue closing pattern](../project/issues/managing_issues.md#closing-issues-automatically)
   for the corresponding issue. All other issues and merge requests are **not**
   considered.
1. Then the `<issue, merge request>` pairs are filtered out by last XX days (specified
   by the UI - default is 90 days). So it prohibits these pairs from being considered.
1. For the remaining `<issue, merge request>` pairs, we check the information that
   we need for the stages, like issue creation date, merge request merge time,
   etc.

To sum up, anything that doesn't follow [GitLab flow](../../topics/gitlab_flow.md) will not be tracked and the
Value Stream Analytics dashboard will not present any data for:

- Merge requests that do not close an issue.
- Issues not labeled with a label present in the Issue Board or for issues not assigned a milestone.
- Staging stage, if the project has no [production environment](#how-the-production-environment-is-identified).

## How the production environment is identified

Value Stream Analytics identifies production environments by looking for project [environments](../../ci/yaml/README.md#environment) with a name matching any of these patterns:

- `prod` or `prod/*`
- `production` or `production/*`

These patterns are not case-sensitive.

You can change the name of a project environment in your GitLab CI/CD configuration.

## Example workflow

Below is a simple fictional workflow of a single cycle that happens in a
single day passing through all seven stages. Note that if a stage does not have
a start and a stop mark, it is not measured and hence not calculated in the median
time. It is assumed that milestones are created and CI for testing and setting
environments is configured.

1. Issue is created at 09:00 (start of **Issue** stage).
1. Issue is added to a milestone at 11:00 (stop of **Issue** stage / start of
   **Plan** stage).
1. Start working on the issue, create a branch locally and make one commit at
   12:00.
1. Make a second commit to the branch which mentions the issue number at 12.30
   (stop of **Plan** stage / start of **Code** stage).
1. Push branch and create a merge request that contains the [issue closing pattern](../project/issues/managing_issues.md#closing-issues-automatically)
   in its description at 14:00 (stop of **Code** stage / start of **Test** and
   **Review** stages).
1. The CI starts running your scripts defined in [`.gitlab-ci.yml`](../../ci/yaml/README.md) and
   takes 5min (stop of **Test** stage).
1. Review merge request, ensure that everything is OK and merge the merge
   request at 19:00. (stop of **Review** stage / start of **Staging** stage).
1. Now that the merge request is merged, a deployment to the `production`
   environment starts and finishes at 19:30 (stop of **Staging** stage).

From the above example you can conclude the time it took each stage to complete
as long as their total time:

- **Issue**: 2h (11:00 - 09:00)
- **Plan**: 1h (12:00 - 11:00)
- **Code**: 2h (14:00 - 12:00)
- **Test**: 5min
- **Review**: 5h (19:00 - 14:00)
- **Staging**: 30min (19:30 - 19:00)

A few notes:

- In the above example we demonstrated that it doesn't matter if your first
  commit doesn't mention the issue number, you can do this later in any commit
  of the branch you are working on.
- You can see that the **Test** stage is not calculated to the overall time of
  the cycle since it is included in the **Review** process (every MR should be
  tested).
- The example above was just **one cycle** of the seven stages. Add multiple
  cycles, calculate their median time and the result is what the dashboard of
  Value Stream Analytics is showing.

## Permissions

The current permissions on the Project-level Value Stream Analytics dashboard are:

- Public projects - anyone can access.
- Internal projects - any authenticated user can access.
- Private projects - any member Guest and above can access.

You can [read more about permissions](../../user/permissions.md) in general.

## More resources

Learn more about Value Stream Analytics in the following resources:

- [Value Stream Analytics feature page](https://about.gitlab.com/stages-devops-lifecycle/value-stream-analytics/).
- [Value Stream Analytics feature preview](https://about.gitlab.com/blog/2016/09/16/feature-preview-introducing-cycle-analytics/).
- [Value Stream Analytics feature highlight](https://about.gitlab.com/blog/2016/09/21/cycle-analytics-feature-highlight/).
