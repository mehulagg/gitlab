---
stage: none
group: unassigned
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#assignments
---

# Testing with feature flags

To run a specific test with a feature flag enabled you can use the `QA::Runtime::Feature` class to
enable and disable feature flags ([via the API](../../../api/features.md)).

Note that administrator authorization is required to change feature flags. `QA::Runtime::Feature`
automatically authenticates as an administrator as long as you provide an appropriate access
token via `GITLAB_QA_ADMIN_ACCESS_TOKEN` (recommended), or provide `GITLAB_ADMIN_USERNAME`
and `GITLAB_ADMIN_PASSWORD`.

Please be sure to include the tag `:requires_admin` so that the test can be skipped in environments
where admin access is not available.

WARNING:
You are strongly advised to [enable feature flags only for a group, project, user](../../feature_flags/development.md#feature-actors),
or [feature group](../../feature_flags/development.md#feature-groups). This makes it possible to
test a feature in a shared environment without affecting other users.

For example, the code below would enable a feature flag named `:feature_flag_name` for the project
created by the test:

```ruby
RSpec.describe "with feature flag enabled", :requires_admin do
  let(:project) { Resource::Project.fabricate_via_api! }

  before do
    Runtime::Feature.enable(:feature_flag_name, project: project)
  end

  it "feature flag test" do
    # Execute the test with the feature flag enabled.
    # It will only affect the project created in this test.
  end

  after do
    Runtime::Feature.disable(:feature_flag_name, project: project)
  end
end
```

Note that the `enable` and `disable` methods first set the flag and then check that the updated
value is returned by the API.

Similarly, you can enable a feature for a group, user, or feature group:

```ruby
group = Resource::Group.fabricate_via_api!
Runtime::Feature.enable(:feature_flag_name, group: group)

user = Resource::User.fabricate_via_api!
Runtime::Feature.enable(:feature_flag_name, user: user)

feature_group = "a_feature_group"
Runtime::Feature.enable(:feature_flag_name, feature_group: feature_group)
```

If no scope is provided, the feature flag is set instance-wide:

```ruby
# This will affect all users!
Runtime::Feature.enable(:feature_flag_name)
```

## Running a scenario with a feature flag enabled

It's also possible to run an entire scenario with a feature flag enabled, without having to edit
existing tests or write new ones.

Please see the [QA README](https://gitlab.com/gitlab-org/gitlab/tree/master/qa#running-tests-with-a-feature-flag-enabled)
for details.

## Confirming that end-to-end tests pass with a feature flag enabled

NOTE:
This section is particularly relevant to the requirement in the [feature flag rollout template](https://gitlab.com/gitlab-org/gitlab/-/blob/f7447302eafe1320ccc6136b5f3c39638ec8dc64/.gitlab/issue_templates/Feature%20Flag%20Roll%20Out.md)
that QA tests should pass with the feature flag enabled before the feature flag is enabled on Staging
or on GitLab.com.

If a test enables a feature flag as describe above, it is sufficient to run `package-and-qa` in a merge request containing the relevant changes.
Or, if the feature flag and relevant changes have already been merged, you can confirm that the tests
pass on `master`. The QA tests run on `master` every two hours, and the results are posted to a [Test
Session Report, which is available in the testcase-sessions project](https://gitlab.com/gitlab-org/quality/testcase-sessions/-/issues?label_name%5B%5D=found%3Amaster).

If the relevant tests do not enable the feature flag themselves, you can check if the tests will need
to be updated by running them against a GitLab instance that has the feature flag enabled.
Some examples of how to do so include:

- Enable the feature flag on Staging for the `gitlab-qa-sandbox-group` and then:

  - use GitLab QA to [run the Staging QA scenario](https://gitlab.com/gitlab-org/gitlab-qa/-/blob/master/docs/what_tests_can_be_run.md#testinstancestaging).
  - or, run the full suite of tests in CI by triggering the [`Daily Full QA suite` scheduled pipeline](https://ops.gitlab.net/gitlab-org/quality/staging/-/pipeline_schedules).
    If you do so, please let the pipeline triage DRI know by posting in Slack in `#qa-staging` or `#quality`. You can view the results in the pipeline, or as a [Test Session Report](https://gitlab.com/gitlab-org/quality/testcase-sessions/-/issues?label_name%5B%5D=found%3Astaging.gitlab.com).

- Open a merge request that enables the flag by default and then run `package-and-qa`.

- Enable the feature flag on your GDK or another private GitLab instance and then [use GitLab QA to run the relevant tests against that instance](https://gitlab.com/gitlab-org/gitlab-qa/-/blob/master/docs/what_tests_can_be_run.md#testinstanceany-ceeefull-image-addressnightlylatestany_tag-httpyourinstancegitlab).

NOTE:
If you run the full suite of tests from your own machine, it would take many hours to complete. We recommend you run [one or more specific tests](https://gitlab.com/gitlab-org/gitlab-qa/-/blob/master/docs/what_tests_can_be_run.md#running-a-specific-test-or-set-of-tests). Alternatively, you can run all the tests in CI as described above, which will run them in parallel.
