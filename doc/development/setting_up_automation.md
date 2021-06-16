---
stage: none
group: unassigned
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#assignments
---

# Setting up automation and access token best practices

We have many automation in place, for various use-cases, such as:

- [Danger bot](dangerbot.md) for merge request hygiene
- [Triage ops](https://gitlab.com/gitlab-org/quality/triage-ops) for automated scheduled triage of issues, and merge requests
- [Triage serverless](https://gitlab.com/gitlab-org/quality/triage-serverless) for real-time triage/reaction of issues, and merge requests
- [Multi-project pipeline polling](https://docs.gitlab.com/ee/development/testing_guide/review_apps.html#cicd-architecture-diagram)
  for fetching status of downstream pipelines [while we cannot use the `trigger` keyword](https://gitlab.com/gitlab-org/omnibus-gitlab/-/issues/6118)
- Async retrospective generation
- GitLab Runner releases
- Mirroring projects

Usually, these automations involve using the authenticated API (for instance, to comment on issues), hence require a valid token.

## Token best practices

### Default to using Project access tokens

By default, and when possible, create a new [Project access tokens](../user/project/settings/project_access_tokens.md), and follow these guidelines:

- Set a relevant name for the access token and keep in mind that it will be used as the Name of the bot user created for the token
- You don't need to set an expiration date for the token, unless this is for a temporary automation
- Give the token the minimum scopes your automation requires (usually the `api` scope)

Project access tokens have [a few known limitations](https://gitlab.com/gitlab-org/gitlab/-/issues/213536), but dogfooding them can only help us improve the feature.

### Use a specific service account token when Project access tokens can't be used

For use-cases where a Project access tokens can't be used (if any), we plan to introduce dedicated service accounts owned by a specific team.

Following are examples of potential service accounts that we may create:

- `@gitlab-triage-bot`: Used for triage operations: `gitlab-org/quality/triage-ops`, `gitlab-org/quality/triage-serverless`, `gitlab-org/gitlab-triage`. Owned by the Engineering Productivity team.
- `@gitlab-release-bot`: Used for release-related operations (EE->CE sync, `gitlab-org/gitlab-runner` releases, update of GitLab projects Releases page). Owned by the Delivery team.
- `@gitlab-pipeline-bot`: Used for operations that are critical for pipelines (Danger, multi-project triggering/polling). Owned by the Engineering Productivity team.
- `@gitlab-mirror-bot`: Used for mirroring projects. Owned by the Delivery team.
- `@gitlab-tooling-bot`: Used for tooling scripts/actions (`gitlab-org/quality/toolbox`, automatic Frontend Renovate MRs, `frontend/playground/webpack-memory-metrics`, `gitlab-org/security-products/analyzers/license-finder`). Owned by the Engineering Productivity team.

### Don't reuse an existing token

Never reuse an existing token for your own automation, as this makes it harder to track what a token is used for, and increases the number of changes required in the case the token is revoked.

## Background on the single `@gitlab-bot` service account

In the past, we used to have a single `@gitlab-bot` service account which we used for almost all our automations.

This had two main drawbacks:

1. The bot might [hit the API rate limit](https://gitlab.com/gitlab-org/quality/team-tasks/-/issues/907), so we had to disable it. Disabling the rate limit had the
   consequences that an infinite-loop script could [lead to a DDoS against our own API](https://gitlab.com/gitlab-com/gl-infra/production/-/issues/4655).
1. From a security perspective, reusing the same token everywhere creates a lot of disruption in the event
   [the token is leaked and needs to be rotated](https://gitlab.com/gitlab-com/gl-security/security-operations/sirt/operations/-/issues/1451).

Also, the fact that the service account's credentials were accessible to all the Engineering division was problematic as anyone could log into the bot's account
and create their own access token.

We are in the process of:

1. [Moving the `@gitlab-bot` service account credentials to an Engineering Productivity 1Password vault](https://gitlab.com/gitlab-com/gl-security/security-operations/sirt/operations/-/issues/1082), to stop the self-serving of tokens creation.
1. [Migrating the current `@gitlab-bot`'s tokens to Project access tokens where possible and to specific service accounts for the other use-cases](https://gitlab.com/groups/gitlab-org/quality/-/epics/17).
