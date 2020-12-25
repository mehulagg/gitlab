# Dashboards for stage groups

## Introduction

Observability is an important part of creating a good software system. Observability is about bringing visibility into a system to see and understand the state of each component, with context, to support performance tuning and debugging. GitLab has a rich and detailed observability platform that includes a set of [monitoring dashboards](https://dashboards.gitlab.net/dashboards/f/stage-groups/stage-groups) designed for each stage group.

The [Stage Group Dashboards](https://dashboards.gitlab.net/dashboards/f/stage-groups/stage-groups) are a set of dashboards tailored to the needs of Development development engineers. They are designed to bring the Stage Groups closer to understanding how their code operates on GitLab.com and to help make them more aware of the impact of code changes, deployments, and feature-flag toggles.

Each stage group has a dashboard consisting of metrics at the application level, such as Rails Web Requests, Rails API Requests, Sidekiq Jobs, etc. The metrics in each dashboard are filtered and accumulated based on the [GitLab product categories](https://about.gitlab.com/handbook/product/categories/) and [feature categories](https://docs.gitlab.com/ee/development/feature_categorization/).

The list of dashboards for each stage group is accessible at [https://dashboards.gitlab.net/dashboards/f/stage-groups/stage-groups](https://dashboards.gitlab.net/dashboards/f/stage-groups/stage-groups) for GitLab team members only.

Please note that the dashboards for stage groups are at a very early stage. All contributions are welcome. If you have any questions or suggestions, please submit an issue in the [Scalability Team issues tracker](https://gitlab.com/gitlab-com/gl-infra/scalability/-/issues/new).

## Usage

Inside a stage group dashboard, there are some notable components. In the example below, we use the [Source Code group's dashboard](https://dashboards.gitlab.net/d/stage-groups-source_code/stage-groups-group-dashboard-create-source-code?orgId=1).

**Disclaimer**: the stage group dashboard used for example here was chosen arbitrarily.

### Time range controls

![Default time filter](./img/stage_group_dashboards_time_filter.png)

- By default, all the times are in UTC timezone. [We use UTC when communicating in Engineering](https://about.gitlab.com/handbook/communication/#writing-style-guidelines).
- All metrics recorded in the GitLab production system have 14-day retention.
- Alternatively, you can zoom in or filter the time range directly on a graph. Please visit [Grafana Time Range Controls](https://grafana.com/docs/grafana/latest/dashboards/time-range-controls/) for more information.

### Filters and annotations

In each dashboard, there are two filters and some annotations switches on the top of the page. [Grafana annotations](https://grafana.com/docs/grafana/latest/dashboards/annotations/) mark some special events, which are meaningful to development and operational activities, directly on the graphs.

![Filters and annotations](./img/stage_group_dashboards_filters.png)

- `PROMETHEUS_DS` _(filter)_: filter the selective [Prometheus data sources](https://about.gitlab.com/handbook/engineering/monitoring/#prometheus). Most of the time, you won't need to care about this filter.
- `environment` _(filter)_: filter the environment the metrics are fetched from. The default setting is production (`gprd`). Read more at [Production Environment](https://about.gitlab.com/handbook/engineering/infrastructure/production/architecture/#environments).
- `deploy` _(annotations)_: mark a deployment event on the Gitlab.com SaaS platform.
- `canary-deploy` _(annotations)_: mark a [canary deployment](https://about.gitlab.com/handbook/engineering/#sts=Canary%20Testing) event on the Gitlab.com SaaS platform.
- `feature-flags` _(annotations)_: mark the time point where a feature flag is updated.

This is an example of a feature flag annotation displayed on a dashboard panel:

![Annotations](./img/stage_group_dashboards_annotation.png)

### Metrics panels

#### Notable details
Most of the metrics displayed in the panels are self-explanatory in their title and nearby description, but please note the following:
- The events are counted, measured, accumulated, then collected and stored as [time series](https://prometheus.io/docs/concepts/data_model/). The data are calculated using statistical methods to produce metrics. It means that metrics are approximately correct and meaningful over a time period. They help you have an overview of the stage of a system over time. They are not meant to give you precise numbers of a discrete event. If you need a higher level of accuracy, please look at another monitoring tool like [logs](https://about.gitlab.com/handbook/engineering/monitoring/#logs). Please read the following examples for more explanations.
- All the rate metrics' units are `requests per second`. The default aggregate time frame is 1 minute.
- All the rate metrics are more accurate when the data is big enough. The default floating-point precision is 2. In some extremely low panels, you'll see `0.00` although there is still some real traffic.

#### Examples
![Metrics example 1](./img/stage_group_dashboards_metrics_1.png)

Let's look at an example of a WEB Request panel. Examing 3 consecutive data points of `Projects::RawController#show`:
  + `2020-12-25 00:42:00`: `34.13`. As the default aggregate time frame is 1 minute, it means at the minute 42 (from `2020-12-25 00:42:00` to `2020-12-25 00:42:59` ), there are approximately `34.13 * 60 = ~ 2047` requests processed by the web servers.
  + `2020-12-25 00:43:00`: `31.13`. Similarly, there are approximately `1868` requests from `2020-12-25 00:43:00` to `2020-12-25 00:43:59`
  + `2020-12-25 00:44:00`: `38.27`. Similarly, there are approximately `2296` requests from `2020-12-25 00:44:00` to `2020-12-25 00:44:59`

![Metrics example 2](./img/stage_group_dashboards_metrics_2.png)

Let's look at another example of a Sidekiq Error Rate panel. `RepositoryUpdateMirrorWorker` error rate at `2020-12-25 02:04:00` is `0.07`, equivalent to `4.2`. It's weird, right? It turns out that the data point is rounded up. The raw result is `0.06666666667`, equivalent to `4`. You may encounter this type of gotcha frequently in the future.

#### Inspection and custom queries

To inspect the raw data of the panel for further calculation, click on the Inspect button from the dropdown menu of a panel. Queries, raw data, and panel JSON structure are available. Read more at [Grafana panel inspection](https://grafana.com/docs/grafana/latest/panels/inspect-panel/).

All the dashboards are powered by [Grafana](https://grafana.com/), a frontend for displaying metrics. Grafana consumes the data returned from queries to backend Prometheus data source, then presents them under different visualizations. The stage group dashboards are built to serve the most common use cases so that we provide a limited set of filters, and pre-built queries. Grafana provides a way to explore and visualize the metrics data with [Grafana Explore](https://grafana.com/docs/grafana/latest/explore/). This would require some knowledge about [Prometheus promql query language](https://prometheus.io/docs/prometheus/latest/querying/basics/).

## How to debug with the dashboards?

### Scenario 1: Verify and debug an issue after a deployment
- A team member in the Code Review group has merged an MR and deployed it into the production.
- To verify the deployment, that team member accesses the [Code Review group's dashboard](https://dashboards.gitlab.net/d/stage-groups-code_review/stage-groups-group-dashboard-create-code-review?orgId=1).
- Sidekiq Error Rate panel seems to have an issue. `UpdateMergeRequestsWorker`'s error rate' suddenly increases after their deployment.

![Debug 1](./img/stage_group_dashboards_debug_1.png)

- Clicking on` Kibana: Kibana Sidekiq failed request logs` link in the Extra links session, that member continues filtering for `UpdateMergeRequestsWorker` and skim through the logs.

![Debug 2](./img/stage_group_dashboards_debug_2.png)

- That member opens [Sentry](https://sentry.gitlab.net/gitlab/gitlabcom), filter by transaction type, and correlation_id from a Kibana's result item.

![Debug 3](./img/stage_group_dashboards_debug_3.png)

- Tada, the precise exception, including a stack trace, job arguments, and other information, appears. Happy debugging!

## How to customize the dashboard?

All Grafana dashboards at Gitlab are generated from the [Jsonnet files](https://github.com/grafana/grafonnet-lib) stored in [the runbook project](https://gitlab.com/gitlab-com/runbooks/-/tree/master/dashboards). Particularly, the stage group dashboards definitions are stored in [/dashboards/stage-groups](https://gitlab.com/gitlab-com/runbooks/-/tree/master/dashboards/stage-groups) subfolder in the Runbook. By convention, each group has a corresponding jsonnet file. The dashboards are synced with Gitlab's [stage group data](https://gitlab.com/gitlab-com/www-gitlab-com/-/raw/master/data/stages.yml) every month. Expansion and customization are one of the key principles when we design this system. To customize your group's dashboard, you'll need to edit the corresponding file and follow the [Runbook workflow](https://gitlab.com/gitlab-com/runbooks/-/tree/master/dashboards#dashboard-source). The dashboard will be updated after the MR is merged. Looking at an autogenerated file, for example, [product_planning.dashboard.jsonnet](https://gitlab.com/gitlab-com/runbooks/-/blob/master/dashboards/stage-groups/product_planning.dashboard.jsonnet):

```jsonnet
// This file is autogenerated using scripts/update_stage_groups_dashboards.rb
// Please feel free to customize this file.
local stageGroupDashboards = import './stage-group-dashboards.libsonnet';

stageGroupDashboards.dashboard('product_planning')
.stageGroupDashboardTrailer()
```

We provide basic customization to filter out the components essential to your group's activities. By default, all components `web`, `api`, `git`, and `sidekiq` are available in the dashboard.

```jsonnet
stageGroupDashboards.dashboard('product_planning', components=['web', 'api']).stageGroupDashboardTrailer()
# Or
stageGroupDashboards.dashboard('product_planning', components=['sidekiq']).stageGroupDashboardTrailer()

```

You can aslo append useful information or custom metrics to a dashboard. This is an example that adds some useful links and a total request rate on the top of the page.

```jsonnet
local stageGroupDashboards = import './stage-group-dashboards.libsonnet';
local grafana = import 'github.com/grafana/grafonnet-lib/grafonnet/grafana.libsonnet';
local basic = import 'grafana/basic.libsonnet';

stageGroupDashboards.dashboard('source_code')
.addPanel(
  grafana.text.new(
    title='Group information',
    mode='markdown',
    content=|||
      Useful link for the Source Code Management group dashboard:
      - [Issue list](https://gitlab.com/groups/gitlab-org/-/issues?scope=all&utf8=%E2%9C%93&state=opened&label_name%5B%5D=repository)
      - [Epic list](https://gitlab.com/groups/gitlab-org/-/epics?label_name[]=repository)
    |||,
  ),
  gridPos={ x: 0, y: 0, w: 24, h: 4 }
)
.addPanel(
  basic.timeseries(
    title='Total Request Rate',
    yAxisLabel='Requests per Second',
    decimals=2,
    query=|||
      sum (
        rate(gitlab_transaction_duration_seconds_count{
          env='$environment',
          environment='$environment',
          feature_category=~'source_code_management',
        }[$__interval])
      )
    |||
  ),
  gridPos={ x: 0, y: 0, w: 24, h: 7 }
)
.stageGroupDashboardTrailer()
```

![Stage Group Dashboard Customization](./img/stage_group_dashboards_time_customization.png)

For deeper customization and more complicated metrics, please read [Grafonnet lib](https://github.com/grafana/grafonnet-lib) and [Gitlab Prometheus Metrics](https://docs.gitlab.com/ee/administration/monitoring/prometheus/gitlab_metrics.html#gitlab-prometheus-metrics).
