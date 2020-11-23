<!-- Title suggestion: [Experiment Name] Successful Cleanup -->

## Summary

The experiment is currently rolled out to 100% of users and has been deemed a success.
This now needs to work as it does as part of the product.

## Steps

- [ ] Determine whether the feature should apply to SaaS and/or self-managed
- [ ] Determine whether the feature should apply to EE - and which tiers - and/or Core
- [ ] Determine if tracking should be kept as is, removed or modified.
- [ ] Migrate experiment to a default enabled [feature flag](https://docs.gitlab.com/ee/development/feature_flags/development.html) for one milestone and add a changelog.
- [ ] Ensure any relevant documentation has been updated.
- [ ] In the next milestone, [remove the feature flag](https://docs.gitlab.com/ee/development/feature_flags/controls.html#cleaning-up).
- [ ] After the flag removal is deployed, [clean up the feature/experiment feature flags](https://docs.gitlab.com/ee/development/feature_flags/controls.html#cleaning-up) by running chatops command in `#production` channel
