## Description

As the name implies, the purpose of the template is to detail underperforming queries for futher investigation.

### Steps

- [ ] Rename the issue to - `Query Performance Investigation - [Query Snippet | Table info]`
  - For example - `Query Performance Investigation - SELECT "namespaces".* FROM "namespaces" WHERE "namespaces"."id" = $1 LIMIT $2`
- [ ] Provide information in the Requested Data Points table
- [ ] Provide [priority and severity labels](https://about.gitlab.com/handbook/engineering/quality/issue-triage/#availability)
- [ ] If this requires immediate attention cc `@gitlab-org/database-team` and reach out in the #g_database slack channel

### Requested Data points

Please provide as many of these fields as possible when submitting a query performance report.

| Metric | Measurement |
|--------|-------------|
| TPS |  |
| Duration |  |
| Source of calls | Sidekiq, WebAPI, etc |
| Query ID | | 
| SQL Statement | | 
| Query Plan | | 
| Query Example | | 
| Total number of calls (relative) |  |
| % of Total time |  |

<!--

- Example of a postgres checkup report - https://gitlab.com/gitlab-com/gl-infra/infrastructure/-/snippets/2056787
- Epic - Improving the Database resource usage (&365) - https://gitlab.com/groups/gitlab-com/gl-infra/-/epics/365#reports-of-database-performance-peak-investigation-analysis-executed

-->

/label ~"group::database" ~"database::validation"
