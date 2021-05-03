<!-- Title suggestion: [Feature flag] Enable description of feature -->

## Feature

This feature is benind the `:feature_name` feature flag.

<!-- Short description of what the feature is about and link to relevant other issues. -->
- [Issue Name](ISSUE LINK)

## Owners

- Team: NAME_OF_TEAM
- Most appropriate slack channel to reach out to: `#g_TEAM_NAME`
- Best individual to reach out to: NAME
- PM: NAME

## Stakeholders

<!--
Are there any other stages or teams involved that need to be kept in the loop?

- Name of a PM
- The Support Team
- The Delivery Team
-->

## The Rollout Plan

- Partial Rollout on GitLab.com with testing groups
- Rollout on GitLab.com for a certain period (How long)
- Percentage Rollout on GitLab.com
- Rollout Feature for everyone as soon as it's ready

<!-- Which dashboards from https://dashboards.gitlab.net are most relevant? Sentry errors reports can also be useful to review -->

## Testing Groups/Projects

<!-- If applicable, any groups/projects that are happy to have this feature turned on early. Some organizations may wish to test big changes they are interested in with a small subset of users ahead of time for example. -->

- `gitlab-org/gitlab` project
- `gitlab-org`/`gitlab-com` groups
- ...


## Expectations

### What are we expecting to happen?

<!-- Describe the expected outcome when rolling out this feature -->

### What might happen if this goes wrong?

<!-- Should the feature flag be turned off? Any MRs that need to be rolled back? Communication that needs to happen? What are some things you can think of that could go wrong - data loss or broken pages? -->

### What can we monitor to detect problems with this?

<!-- Which dashboards from https://dashboards.gitlab.net are most relevant? -->

## Rollout Steps

### Rollout on non-production environments

- [ ] Enable on non-production environments
    - [ ] `/chatops run feature set feature_name true --dev`
    - [ ] `/chatops run feature set feature_name true --staging`
- [ ] Verify that the feature works as expected

### Priliminary tasks before global rollout on production

- [ ] Check if the feature flag change needs to be accompagnied with a
  [change management issue](https://about.gitlab.com/handbook/engineering/infrastructure/change-management/#feature-flags-and-the-change-management-process).
  Cross link the issue here if it does.
- [ ] Ensure that documentation has been updated ([More info](https://docs.gitlab.com/ee/development/documentation/feature_flags.html#features-that-became-enabled-by-default))
- [ ] Announce on the issue an estimated time this will be enabled on GitLab.com
- [ ] Enable on GitLab.com for [testing groups/projects](#testing-groupsprojects)
    - [ ] `/chatops run feature set --project=gitlab-org/gitlab feature_name true`
- [ ] Verify that the feature works as expected and add details with screenshots as a comment on this issue

### Global rollout on production

- [ ] If it is possible to perform an incremental rollout, this should be preferred. Proposed increments are: `10%`, `50%`, `100%`. Proposed minimum time between increments is 15 minutes.
  - When setting percentages, make sure that the feature works correctly between feature checks. See https://gitlab.com/gitlab-org/gitlab/-/issues/327117 for more information
  - For actor-based rollout: `/chatops run feature set feature_name 10 --actors`
  - For time-based rollout: `/chatops run feature set feature_name 10`
- [ ] Announce on the issue that the flag has been enabled
- [ ] Cross post chatops slack command to `#support_gitlab-com`
  ([more guidance when this is necessary in the dev docs](https://docs.gitlab.com/ee/development/feature_flags/controls.html#where-to-run-commands)) and in your team channel

### Optional: Change the default value of the flag in code

If you're still unsure whether the feature is deemed stable (especially features with security implication)
but needs to release the features in the next blog post,
you can optionally change the default state of the feature flag to make it opt-out.
To do so, follow these steps:

- [ ] Create a merge request to change `default_enabled` attribute of the flag YAML definition to be `true`.
- [ ] Wait until the above MR has landed on production. This usually takes one working day. 
      To make sure that it has been deployed, run `/chatops run auto_deploy status <merge-commit>`.
      If the merge request made in the code cutoff, the feature can official be announced in
      the release blog post.

### Cleanup

After the feature has been confirmed deemed stable on production,
the cleanup should be either done in the next Milestone or as soon as possible.
For more information, please follow [our documentation](https://docs.gitlab.com/ee/development/feature_flags/controls.html#cleaning-up).

<!-- The checklist here is to keep track of it's status for stakeholders -->
- [ ] Create a merge request to remove `:feature_name` feature flag
    - [ ] Remove all references to the feature flag from the codebase
    - [ ] Remove the YAML definitions for the feature from the repository
    - [ ] Create a Changelog Entry
- [ ] Wait until the above MR has landed on production. This usually takes one working day. 
      To make sure that it has been deployed, run `/chatops run auto_deploy status <merge-commit>`.
- [ ] Clean up the feature flag from all environments by running these chatops command in `#production` channel:
    - [ ] `/chatops run feature delete feature_name --dev`
    - [ ] `/chatops run feature delete feature_name --staging`
    - [ ] `/chatops run feature delete feature_name`
- [ ] Close this rollout issue.

## Rollback Steps

- [ ] This feature can be disabled by running the following Chatops command:

```
/chatops run feature set feature_name false
```

/label ~"feature flag"
/assign DRI
