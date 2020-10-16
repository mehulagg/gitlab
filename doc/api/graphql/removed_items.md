# GraphQL API removed items

GraphQL is a versionless API, unlike the REST API.
Occasionally, items have to be updated or removed from the GraphQL API.
According to our [process for removing items](index.md#deprecation-process), here are the items that have been removed.

## GitLab 13.6

Fields removed in GitLab 13.6 ([!44866](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/44866)):

| GraphQL type         | Field name           | Deprecated in | Use instead                |
| -------------------- | -------------------- | ------------- | -------------------------- |
| `Commit`             | `latestPipeline`     | 12.5          | `pipelines`                |
| `GrafanaIntegration` | `token`              | 12.7          | None. Plaintext tokens no longer supported for security reasons. |
| `Issue`, `EpicIssue` | `designs`            | 12.2          | `designCollection`         |
| `MergeRequest`       | `mergeCommitMessage` | 11.8          | `latestMergeCommitMessage` |
| `Timelog`            | `date`               | 12.10         | `spentAt`                  |
