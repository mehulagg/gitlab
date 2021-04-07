---
stage: Verify
group: Continuous Integration
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#assignments
comments: false
type: index, howto
---

# Migrating from GitHub Actions

If you are currently using GitHub Actions, you can migrate your CI/CD pipelines to [GitLab CI/CD](../introduction/index.md),
and start making use of all its powerful features. Check out our
[GitHub vs GitLab](https://about.gitlab.com/devops-tools/github-vs-gitlab/)
comparison to see what's different.

We have collected several resources that you may find useful before starting to migrate.

The [Quick Start Guide](../quick_start/index.md) is a good overview of how GitLab CI/CD works. You may also be interested in [Auto DevOps](../../topics/autodevops/index.md) which can be used to build, test, and deploy your applications with little to no configuration needed at all.

For advanced CI/CD teams, [custom project templates](../../user/admin_area/custom_project_templates.md) can enable the reuse of pipeline configurations.

If you have questions that are not answered here, the [GitLab community forum](https://forum.gitlab.com/) can be a great resource.

## `gitlab.yml` vs `gitlab-ci.yml`
GitHub Workflows are `.yml` files typically stored in
the `.github/workflows` directory of your repository. GitLab's primary CI file resides in the root of your project, however additional `.yml` files can be stored anywhere in your project and referenced within your script.

GitHub Actions workflows are comparable to GitLab's `stages`.

### Jobs
WIP

### Docker image definition
WIP

### Workflows
WIP

### Filter job by branch
WIP

### Caching
WIP

### Contexts and Variables
WIP

### Build environments
WIP

### Shell scripts and commands
WIP

### `script` vs `run`
GitLab CI/CD shell commands and scripts are executed using the `script` keyword, which replaces `run` in GitHub actions like so:

``` yaml
job1:
    script:
        - echo Hello world!
```

### `rules` vs `if`
GitLab CI/CD implements an exhaustive `rules` keyword for defining the conditions for whether jobs are included in a pipeline. `rules` is comparable to `if` in GitHub Actions.

``` yaml
rules:
    - if: '$CI_COMMIT_BRANCH == "master"'
      when: delayed
      start_in: '3 hours'
      allow_failure: true
```

