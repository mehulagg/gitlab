---
stage: Release
group: Release
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#assignments
---

# CI/CD Analytics

## Pipeline success and duration charts **(FREE)**

> - Introduced in GitLab 3.1.1 as Commit Stats, and later renamed to Pipeline Charts.
> - [Renamed](https://gitlab.com/gitlab-org/gitlab/-/issues/38318) to CI/CD Analytics in GitLab 12.8.

GitLab tracks the history of your pipeline successes and failures, as well as how long each pipeline
ran. To view this information, go to **Analytics > CI/CD Analytics**.

View successful pipelines:

![Successful pipelines](img/pipelines_success_chart.png)

View pipeline duration history:

![Pipeline duration](img/pipelines_duration_chart.png)

## DevOps Research and Assessment (DORA) key metrics **(ULTIMATE)**

> - [Introduced](https://gitlab.com/gitlab-org/gitlab/-/issues/275991) in GitLab 13.7.
> - Support [Lead time for changes]() in GitLab 13.10.

Customer experience is a key metric. Users want to measure platform stability and other
post-deployment performance KPIs, and set targets for customer behavior, experience, and financial
impact. Tracking and measuring these indicators solves an important pain point. Similarly, creating
views that manage products, not projects or repositories, provides users with a more relevant data set.
Since GitLab is a tool for the entire DevOps life-cycle, information from different workflows is
integrated and can be used to measure the success of the teams.

The DevOps Research and Assessment ([DORA](https://cloud.google.com/blog/products/devops-sre/the-2019-accelerate-state-of-devops-elite-performance-productivity-and-scaling))
team developed four key metrics that the industry has widely adopted. You can use these metrics as
performance indicators for software development teams:

- Deployment frequency: How often an organization successfully releases to production.
- Lead time for changes: The amount of time it takes for code to reach production.
- Change failure rate: The percentage of deployments that cause a failure in production.
- Time to restore service: How long it takes an organization to recover from a failure in
  production.

### Supported metrics in GitLab

| Level           | Metric name               | API                                  | Chart (UI)                                      | Comment                                                                               |
| --------------- | -----------               | ---------------                      | ----------                                      | -------                                                                               |
| Project-level   | `deployment_frequency`    | [13.7 ~](../../api/dora/metrics.md)  | [13.8 ~](#deployment-frequency-charts-ultimate) | The [old API endopint](../../api/dora4_project_analytics.md) was deprecated in 13.10. |
| Group-level     | `deployment_frequency`    | [13.10 ~](../../api/dora/metrics.md) | To be supported  |                                                                                       |
| Project-level   | `lead_time_for_changes`   | [13.10 ~](../../api/dora/metrics.md) | To be supported  |                                                                                       |
| Group-level     | `lead_time_for_changes`   | [13.10 ~](../../api/dora/metrics.md) | To be supported  |                                                                                       |
| Project-level   | `change_failure_rate`     | To be supported                      | To be supported  |                                                                                       |
| Group-level     | `change_failure_rate`     | To be supported                      | To be supported  |                                                                                       |
| Project-level   | `time_to_restore_service` | To be supported                      | To be supported  |                                                                                       |
| Group-level     | `time_to_restore_service` | To be supported                      | To be supported  |                                                                                       |

## Deployment frequency charts **(ULTIMATE)**

> [Introduced](https://gitlab.com/gitlab-org/gitlab/-/issues/275991) in GitLab 13.8.

The **Analytics > CI/CD Analytics** page shows information about the deployment frequency to the
`production` environment. The environment **must** be named `production` for its deployment
information to appear on the graphs.

![Deployment frequency](img/deployment_frequency_chart_v13_8.png)
