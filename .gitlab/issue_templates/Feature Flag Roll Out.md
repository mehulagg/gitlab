<!-- Title suggestion: [Feature flag] Enable description of feature -->

## Feature

This feature uses the `:feature_name` feature flag!

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

- Partial Rollout on GitLab.com with beta groups
- Rollout on GitLab.com for a certain period (How long)
- Percentage Rollout on GitLab.com
- Rollout Feature for everyone as soon as it's ready

<!-- Which dashboards from https://dashboards.gitlab.net are most relevant? Sentry errors reports can also be useful to review -->

**Beta Groups/Projects:**
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

## Rollout Timeline

<!-- Please check which steps are needed and remove those which don't apply -->

**Rollout Steps**

*Preparation Phase*
- [ ] Enable on staging (`/chatops run feature set feature_name true --staging`)

- [ ] Test on staging

- [ ] Ensure that documentation has been updated ([More info](https://docs.gitlab.com/ee/development/documentation/feature_flags.html#features-that-became-enabled-by-default))

- [ ] Announce on the issue an estimated time this will be enabled on GitLab.com

- [ ] Check if the feature flag change needs to be accompanied with a
      [change management
      issue](https://about.gitlab.com/handbook/engineering/infrastructure/change-management/#feature-flags-and-the-change-management-process). Cross
      link the issue here if it does.

- [ ] Ensure that you or a representative in development can be available for at least 2 hours after feature flag updates in production. If a different developer will be covering, or an exception is needed, please inform the oncall SRE by using the `@sre-oncall` Slack alias.

*Partial Rollout Phase*

- [ ] Enable on GitLab.com for individual groups/projects listed above and verify behaviour (`/chatops run feature set --project=gitlab-org/gitlab feature_name true`)

- [ ] Verify behaviour (See Beta Groups) and add details with screenshots as a comment on this issue

- [ ] If it is possible to perform an incremental rollout, this should be preferred. Proposed increments are: `10%`, `50%`, `100%`. Proposed minimum time between increments is 15 minutes.
  - When setting percentages, make sure that the feature works correctly between feature checks. See https://gitlab.com/gitlab-org/gitlab/-/issues/327117 for more information
  - For actor-based rollout: `/chatops run feature set feature_name 10 --actors`
  - For time-based rollout: `/chatops run feature set feature_name 10`

*Full Rollout Phase*
- [ ] Make the feature flag enabled by default i.e. Change `default_enabled` to `true`

- [ ] Cross post chatops slack command to `#support_gitlab-com` ([more guidance when this is necessary in the dev docs](https://docs.gitlab.com/ee/development/feature_flags/controls.html#where-to-run-commands)) and in your team channel

- [ ] Announce on the issue that the flag has been enabled

- [ ] Create a cleanup issue using the "Feature Flag Removal" template

## Rollback Steps

- [ ] This feature can be disabled by running the following Chatops command:

```
/chatops run feature set --project=gitlab-org/gitlab feature_name false
```

/label ~"feature flag"
/assign DRI
