<!-- Title suggestion: [Feature flag] Enable description of feature -->

## What

Remove the `:feature_name` feature flag ...

## Owners

- Team: NAME_OF_TEAM
- Most appropriate slack channel to reach out to: `#g_TEAM_NAME`
- Best individual to reach out to: NAME

## Expectations

### What are we expecting to happen?

### What might happen if this goes wrong?

### What can we monitor to detect problems with this?

<!-- Which dashboards from https://dashboards.gitlab.net are most relevant? -->

## Beta groups/projects

If applicable, any groups/projects that are happy to have this feature turned on early. Some organizations may wish to test big changes they are interested in with a small subset of users ahead of time for example.

- `gitlab-org/gitlab` project
- `gitlab-org`/`gitlab-com` groups
- ...

## Roll Out Steps

- [ ] Confirm that QA tests pass with the feature flag enabled (if you're unsure how, contact the relevant [stable counterpart in the Quality department](https://about.gitlab.com/handbook/engineering/quality/#individual-contributors))
- [ ] Enable on staging (`/chatops run feature set feature_name true --staging`)
- [ ] Test on staging
- [ ] Ensure that documentation has been updated
- [ ] Enable on GitLab.com for individual groups/projects listed above and verify behaviour  (`/chatops run feature set --project=gitlab-org/gitlab feature_name true`)
- [ ] Coordinate a time to enable the flag with the SRE oncall and release managers
  - In `#production` mention `@sre-oncall` and `@release-managers`. Once an SRE on call and Release Manager on call confirm, you can proceed with the rollout
- [ ] Announce on the issue an estimated time this will be enabled on GitLab.com
- [ ] Enable on GitLab.com by running chatops command in `#production` (`/chatops run feature set feature_name true`)
- [ ] Cross post chatops Slack command to `#support_gitlab-com` ([more guidance when this is necessary in the dev docs](https://docs.gitlab.com/ee/development/feature_flags/controls.html#where-to-run-commands)) and in your team channel
- [ ] Announce on the issue that the flag has been enabled on gitlab.com
- [ ] Enable the feature by default at source code level by setting `true` to the [`default_enabled`](https://docs.gitlab.com/ee/development/feature_flags/development.html#feature-flag-definition-and-validation).
  - [ ] (Required) Add a [changelog](https://docs.gitlab.com/ee/development/changelog.html) entry
  - [ ] (Optional) Enable [Auto Clean Up](#option-1-auto-cleanup-recommended) by setting `true` to the [`auto_clean_up`](https://docs.gitlab.com/ee/development/feature_flags/development.html#feature-flag-definition-and-validation) in the same merge request.
- [ ] Congrats! :tada: Your feature can be officially mentioned in a monthly release blog post.
      You can also close an associated feature implementation issue if any.

### Rollback Steps

- [ ] This feature can be disabled by running the following Chatops command:

```
/chatops run feature set --project=gitlab-org/gitlab feature_name false
```

## Clean up after roll out

In order to close this rollout issue, you must remove the feature flag definition
from the source code. There are several options to clean up this feature flag and associated data.
Please choose one of them from the following options:

### Option 1: Auto cleanup (Recommended)

- [ ] Set `true` to [`auto_clean_up`](https://docs.gitlab.com/ee/development/feature_flags/development.html#feature-flag-definition-and-validation).
      GitLab will take care of the cleanup for your feature flag.
      For more information, see [the documentation](https://docs.gitlab.com/ee/development/feature_flags/controls.html#auto-clean-up)

### Option 2: Manual cleanup

- [ ] Remove feature flag and add changelog entry
- [ ] After the flag removal is deployed, [clean up the feature flag](https://docs.gitlab.com/ee/development/feature_flags/controls.html#cleaning-up) by running chatops command in `#production` channel

/label ~"feature flag"
