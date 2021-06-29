---
stage: Create
group: Gitaly
info: "To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#assignments"
type: reference
---

# Gitaly timeouts **(FREE SELF)**

[Gitaly](../../../administration/gitaly/index.md) timeouts are configurable. The timeouts can be
configured to make sure that long-running Gitaly calls don't needlessly take up resources.

To access Gitaly timeout settings:

1. On the top bar, select **Menu >** **{admin}** **Admin**.
1. On the left sidebar, select **Settings > Preferences**.
1. Expand the **Gitaly timeouts** section.

## Available timeouts

The following timeouts are available.

| Timeout | Default    | Desciption                                                                                                                                                                                                                                                                               |
|:--------|:-----------|:-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| Default | 55 seconds | Timeout for Gitaly calls from the GitLab application (not enforced for `git` `fetch` and `push` operations, or Sidekiq jobs). Makes sure that Gitaly calls made within a web request cannot exceed the entire request timeout. It should be shorter than the worker timeout that can be configured for [Puma](https://docs.gitlab.com/omnibus/settings/puma.html#puma-settings). If a Gitaly call timeout would exceed the worker timeout, the remaining time from the worker timeout would be used to avoid having to terminate the worker. |
| Fast    | 10 seconds | Timeout for very short Gitaly calls.                                                                                                                                                                                                                                                     |
| Medium  | 30 seconds | Timeout that should be set between Default and Fast.                                                                                                                                                                                                                                     |
