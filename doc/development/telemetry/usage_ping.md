# Usage Ping Guide

> - [Introduced][ee-557] in GitLab Enterprise Edition 8.10.
> - More statistics [were added][ee-735] in GitLab Enterprise Edition 8.12.
> - [Moved to GitLab Core][ce-23361] in 9.1.
> - More statistics [were added][ee-6602] in GitLab Ultimate 11.2.

This guide provides a details about how usage ping works. It includes the following sections:

1. [What is Usage Ping](#what-is-usage-ping)
1. [Usage Ping payload](#usage-ping-payload)
1. [Disabling Usage Ping](#disabling-usage-ping)
1. [Usage Ping request flow](#usage-ping-request-flow)
1. [How Usage Ping works](#how-usage-ping-works)
1. [Implementing Usage Ping](#implementing-usage-ping)
1. [Developing and testing usage ping](#developing-and-testing-usage-ping)

For more information about Telemetry, see:

- [Telemetry Guide](index.md)
- [Snowplow Guide](snowplow.md)

More useful links:

- [Telemetry Direction](https://about.gitlab.com/direction/telemetry/)
- [Data Analysis Process](https://about.gitlab.com/handbook/business-ops/data-team/#-data-analysis-process)
- [Data for Product Managers](https://about.gitlab.com/handbook/business-ops/data-team/data-for-product-managers/)
- [Data Infrastructure](https://about.gitlab.com/handbook/business-ops/data-team/data-infrastructure/)

## What is Usage Ping

- GitLab sends a weekly payload containing usage data to GitLab Inc. The usage ping uses high-level data to help our product, support, and sales teams. It does not send any project names, usernames, or any other specific data. The information from the usage ping is not anonymous, it is linked to the hostname of the instance. Sending usage ping is optional, and any instance can disable analytics.
- The usage data is primarily composed of row counts for different tables in the instance’s database. By comparing these counts month over month (or week over week), we can get a rough sense for how an instance is using the different features within the product.
- Usage ping is important to GitLab as we use it to calculate our and Stage Monthly Active Users (SMAU) which helps us measure the success of our stages and features.
- Once usage ping is enabled, GitLab will gather data from the other instances and will be able to show usage statistics of your instance to your users.

### Why Should We Enable Usage Ping?

- The main purpose of Usage Ping is to build a better GitLab. Data about how GitLab is used is collected to better understand feature/stage adoption and usage, which helps us understand how GitLab is adding value and helps our team better understand the reasons why people use GitLab and with this knowledge we are able to make better product decisions.
- As a benefit of having the usage ping active, GitLab lets you analyze the users’ activities over time of your GitLab installation.
- As a benefit of having the usage ping active, GitLab provides you with The DevOps Score,which gives you an overview of your entire instance’s adoption of Concurrent DevOps from planning to monitoring.
- You will get better, more proactive support. (assuming that our TAMs and support organization used the data to deliver more value)
- You will get insight and advice into how to get the most value out of your investment in GitLab. Wouldn't you want to know that a number of features or values are not being adopted in your organization?
- You get a report that illustrates how you compare against other similar organizations (anonymized), with specific advice and recommendations on how to improve your DevOps processes.

### Limitations

- Usage Ping does not track frontend events things like page views, link clicks, or user sessions and only focuses on aggregated backend events.
- Because of these limitations we recommend instrumenting your products with Snowplow for more detailed analytics on GitLab.com and use Usage Ping to track aggregated backend events on self-managed.

## Usage Ping payload

You can view the exact JSON payload sent to GitLab Inc. in the administration panel. To view the payload:

1. Navigate to the **Admin Area > Settings > Metrics and profiling**.
1. Expand the **Usage statistics** section.
1. Click the **Preview payload** button.

Here is an example of the payload structure

``` json
{
  "uuid": "0000000-0000-0000-0000-000000000000",
  "hostname": "example.com",
  "version": "12.10.0-pre",
  "installation_type": "omnibus-gitlab",
  "active_user_count": 999,
  "recorded_at": "2020-04-17T07:43:54.162+00:00",
  "edition": "EEU",
  "license_md5": "00000000000000000000000000000000",
  "license_id": null,
  "historical_max_users": 999,
  "licensee": {
    "Name": "ABC, Inc.",
    "Email": "email@example.com",
    "Company": "ABC, Inc."
  },
  "license_user_count": 999,
  "license_starts_at": "2020-01-01",
  "license_expires_at": "2021-01-01",
  "license_plan": "ultimate",
  "license_add_ons": {
  },
  "license_trial": false,
  "counts": {
    "assignee_lists": 999,
    "boards": 999,
    "ci_builds": 999,
    ...
  },
  "container_registry_enabled": true,
  "dependency_proxy_enabled": false,
  "gitlab_shared_runners_enabled": true,
  "gravatar_enabled": true,
  "influxdb_metrics_enabled": true,
  "ldap_enabled": false,
  "mattermost_enabled": false,
  "omniauth_enabled": true,
  "prometheus_metrics_enabled": false,
  "reply_by_email_enabled": "incoming+%{key}@incoming.gitlab.com",
  "signup_enabled": true,
  "web_ide_clientside_preview_enabled": true,
  "ingress_modsecurity_enabled": true,
  "projects_with_expiration_policy_disabled": 999,
  "projects_with_expiration_policy_enabled": 999,
  ...
  "elasticsearch_enabled": true,
  "license_trial_ends_on": null,
  "geo_enabled": false,
  "git": {
    "version": {
      "major": 2,
      "minor": 26,
      "patch": 1
    }
  },
  "gitaly": {
    "version": "12.10.0-rc1-93-g40980d40",
    "servers": 56,
    "filesystems": [
      "EXT_2_3_4"
    ]
  },
  "gitlab_pages": {
    "enabled": true,
    "version": "1.17.0"
  },
  "database": {
    "adapter": "postgresql",
    "version": "9.6.15"
  },
  "app_server": {
    "type": "console"
  },
  "avg_cycle_analytics": {
    "issue": {
      "average": 999,
      "sd": 999,
      "missing": 999
    },
    "plan": {
      "average": null,
      "sd": 999,
      "missing": 999
    },
    "code": {
      "average": null,
      "sd": 999,
      "missing": 999
    },
    "test": {
      "average": null,
      "sd": 999,
      "missing": 999
    },
    "review": {
      "average": null,
      "sd": 999,
      "missing": 999
    },
    "staging": {
      "average": null,
      "sd": 999,
      "missing": 999
    },
    "production": {
      "average": null,
      "sd": 999,
      "missing": 999
    },
    "total": 999
  },
  "usage_activity_by_stage": {
    "configure": {
      "project_clusters_enabled": 999,
      ...
    },
    "create": {
      "merge_requests": 999,
      ...
    },
    "manage": {
      "events": 999,
      ...
    },
    "monitor": {
      "clusters": 999,
      ...
    },
    "package": {
      "projects_with_packages": 999
    },
    "plan": {
      "issues": 999,
      ...
    },
    "release": {
      "deployments": 999,
      ...
    },
    "secure": {
      "user_container_scanning_jobs": 999,
      ...
    },
    "verify": {
      "ci_builds": 999,
      ...
    }
  },
  "usage_activity_by_stage_monthly": {
    "configure": {
      "project_clusters_enabled": 999,
      ...
    },
    "create": {
      "merge_requests": 999,
      ...
    },
    "manage": {
      "events": 999,
      ...
    },
    "monitor": {
      "clusters": 999,
      ...
    },
    "package": {
      "projects_with_packages": 999
    },
    "plan": {
      "issues": 999,
      ...
    },
    "release": {
      "deployments": 999,
      ...
    },
    "secure": {
      "user_container_scanning_jobs": 999,
      ...
    },
    "verify": {
      "ci_builds": 999,
      ...
    }
  }
}
```

## Disabling usage ping

The usage ping is opt-out. If you want to deactivate this feature, go to the Settings page of your administration panel and uncheck the Usage Ping checkbox.

To disable the usage ping and prevent it from being configured in future through the administration panel, Omnibus installs can set the following in [`gitlab.rb`](https://docs.gitlab.com/omnibus/settings/configuration.html#configuration-options):

```ruby
gitlab_rails['usage_ping_enabled'] = false
```

And source installs can set the following in `gitlab.yml`:

```yaml
production: &base
  # ...
  gitlab:
    # ...
    usage_ping_enabled: false
```

## Usage Ping Request Flow

The following example shows a basic request/response flow between a GitLab Instance, the Versions Application, the License Application, Salesforce, GitLab's S3 Bucket, GitLab's Snowflake Data Warehouse, and Sisense.:

```mermaid
sequenceDiagram
    participant GitLab Instance
    participant Versions Application
    participant Licenses Application
    participant Salesforce
    participant S3 Bucket
    participant Snowflake DW
    participant Sisense Dashboards
    GitLab Instance->>Versions Application: Send Usage Ping
    loop Process usage data
        Versions Application->>Versions Application: Parse usage data
        Versions Application->>Versions Application: Write to database
        Versions Application->>Versions Application: Update license ping time
    end
    loop Process data for Salesforce
        Versions Application-xLicenses Application: Request Zuora subscription id
        Licenses Application-xVersions Application: Zuora subscription id
        Versions Application-xSalesforce: Request Zuora account id  by Zuora subscription id
        Salesforce-xVersions Application: Zuora account id
        Versions Application-xSalesforce: Usage data for the Zuora account
    end
    Versions Application->>S3 Bucket: Export Versions database
    S3 Bucket->>Snowflake DW: Import data
    Snowflake DW->>Snowflake DW: Transform data using dbt
    Snowflake DW->>Sisense Dashboards: Data available for querying
    Versions Application->>GitLab Instance: DevOps Score (Conversational Development Index)
```

## How Usage Ping works

1. The Usage Ping [cron job](https://gitlab.com/gitlab-org/gitlab/-/blob/master/app/workers/gitlab_usage_ping_worker.rb#L30) is set in Sidekiq to run weekly.
1. When the cron job runs, it calls [GitLab::UsageData.to_json](https://gitlab.com/gitlab-org/gitlab/-/blob/master/app/services/submit_usage_ping_service.rb#L22).
1. GitLab::UsageData.to_json [cascades down](https://gitlab.com/gitlab-org/gitlab/-/blob/master/lib/gitlab/usage_data.rb#L22) to ~400+ other counter method calls.
1. The response of all methods calls are [merged together](https://gitlab.com/gitlab-org/gitlab/-/blob/master/lib/gitlab/usage_data.rb#L14) into a single JSON payload in GitLab::UsageData.to_json.
1. The JSON payload is then [posted to the Versions application]( https://gitlab.com/gitlab-org/gitlab/-/blob/master/app/services/submit_usage_ping_service.rb#L20).

## Implementing Usage Ping

Usage Ping consists of four types of counters which are all found in `usage_data.rb`:

- **Ordinary Batch Counters:** Simple count of a given ActiveRecord_Relation
- **Distinct Batch Counters:** Distinct count of a given ActiveRecord_Relation on given column
- **Alternative Counters:** Used for settings and configurations
- **Redis Counters:** Used for in-memory counts. This method is being deprecated due to data inaccuracies and will be replaced with a persistent method.

Note: Only use the provided counter methods. Each counter method contains a built in fail safe to isolate each counter to avoid breaking the entire Usage Ping.

### Why batch counting

For large tables, PostgreSQL can take a long time to count rows due to MVCC [(Multi-version Concurrency Control)](https://en.wikipedia.org/wiki/Multiversion_concurrency_control). Batch counting is a counting method where a single large query is broken into multiple smaller queries. For example, instead of a single query querying 1,000,000 records, with batch counting, you can execute 100 queries of 10,000 records each. Batch counting is useful for avoiding database timeouts as each batch query is significantly shorter than one single long running query.

For GitLab.com, there are extremely large tables with 15 second query timeouts, so, we use batch counting to avoid encountering timeouts. Here are the sizes of some GitLab.com tables:

| Table                      | Row counts in millions |
|----------------------------|------------------------|
| merge_request_diff_commits | 2280                   |
| ci_build_trace_sections    | 1764                   |
| merge_request_diff_files   | 1082                   |
| events                     | 514                    |

There are two batch counting methods provided, `Ordinary Batch Counters` and `Distinct Batch Counters`. Batch counting requires indexes on columns to calculate max, min, and range queries. In some cases, a specialized index may need to be added on the columns involved in a counter.

### Ordinary Batch Counters

Handles `ActiveRecord::StatementInvalid` error

Simple count of a given ActiveRecord_Relation

Method: `count(relation, column = nil, batch: true, start: nil, finish: nil)`

Arguments:

- `relation` the ActiveRecord_Relation to perform the count
- `column` the column to perform the count on, by default is the primary key
- `batch`: default `true` in order to use batch counting
- `start`: custom start of the batch counting in order to avoid complex min calculations
- `end`: custom end of the batch counting in order to avoid complex min calculations

Examples:

```ruby
count(User.active)
count(::Clusters::Cluster.aws_installed.enabled, :cluster_id)
count(::Clusters::Cluster.aws_installed.enabled, :cluster_id, start: ::Clusters::Cluster.minimum(:id), finish: ::Clusters::Cluster.maximum(:id))
```

### Distinct Batch Counters

Handles `ActiveRecord::StatementInvalid` error

Distinct count of a given ActiveRecord_Relation on given column

Method: `distinct_count(relation, column = nil, batch: true, start: nil, finish: nil)`

Arguments:

- `relation` the ActiveRecord_Relation to perform the count
- `column` the column to perform the distinct count, by default is the primary key
- `batch`: default `true` in order to use batch counting
- `start`: custom start of the batch counting in order to avoid complex min calculations
- `end`: custom end of the batch counting in order to avoid complex min calculations

Examples:

```ruby
distinct_count(::Project, :creator_id)
distinct_count(::Note.with_suggestions.where(time_period), :author_id, start: ::User.minimum(:id), finish: ::User.maximum(:id))
distinct_count(::Clusters::Applications::CertManager.where(time_period).available.joins(:cluster), 'clusters.user_id')
```

### Redis Counters

Handles `::Redis::CommandError` and `Gitlab::UsageDataCounters::BaseCounter::UnknownEvent`
returns -1 when a block is sent or hash with all values -1 when a `counter(Gitlab::UsageDataCounters)` is sent
different behavior due to 2 different implementations of Redis counter

Method: `redis_usage_data(counter, &block)`

Arguments:

- `counter`: a counter from `Gitlab::UsageDataCounters`, that has `fallback_totals` method implemented
- or a `block`: wich is evaluated

Example of usage:

```ruby
redis_usage_data(Gitlab::UsageDataCounters::WikiPageCounter)
redis_usage_data { ::Gitlab::UsageCounters::PodLogs.usage_totals[:total] }
```

Note that Redis counters are in the [process of being deprecated](https://gitlab.com/gitlab-org/gitlab/-/issues/216330) and you should instead try to use Snowplow events instead. We're in the process of building [self-managed event tracking](https://gitlab.com/gitlab-org/telemetry/-/issues/373) and once this is available, we will convert all Redis counters into Snowplow events.

### Alternative Counters

Handles `StandardError` and fallbacks into -1 this way not all measures fail if we encounter one exception.
Mainly used for settings and configurations.

Method: `alt_usage_data(value = nil, fallback: -1, &block)`

Arguments:

- `value`: a simple static value in wich case the value is simply returned.
- or a `block`: wich is evaluated
- `fallback: -1`: the common value used for any metrics that are failing.

Example of usage:

```ruby
alt_usage_data { Gitlab::VERSION }
alt_usage_data { Gitlab::CurrentSettings.uuid }
alt_usage_data(999)
```

## Developing and testing Usage Ping

### 1. Use your Rails console to manually test counters

```ruby
# count
Gitlab::UsageData.count(User.active)
Gitlab::UsageData.count(::Clusters::Cluster.aws_installed.enabled, :cluster_id)

# count distinct
Gitlab::UsageData.distinct_count(::Project, :creator_id)
Gitlab::UsageData.distinct_count(::Note.with_suggestions.where(time_period), :author_id, start: ::User.minimum(:id), finish: ::User.maximum(:id))
```

### 2. Generate the SQL query

Your Rails console will give back the generated SQL queries.

Example:

```ruby
 pry(main)> Gitlab::UsageData.count(User.active)
   (0.4ms)  SELECT "features"."key" FROM "features"
   (0.7ms)  SELECT MIN("users"."id") FROM "users" WHERE ("users"."state" IN ('active')) AND (ghost IS NOT TRUE) AND ("users"."user_type" IS NULL OR "users"."user_type" NOT IN (2, 1, 3))
   (0.6ms)  SELECT MAX("users"."id") FROM "users" WHERE ("users"."state" IN ('active')) AND (ghost IS NOT TRUE) AND ("users"."user_type" IS NULL OR "users"."user_type" NOT IN (2, 1, 3))
   (0.5ms)  SELECT COUNT("users"."id") FROM "users" WHERE ("users"."state" IN ('active')) AND (ghost IS NOT TRUE) AND ("users"."user_type" IS NULL OR "users"."user_type" NOT IN (2, 1, 3)) AND "users"."id" BETWEEN 0 AND 99999
```

### 3. Optimize queries with #database-lab

Paste the SQL query into `#database-lab` to see how the query performs at scale.

- #database-lab is a Slack channel which uses a production-sized environment to test your queries
- GitLab.com’s production database has a 15 second timeout.
- For each query we require an execution time of under 1 second due do cold caches which can 10x this time.
- Add a specialized index on columns involved to reduce your the execution time.

In order to have an understanding of the queries execution we add in the MR description the following information

For counters that have a `time_period` test and add information for both cases.

- with `time_period = {}` for all time period
- and `time_period = { created_at: 28.days.ago..Time.current }` for last 28 days period

Execution plan and query time before and after optimization

Using database-lab and [explain.depesz.com](https://explain.depesz.com/) see more details in [database review guide](../database_review.md#preparation-when-adding-or-modifying-queries)

Query generated for the index and time

Using database-lab

Migration output for up and down execution

Examples of query optimization work:

- [Example 1](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/26445)
- [Example 2](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/26871)

### 4. Ask for a Telemetry Review

On GitLab.com, we have DangerBot setup to monitor Telemetry related files and DangerBot will recommend a Telemetry review. Simply `@gitlab-org/growth/telemetry/engineers` in your MR for a review.

## Usage Statistics definitions

| Statistic | Section  | Stage    | Description   |
|:--|:--|:--|:--|
|`uuid`||||
|`hostname`||||
|`version`||||
|`installation_type`||||
|`active_user_count`||||
|`recorded_at`||||
|`edition`||||
|`license_md5`||||
|`license_id`||||
|`historical_max_users`||||
|`Name`|`licensee`|||
|`Email`|`licensee`|||
|`Company|licensee`|||
|`license_user_count`||||
|`license_starts_at`||||
|`license_expires_at`||||
|`license_plan`||||
|`license_trial`||||
|`assignee_lists`|`counts`|||
|`boards`|`counts`|||
|`ci_builds`|`counts`|||
|`ci_internal_pipelines`|`counts`|||
|`ci_external_pipelines`|`counts`|||
|`ci_pipeline_config_auto_devops`|`counts`|||
|`ci_pipeline_config_repository`|`counts`|||
|`ci_runners`|`counts`|||
|`ci_triggers`|`counts`|||
|`ci_pipeline_schedules`|`counts`|||
|`auto_devops_enabled`|`counts`|||
|`auto_devops_disabled`|`counts`|||
|`deploy_keys`|`counts`|||
|`deployments`|`counts`|||
|`dast_jobs`|`counts`|||
|`successful_deployments`|`counts`|||
|`failed_deployments`|`counts`|||
|`environments`|`counts`|||
|`clusters`|`counts`|||
|`clusters_enabled`|`counts`|||
|`project_clusters_enabled`|`counts`|||
|`group_clusters_enabled`|`counts`|||
|`instance_clusters_enabled`|`counts`|||
|`clusters_disabled`|`counts`|||
|`project_clusters_disabled`|`counts`|||
|`group_clusters_disabled`|`counts`|||
|`instance_clusters_disabled`|`counts`|||
|`clusters_platforms_eks`|`counts`|||
|`clusters_platforms_gke`|`counts`|||
|`clusters_platforms_user`|`counts`|||
|`clusters_applications_helm`|`counts`|||
|`clusters_applications_ingress`|`counts`|||
|`clusters_applications_cert_managers`|`counts`|||
|`clusters_applications_crossplane`|`counts`|||
|`clusters_applications_prometheus`|`counts`|||
|`clusters_applications_runner`|`counts`|||
|`clusters_applications_knative`|`counts`|||
|`clusters_applications_elastic_stack`|`counts`|||
|`clusters_management_project`|`counts`|||
|`in_review_folder`|`counts`|||
|`grafana_integrated_projects`|`counts`|||
|`groups`|`counts`|||
|`issues`|`counts`|||
|`issues_created_from_gitlab_error_tracking_ui`|`counts`|||
|`issues_with_associated_zoom_link`|`counts`|||
|`issues_using_zoom_quick_actions`|`counts`|||
|`issues_with_embedded_grafana_charts_approx`|`counts`|||
|`issues_with_health_status`|`counts`|||
|`keys`|`counts`|||
|`label_lists`|`counts`|||
|`lfs_objects`|`counts`|||
|`milestone_lists`|`counts`|||
|`milestones`|`counts`|||
|`pages_domains`|`counts`|||
|`pool_repositories`|`counts`|||
|`projects`|`counts`|||
|`projects_imported_from_github`|`counts`|||
|`projects_with_repositories_enabled`|`counts`|||
|`projects_with_error_tracking_enabled`|`counts`|||
|`protected_branches`|`counts`|||
|`releases`|`counts`|||
|`remote_mirrors`|`counts`|||
|`requirements_created`|`counts`|||
|`snippets`|`counts`|||
|`suggestions`|`counts`|||
|`todos`|`counts`|||
|`uploads`|`counts`|||
|`web_hooks`|`counts`|||
|`projects_alerts_active`|`counts`|||
|`projects_asana_active`|`counts`|||
|`projects_assembla_active`|`counts`|||
|`projects_bamboo_active`|`counts`|||
|`projects_bugzilla_active`|`counts`|||
|`projects_buildkite_active`|`counts`|||
|`projects_campfire_active`|`counts`|||
|`projects_custom_issue_tracker_active`|`counts`|||
|`projects_discord_active`|`counts`|||
|`projects_drone_ci_active`|`counts`|||
|`projects_emails_on_push_active`|`counts`|||
|`projects_external_wiki_active`|`counts`|||
|`projects_flowdock_active`|`counts`|||
|`projects_github_active`|`counts`|||
|`projects_hangouts_chat_active`|`counts`|||
|`projects_hipchat_active`|`counts`|||
|`projects_irker_active`|`counts`|||
|`projects_jenkins_active`|`counts`|||
|`projects_jira_active`|`counts`|||
|`projects_mattermost_active`|`counts`|||
|`projects_mattermost_slash_commands_active`|`counts`|||
|`projects_microsoft_teams_active`|`counts`|||
|`projects_packagist_active`|`counts`|||
|`projects_pipelines_email_active`|`counts`|||
|`projects_pivotaltracker_active`|`counts`|||
|`projects_prometheus_active`|`counts`|||
|`projects_pushover_active`|`counts`|||
|`projects_redmine_active`|`counts`|||
|`projects_slack_active`|`counts`|||
|`projects_slack_slash_commands_active`|`counts`|||
|`projects_teamcity_active`|`counts`|||
|`projects_unify_circuit_active`|`counts`|||
|`projects_webex_teams_active`|`counts`|||
|`projects_youtrack_active`|`counts`|||
|`projects_slack_notifications_active`|`counts`|||
|`projects_slack_slash_active`|`counts`|||
|`projects_jira_server_active`|`counts`|||
|`projects_jira_cloud_active`|`counts`|||
|`projects_jira_dvcs_cloud_active`|`counts`|||
|`projects_jira_dvcs_server_active`|`counts`|||
|`labels`|`counts`|||
|`merge_requests`|`counts`|||
|`notes`|`counts`|||
|`wiki_pages_create`|`counts`|||
|`wiki_pages_update`|`counts`|||
|`wiki_pages_delete`|`counts`|||
|`web_ide_commits`|`counts`|||
|`web_ide_views`|`counts`|||
|`web_ide_merge_requests`|`counts`|||
|`web_ide_previews`|`counts`|||
|`snippet_comment`|`counts`|||
|`commit_comment`|`counts`|||
|`merge_request_comment`|`counts`|||
|`snippet_create`|`counts`|||
|`snippet_update`|`counts`|||
|`navbar_searches`|`counts`|||
|`cycle_analytics_views`|`counts`|||
|`productivity_analytics_views`|`counts`|||
|`source_code_pushes`|`counts`|||
|`merge_request_create`|`counts`|||
|`design_management_designs_create`|`counts`|||
|`design_management_designs_update`|`counts`|||
|`design_management_designs_delete`|`counts`|||
|`licenses_list_views`|`counts`|||
|`user_preferences_group_overview_details`|`counts`|||
|`user_preferences_group_overview_security_dashboard`|`counts`|||
|`ingress_modsecurity_logging`|`counts`|||
|`ingress_modsecurity_blocking`|`counts`|||
|`ingress_modsecurity_disabled`|`counts`|||
|`ingress_modsecurity_not_installed`|`counts`|||
|`dependency_list_usages_total`|`counts`|||
|`epics`|`counts`|||
|`feature_flags`|`counts`|||
|`geo_nodes`|`counts`|||
|`incident_issues`|`counts`|`monitor`|Issues created by the alert bot||
|`alert_bot_incident_issues`|`counts`|`monitor`|Issues created by the alert bot||
|`incident_labeled_issues`|`counts`|`monitor`|Issues with the incident label||
|`issues_created_gitlab_alerts`|`counts`|`monitor`|issues created from alerts by non-alert bot users||
|`ldap_group_links`|`counts`|||
|`ldap_keys`|`counts`|||
|`ldap_users`|`counts`|||
|`pod_logs_usages_total`|`counts`|||
|`projects_enforcing_code_owner_approval`|`counts`|||
|`projects_mirrored_with_pipelines_enabled`|`counts`|||
|`projects_reporting_ci_cd_back_to_github`|`counts`|||
|`projects_with_packages`|`counts`|||
|`projects_with_prometheus_alerts`|`counts`|||
|`projects_with_tracing_enabled`|`counts`|||
|`projects_with_alerts_service_enabled`|`counts`|||
|`template_repositories`|`counts`|||
|`container_scanning_jobs`|`counts`|||
|`dependency_scanning_jobs`|`counts`|||
|`license_management_jobs`|`counts`|||
|`sast_jobs`|`counts`|||
|`status_page_projects`|`counts`|`monitor`||
|`status_page_issues`|`counts`|`monitor`||
|`epics_deepest_relationship_level`|`counts`|||
|`operations_dashboard_default_dashboard`|`counts`|||
|`operations_dashboard_users_with_projects_added`|`counts`|||
|`container_registry_enabled`||||
|`dependency_proxy_enabled`||||
|`gitlab_shared_runners_enabled`||||
|`gravatar_enabled`||||
|`ldap_enabled`||||
|`mattermost_enabled`||||
|`omniauth_enabled`||||
|`prometheus_metrics_enabled`||||
|`reply_by_email_enabled`||||
|`signup_enabled`||||
|`web_ide_clientside_preview_enabled`||||
|`ingress_modsecurity_enabled`||||
|`elasticsearch_enabled`||||
|`license_trial_ends_on`||||
|`geo_enabled`||||
|`version`|Git|||
|`version`|Gitaly|||
|`servers`|Gitaly|||
|`filesystems`|Gitaly|||
|`enabled`|`gitlab_pages`|||
|`version`|`gitlab_pages`|||
|`adapter`|`database`|||
|`version`|`database`|||
|`average`|`avg_cycle_analytics - issue`|||
|`sd`|`avg_cycle_analytics - issue`|||
|`missing`|`avg_cycle_analytics - issue`|||
|`average`|`avg_cycle_analytics - plan`|||
|`sd`|`avg_cycle_analytics - plan`|||
|`missing`|`avg_cycle_analytics - plan|||
|`average`|`avg_cycle_analytics - code`|||
|`sd`|`avg_cycle_analytics - code`|||
|`missing`|`avg_cycle_analytics - code`|||
|`average`|`avg_cycle_analytics - test`|||
|`sd`|`avg_cycle_analytics - test`|||
|`missing`|`avg_cycle_analytics - test`|||
|`average`|`avg_cycle_analytics - review`|||
|`sd`|`avg_cycle_analytics - review`|||
|`missing`|`avg_cycle_analytics - review`|||
|`average`|`avg_cycle_analytics - staging`|||
|`sd`|`avg_cycle_analytics - staging`|||
|`missing`|`avg_cycle_analytics - staging`|||
|`average`|`avg_cycle_analytics - production`|||
|`sd`|`avg_cycle_analytics - production`|||
|`missing`|`avg_cycle_analytics - production`|||
|`total`|`avg_cycle_analytics`|||
|`clusters_applications_cert_managers`|`usage_activity_by_stage`|`configure`||
|`clusters_applications_helm`|`usage_activity_by_stage`|`configure`||
|`clusters_applications_ingress`|`usage_activity_by_stage`|`configure`||
|`clusters_applications_knative`|`usage_activity_by_stage`|`configure`||
|`clusters_management_project`|`usage_activity_by_stage`|`configure`||
|`clusters_disabled`|`usage_activity_by_stage`|`configure`||
|`clusters_enabled`|`usage_activity_by_stage`|`configure`||
|`clusters_platforms_gke`|`usage_activity_by_stage`|`configure`||
|`clusters_platforms_eks`|`usage_activity_by_stage`|`configure`||
|`clusters_platforms_user`|`usage_activity_by_stage`|`configure`||
|`instance_clusters_disabled`|`usage_activity_by_stage`|`configure`||
|`instance_clusters_enabled`|`usage_activity_by_stage`|`configure`||
|`group_clusters_disabled`|`usage_activity_by_stage`|`configure`||
|`group_clusters_enabled`|`usage_activity_by_stage`|`configure`||
|`project_clusters_disabled`|`usage_activity_by_stage`|`configure`||
|`project_clusters_enabled`|`usage_activity_by_stage`|`configure`||
|`projects_slack_notifications_active`|`usage_activity_by_stage`|`configure`||
|`projects_slack_slash_active`|`usage_activity_by_stage`|`configure`||
|`projects_with_prometheus_alerts: 0`|`usage_activity_by_stage`|`configure`||
|`deploy_keys`|`usage_activity_by_stage`|`create`||
|`keys`|`usage_activity_by_stage`|`create`||
|`merge_requests`|`usage_activity_by_stage`|`create`||
|`projects_enforcing_code_owner_approval`|`usage_activity_by_stage`|`create`||
|`projects_imported_from_github`|`usage_activity_by_stage`|`create`||
|`projects_with_repositories_enabled`|`usage_activity_by_stage`|`create`||
|`protected_branches`|`usage_activity_by_stage`|`create`||
|`remote_mirrors`|`usage_activity_by_stage`|`create`||
|`snippets`|`usage_activity_by_stage`|`create`||
|`suggestions: 0`|`usage_activity_by_stage`|`create`||
|`groups`|`usage_activity_by_stage`|`manage`||
|`ldap_keys`|`usage_activity_by_stage`|`manage`||
|`ldap_users: 0`|`usage_activity_by_stage`|`manage`||
|`users_created`|`usage_activity_by_stage`|`manage`||
|`clusters`|`usage_activity_by_stage`|`monitor`||
|`clusters_applications_prometheus`|`usage_activity_by_stage`|`monitor`||
|`operations_dashboard_default_dashboard`|`usage_activity_by_stage`|`monitor`||
|`operations_dashboard_users_with_projects_added`|`usage_activity_by_stage`|`monitor`||
|`projects_prometheus_active`|`usage_activity_by_stage`|`monitor`||
|`projects_with_error_tracking_enabled`|`usage_activity_by_stage`|`monitor`||
|`projects_with_tracing_enabled: 0`|`usage_activity_by_stage`|`monitor`||
|`projects_with_packages: 0`|`usage_activity_by_stage`|package||
|`assignee_lists`|`usage_activity_by_stage`|`plan`||
|`epics`|`usage_activity_by_stage`|`plan`||
|`issues`|`usage_activity_by_stage`|`plan`||
|`label_lists`|`usage_activity_by_stage`|`plan`||
|`milestone_lists`|`usage_activity_by_stage`|`plan`||
|`notes`|`usage_activity_by_stage`|`plan`||
|`projects`|`usage_activity_by_stage`|`plan`||
|`projects_jira_active`|`usage_activity_by_stage`|`plan`||
|`projects_jira_dvcs_cloud_active`|`usage_activity_by_stage`|`plan`||
|`projects_jira_dvcs_server_active`|`usage_activity_by_stage`|`plan`||
|`service_desk_enabled_projects`|`usage_activity_by_stage`|`plan`||
|`service_desk_issues`|`usage_activity_by_stage`|`plan`||
|`todos: 0`|`usage_activity_by_stage`|`plan`||
|`deployments`|`usage_activity_by_stage`|`release`||
|`failed_deployments`|`usage_activity_by_stage`|`release`||
|`projects_mirrored_with_pipelines_enabled`|`usage_activity_by_stage`|`release`||
|`releases`|`usage_activity_by_stage`|`release`||
|`successful_deployments: 0`|`usage_activity_by_stage`|`release`||
|`user_preferences_group_overview_security_dashboard: 0`|`usage_activity_by_stage`|`secure`||
|`ci_builds`|`usage_activity_by_stage`|`verify`||
|`ci_external_pipelines`|`usage_activity_by_stage`|`verify`||
|`ci_internal_pipelines`|`usage_activity_by_stage`|`verify`||
|`ci_pipeline_config_auto_devops`|`usage_activity_by_stage`|`verify`||
|`ci_pipeline_config_repository`|`usage_activity_by_stage`|`verify`||
|`ci_pipeline_schedules`|`usage_activity_by_stage`|`verify`||
|`ci_pipelines`|`usage_activity_by_stage`|`verify`||
|`ci_triggers`|`usage_activity_by_stage`|`verify`||
|`clusters_applications_runner`|`usage_activity_by_stage`|`verify`||
|`projects_reporting_ci_cd_back_to_github: 0`|`usage_activity_by_stage`|`verify`||
