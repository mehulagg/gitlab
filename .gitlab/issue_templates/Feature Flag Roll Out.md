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

<!-- Describe how the feature should be rolled out, and check the right boxes. You can check multiple if applicable -->

- [ ] Partial Rollout on GitLab.com with beta groups
- [ ] Rollout on GitLab.com for a certain period (How long)
- [ ] Percentage Rollout on GitLab.com - XX%
- [ ] Rollout Feature for everyone as soon as it's ready

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

## Roll Out Steps

<!-- Please check which steps are needed and remove those which don't apply -->

**Initial Rollout**

- [ ] Enable on staging
- [ ] Test on staging
- [ ] Ensure that documentation has been updated ([More info](https://docs.gitlab.com/ee/development/documentation/feature_flags.html#features-that-became-enabled-by-default))
- [ ] Enable on GitLab.com for individual groups/projects listed above
- [ ] Verify behaviour (See Beta Groups) and add details with screenshots as a comment on this issue


**General Availability** ([More Info](https://docs.gitlab.com/ee/development/feature_flags/controls.html#communicate-the-change))
<!-- The next two are probably only needed for high visibility and/or critical rollouts. Please refer to the official documentation linked above for more clarification -->

- [ ] Coordinate a time to enable the flag with `#production` and `#g_delivery` on slack.
- [ ] Announce on the issue an estimated time this will be enabled on GitLab.com
- [ ] Enable on GitLab.com by running chatops command in `#production`
- [ ] Cross post chatops slack command to `#support_gitlab-com` ([more guidance when this is necessary in the dev docs](https://docs.gitlab.com/ee/development/feature_flags/controls.html#where-to-run-commands)) and in your team channel
- [ ] Announce on the issue that the flag has been enabled


**Cleanup**

- [ ] Remove `:feature_name` feature flag and add changelog entry
- [ ] After the flag removal is deployed, [clean up the feature flag](https://docs.gitlab.com/ee/development/feature_flags/controls.html#cleaning-up) by running chatops command in `#production` channel


/label ~"feature flag"
