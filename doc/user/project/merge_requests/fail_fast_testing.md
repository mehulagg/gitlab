---
type: reference, howto
---

# Fail Fast Testing **(PREMIUM)**

> [Introduced](https://gitlab.com/gitlab-org/gitlab/-/issues/198550) in GitLab 13.1.

For applications that use RSpec for running tests, we've introduced the `Verify/Failfast`
[template to run subsets of your test suite](https://gitlab.com/gitlab-org/gitlab/-/tree/master/lib/gitlab/ci/templates/Verify/FailFast.gitlab-ci.yml),
based on the changes in your merge request.

The template uses the [test_file_finder (`tff`) gem](https://gitlab.com/gitlab-org/ci-cd/test_file_finder/)
that accepts a list of files as input, and returns a list of spec (test) files
that it believes to be relevant to the input files.

`tff` is designed for Ruby on Rails projects, so the `Verify/FailFast` template is
configured to run when changes to Ruby files are detected. By default, it runs in
the [`.pre` stage](../../../ci/yaml/README.md#pre-and-post) of a GitLab CI/CD pipeline,
before all other stages.

## Requirements

This template requires:

- A project built in Rails that uses RSpec for testing.
- CI/CD configured to:
  - Use a Docker image with Ruby available.
  - Use [Pipelines for Merge Requests](../../../ci/merge_request_pipelines/index.md#configuring-pipelines-for-merge-requests)
- [Pipelines for Merged Results](../../../ci/merge_request_pipelines/pipelines_for_merged_results/index.md#enable-pipelines-for-merged-results)
  enabled in the project settings.

## Configure Fast RSpec Failure

We'll use the following plain RSpec configuration as a starting point. It installs all the
project gems and executes `rspec`, on merge request pipelines only.

```yaml
rspec-complete:
  stage: test
  rules:
    - if: $CI_PIPELINE_SOURCE == "merge_request_event"
  script:
    - bundle install
    - bundle exec rspec
```

To run the most relevant specs first instead of the whole suite, [`include`](../../../ci/yaml/README.md#include)
the template by adding the following to your CI/CD configuration:

```yaml
include:
  - template: Verify/FailFast.gitlab-ci.yml
```

### Example test loads

For illustrative purposes, let's say our Rails app spec suite consists of 100 specs per model for ten models.

If no Ruby files are changed:

- `rspec-rails-modified-paths-specs` will not run any tests.
- `rspec-complete` will run the full suite of 1000 tests.

If one Ruby model is changed, for example `app/models/example.rb`, then `rspec-rails-modified-paths-specs`
will run the 100 tests for `example.rb`:

- If all of these 100 tests pass, then the full `rspec-complete` suite of 1000 tests is allowed to run.
- If any of these 100 tests fail, they will fail quickly, and `rspec-complete` will not run any tests.

The final case saves resources and time as the full 1000 test suite does not run.
