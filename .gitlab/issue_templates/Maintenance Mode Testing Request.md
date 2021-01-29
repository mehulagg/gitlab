# <Stage name> Crowd-sourced maintenance mode testing

Hi <PM or EM>

The Geo team has finished the implementation of [the MVC for a maintenance mode](https://gitlab.com/groups/gitlab-org/-/epics/2149) and we'd like to crowd-source testing goals for this feature that affects all parts of GitLab.

## What is maintainence mode?

While GitLab is in maintenance, no write requests can be made by non-admin users. 

Users can login and perform other read operations. Maintenance mode is a top requested feature by sys admins and an important step to improve our ability to provide a simple disaster recovery solution. 

## What is this goal of this crowd-sourced testing exercise?

Before we ship this iteration in 13.9, we need your help! Maintenance mode affects the entire application and we want to ensure that we’ve not overlooked any features that are still able to write any data. We’ve already conducted exhaustive tests but found nothing so far!

Engineers/managers know their parts of the product most intimately and can quickly and more thoroughly estimate what their features should behave like in maintenance mode.

**We'd like you to review the documentation and list the top three behaviours that you'd like us to prioritize testing.**

With this we aim to achieve the following goals:

1. Find the most important feature behaviours to test and thus increase test coverage.
1. Improve the feature's documentation.
1. We want to ensure that the first iteration does not break any existing features.
1. Testing out _all_ features in maintenance mode is a very large and time consuming project that can delay our confidence in releasing the feature. So, we wish to pool in resources from all teams developing GitLab.
1. We wish to share knowledge of this feature and give everyone a chance to contribute to manual testing before we release the feature.

That said, we don't plan to delay the release until a blocking bug is found in this test exercise.

## The request

**To be able to ship in 13.9, we ask you to complete the following requested tasks by 2021-02-05.**

Please consider how the feature you develop would be impacted when GitLab is read-only and answer the following questions for us in a comment on this issue:

- [ ] What are the top three behaviours you'd like us to manually test?
- [ ] **Documentation** Review the [documentation for the feature](https://docs.gitlab.com/ee/administration/maintenance_mode/) and answer the following:
  - [ ] Is the behaviour of your feature covered by the documentation? If it doesn't have a sub-section of it's own, do we need to add one, or is the behaviour covered by the overview?
  - [ ] Does the documentation sufficiently inform you of the expected behaviour?
  - [ ] If you'd like any changes made, please mention them in comments below or open an MR.
- [ ] Do you have any concerns relevant to your stage's work, about breaking changes that this feature could introduce?
