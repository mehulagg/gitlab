---
stage: Verify
group: Pipeline Execution
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#assignments
---

# Choose when to run jobs **(FREE)**

When a new pipeline starts, GitLab checks the pipeline configuration to determine
which jobs should run in that pipeline. You can configure jobs to run depending on
the status of variables, the pipeline type, and so on.

To configure a job to be included or excluded from certain pipelines, you can use:

- [`rules`](../yaml/README.md#rules)
- [`only`](../yaml/README.md#only--except)
- [`except`](../yaml/README.md#only--except)

Use [`needs`](../yaml/README.md#needs) to configure a job to run as soon as the
earlier jobs it depends on finish running.

## Specify when jobs run with `rules`

> [Introduced](https://gitlab.com/gitlab-org/gitlab/-/issues/27863) in GitLab 12.3.

Use `rules` to include or exclude jobs in pipelines.

Rules are evaluated *in order* until the first match. When a match is found, the job
is either included or excluded from the pipeline, depending on the configuration.
The job can also have [certain attributes](#rules-attributes)
added to it.

`rules` replaces [`only/except`](#only--except) and they can't be used together
in the same job. If you configure one job to use both keywords, the linter returns a
`key may not be used with rules` error.

### Rules attributes

The job attributes you can use with `rules` are:

- [`when`](#when): If not defined, defaults to `when: on_success`.
  - If used as `when: delayed`, `start_in` is also required.
- [`allow_failure`](#allow_failure): If not defined, defaults to `allow_failure: false`.
- [`variables`](#rulesvariables): If not defined, uses the [variables defined elsewhere](#variables).

If a rule evaluates to true, and `when` has any value except `never`, the job is included in the pipeline.

For example:

```yaml
docker build:
  script: docker build -t my-image:$CI_COMMIT_REF_SLUG .
  rules:
    - if: $CI_COMMIT_BRANCH == $CI_DEFAULT_BRANCH
      when: delayed
      start_in: '3 hours'
      allow_failure: true
```

### Rules clauses

Available rule clauses are:

| Clause                     | Description                                                                                                                        |
|----------------------------|------------------------------------------------------------------------------------------------------------------------------------|
| [`if`](#rulesif)           | Add or exclude jobs from a pipeline by evaluating an `if` statement. Similar to [`only:variables`](#onlyvariables--exceptvariables). |
| [`changes`](#ruleschanges) | Add or exclude jobs from a pipeline based on what files are changed. Same as [`only:changes`](#onlychanges--exceptchanges).          |
| [`exists`](#rulesexists)   | Add or exclude jobs from a pipeline based on the presence of specific files.                                                       |

Rules are evaluated in order until a match is found. If a match is found, the attributes
are checked to see if the job should be added to the pipeline. If no attributes are defined,
the defaults are:

- `when: on_success`
- `allow_failure: false`

The job is added to the pipeline:

- If a rule matches and has `when: on_success`, `when: delayed` or `when: always`.
- If no rules match, but the last clause is `when: on_success`, `when: delayed`
  or `when: always` (with no rule).

The job is not added to the pipeline:

- If no rules match, and there is no standalone `when: on_success`, `when: delayed` or
  `when: always`.
- If a rule matches, and has `when: never` as the attribute.

The following example uses `if` to strictly limit when jobs run:

```yaml
job:
  script: echo "Hello, Rules!"
  rules:
    - if: '$CI_PIPELINE_SOURCE == "merge_request_event"'
      when: manual
      allow_failure: true
    - if: '$CI_PIPELINE_SOURCE == "schedule"'
```

- If the pipeline is for a merge request, the first rule matches, and the job
  is added to the [merge request pipeline](../merge_request_pipelines/index.md)
  with attributes of:
  - `when: manual` (manual job)
  - `allow_failure: true` (the pipeline continues running even if the manual job is not run)
- If the pipeline is **not** for a merge request, the first rule doesn't match, and the
  second rule is evaluated.
- If the pipeline is a scheduled pipeline, the second rule matches, and the job
  is added to the scheduled pipeline. No attributes were defined, so it is added
  with:
  - `when: on_success` (default)
  - `allow_failure: false` (default)
- In **all other cases**, no rules match, so the job is **not** added to any other pipeline.

Alternatively, you can define a set of rules to exclude jobs in a few cases, but
run them in all other cases:

```yaml
job:
  script: echo "Hello, Rules!"
  rules:
    - if: '$CI_PIPELINE_SOURCE == "merge_request_event"'
      when: never
    - if: '$CI_PIPELINE_SOURCE == "schedule"'
      when: never
    - when: on_success
```

- If the pipeline is for a merge request, the job is **not** added to the pipeline.
- If the pipeline is a scheduled pipeline, the job is **not** added to the pipeline.
- In **all other cases**, the job is added to the pipeline, with `when: on_success`.

WARNING:
If you use a `when:` clause as the final rule (not including `when: never`), two
simultaneous pipelines may start. Both push pipelines and merge request pipelines can
be triggered by the same event (a push to the source branch for an open merge request).
See how to [prevent duplicate pipelines](#avoid-duplicate-pipelines)
for more details.

### Avoid duplicate pipelines

If a job uses `rules`, a single action, like pushing a commit to a branch, can trigger
multiple pipelines. You don't have to explicitly configure rules for multiple types
of pipeline to trigger them accidentally.

Some configurations that have the potential to cause duplicate pipelines cause a
[pipeline warning](../troubleshooting.md#pipeline-warnings) to be displayed.
[Introduced](https://gitlab.com/gitlab-org/gitlab/-/issues/219431) in GitLab 13.3.

For example:

```yaml
job:
  script: echo "This job creates double pipelines!"
  rules:
    - if: '$CUSTOM_VARIABLE == "false"'
      when: never
    - when: always
```

This job does not run when `$CUSTOM_VARIABLE` is false, but it *does* run in **all**
other pipelines, including **both** push (branch) and merge request pipelines. With
this configuration, every push to an open merge request's source branch
causes duplicated pipelines.

To avoid duplicate pipelines, you can:

- Use [`workflow`](#workflow) to specify which types of pipelines
  can run.
- Rewrite the rules to run the job only in very specific cases,
  and avoid a final `when:` rule:

  ```yaml
  job:
    script: echo "This job does NOT create double pipelines!"
    rules:
      - if: '$CUSTOM_VARIABLE == "true" && $CI_PIPELINE_SOURCE == "merge_request_event"'
  ```

You can also avoid duplicate pipelines by changing the job rules to avoid either push (branch)
pipelines or merge request pipelines. However, if you use a `- when: always` rule without
`workflow: rules`, GitLab still displays a [pipeline warning](../troubleshooting.md#pipeline-warnings).

For example, the following does not trigger double pipelines, but is not recommended
without `workflow: rules`:

```yaml
job:
  script: echo "This job does NOT create double pipelines!"
  rules:
    - if: '$CI_PIPELINE_SOURCE == "push"'
      when: never
    - when: always
```

You should not include both push and merge request pipelines in the same job without
[`workflow:rules` that prevent duplicate pipelines](#switch-between-branch-pipelines-and-merge-request-pipelines):

```yaml
job:
  script: echo "This job creates double pipelines!"
  rules:
    - if: '$CI_PIPELINE_SOURCE == "push"'
    - if: '$CI_PIPELINE_SOURCE == "merge_request_event"'
```

Also, do not mix `only/except` jobs with `rules` jobs in the same pipeline.
It may not cause YAML errors, but the different default behaviors of `only/except`
and `rules` can cause issues that are difficult to troubleshoot:

```yaml
job-with-no-rules:
  script: echo "This job runs in branch pipelines."

job-with-rules:
  script: echo "This job runs in merge request pipelines."
  rules:
    - if: '$CI_PIPELINE_SOURCE == "merge_request_event"'
```

For every change pushed to the branch, duplicate pipelines run. One
branch pipeline runs a single job (`job-with-no-rules`), and one merge request pipeline
runs the other job (`job-with-rules`). Jobs with no rules default
to [`except: merge_requests`](#only--except), so `job-with-no-rules`
runs in all cases except merge requests.

### `rules:if`

Use `rules:if` clauses to specify when to add a job to a pipeline:

- If an `if` statement is true, add the job to the pipeline.
- If an `if` statement is true, but it's combined with `when: never`, do not add the job to the pipeline.
- If no `if` statements are true, do not add the job to the pipeline.

`rules:if` differs slightly from `only:variables` by accepting only a single
expression string per rule, rather than an array of them. Any set of expressions to be
evaluated can be [conjoined into a single expression](../variables/README.md#conjunction--disjunction)
by using `&&` or `||`, and the [variable matching operators (`==`, `!=`, `=~` and `!~`)](../variables/README.md#syntax-of-cicd-variable-expressions).

Unlike variables in [`script`](../variables/README.md#use-cicd-variables-in-job-scripts)
sections, variables in rules expressions are always formatted as `$VARIABLE`.

`if:` clauses are evaluated based on the values of [predefined CI/CD variables](../variables/predefined_variables.md)
or [custom CI/CD variables](../variables/README.md#custom-cicd-variables).

For example:

```yaml
job:
  script: echo "Hello, Rules!"
  rules:
    - if: '$CI_MERGE_REQUEST_SOURCE_BRANCH_NAME =~ /^feature/ && $CI_MERGE_REQUEST_TARGET_BRANCH_NAME == $CI_DEFAULT_BRANCH'
      when: always
    - if: '$CI_MERGE_REQUEST_SOURCE_BRANCH_NAME =~ /^feature/'
      when: manual
      allow_failure: true
    - if: '$CI_MERGE_REQUEST_SOURCE_BRANCH_NAME'  # Checking for the presence of a variable is possible
```

Some details regarding the logic that determines the `when` for the job:

- If none of the provided rules match, the job is set to `when: never` and is
  not included in the pipeline.
- A rule without any conditional clause, such as a `when` or `allow_failure`
  rule without `if` or `changes`, always matches, and is always used if reached.
- If a rule matches and has no `when` defined, the rule uses the `when`
  defined for the job, which defaults to `on_success` if not defined.
- You can define `when` once per rule, or once at the job-level, which applies to
  all rules. You can't mix `when` at the job-level with `when` in rules.

#### Common `if` clauses for `rules`

For behavior similar to the [`only`/`except` keywords](#only--except), you can
check the value of the `$CI_PIPELINE_SOURCE` variable:

| Value                         | Description                                                                                                                                                                                                                      |
|-------------------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `api`                         | For pipelines triggered by the [pipelines API](../../api/pipelines.md#create-a-new-pipeline).                                                                                                                                    |
| `chat`                        | For pipelines created by using a [GitLab ChatOps](../chatops/index.md) command.                                                                                                                                                 |
| `external`                    | When you use CI services other than GitLab.                                                                                                                                                                                        |
| `external_pull_request_event` | When an external pull request on GitHub is created or updated. See [Pipelines for external pull requests](../ci_cd_for_external_repos/index.md#pipelines-for-external-pull-requests).                                            |
| `merge_request_event`         | For pipelines created when a merge request is created or updated. Required to enable [merge request pipelines](../merge_request_pipelines/index.md), [merged results pipelines](../merge_request_pipelines/pipelines_for_merged_results/index.md), and [merge trains](../merge_request_pipelines/pipelines_for_merged_results/merge_trains/index.md). |
| `parent_pipeline`             | For pipelines triggered by a [parent/child pipeline](../parent_child_pipelines.md) with `rules`. Use this pipeline source in the child pipeline configuration so that it can be triggered by the parent pipeline.                |
| `pipeline`                    | For [multi-project pipelines](../multi_project_pipelines.md) created by [using the API with `CI_JOB_TOKEN`](../multi_project_pipelines.md#triggering-multi-project-pipelines-through-api), or the [`trigger`](#trigger) keyword. |
| `push`                        | For pipelines triggered by a `git push` event, including for branches and tags.                                                                                                                                                  |
| `schedule`                    | For [scheduled pipelines](../pipelines/schedules.md).                                                                                                                                                                            |
| `trigger`                     | For pipelines created by using a [trigger token](../triggers/README.md#trigger-token).                                                                                                                                           |
| `web`                         | For pipelines created by using **Run pipeline** button in the GitLab UI, from the project's **CI/CD > Pipelines** section.                                                                                                       |
| `webide`                      | For pipelines created by using the [WebIDE](../../user/project/web_ide/index.md).                                                                                                                                                |

The following example runs the job as a manual job in scheduled pipelines or in push
pipelines (to branches or tags), with `when: on_success` (default). It does not
add the job to any other pipeline type.

```yaml
job:
  script: echo "Hello, Rules!"
  rules:
    - if: '$CI_PIPELINE_SOURCE == "schedule"'
      when: manual
      allow_failure: true
    - if: '$CI_PIPELINE_SOURCE == "push"'
```

The following example runs the job as a `when: on_success` job in [merge request pipelines](../merge_request_pipelines/index.md)
and scheduled pipelines. It does not run in any other pipeline type.

```yaml
job:
  script: echo "Hello, Rules!"
  rules:
    - if: '$CI_PIPELINE_SOURCE == "merge_request_event"'
    - if: '$CI_PIPELINE_SOURCE == "schedule"'
```

Other commonly used variables for `if` clauses:

- `if: $CI_COMMIT_TAG`: If changes are pushed for a tag.
- `if: $CI_COMMIT_BRANCH`: If changes are pushed to any branch.
- `if: '$CI_COMMIT_BRANCH == "main"'`: If changes are pushed to `main`.
- `if: '$CI_COMMIT_BRANCH == $CI_DEFAULT_BRANCH'`: If changes are pushed to the default
  branch. Use when you want to have the same configuration in multiple
  projects with different default branches.
- `if: '$CI_COMMIT_BRANCH =~ /regex-expression/'`: If the commit branch matches a regular expression.
- `if: '$CUSTOM_VARIABLE !~ /regex-expression/'`: If the [custom variable](../variables/README.md#custom-cicd-variables)
  `CUSTOM_VARIABLE` does **not** match a regular expression.
- `if: '$CUSTOM_VARIABLE == "value1"'`: If the custom variable `CUSTOM_VARIABLE` is
  exactly `value1`.

### `rules:changes`

Use `rules:changes` to specify when to add a job to a pipeline by checking for
changes to specific files.

`rules: changes` works the same way as [`only: changes` and `except: changes`](#onlychanges--exceptchanges).
It accepts an array of paths. You should use `rules: changes` only with branch
pipelines or merge request pipelines. For example, it's common to use `rules: changes`
with merge request pipelines:

```yaml
docker build:
  script: docker build -t my-image:$CI_COMMIT_REF_SLUG .
  rules:
    - if: '$CI_PIPELINE_SOURCE == "merge_request_event"'
      changes:
        - Dockerfile
      when: manual
      allow_failure: true
```

In this example:

- If the pipeline is a merge request pipeline, check `Dockerfile` for changes.
- If `Dockerfile` has changed, add the job to the pipeline as a manual job, and the pipeline
  continues running even if the job is not triggered (`allow_failure: true`).
- If `Dockerfile` has not changed, do not add job to any pipeline (same as `when: never`).

To use `rules: changes` with branch pipelines instead of merge request pipelines,
change the `if:` clause in the previous example to:

```yaml
rules:
  - if: $CI_PIPELINE_SOURCE == "push" && $CI_COMMIT_BRANCH
```

To implement a rule similar to [`except:changes`](#onlychanges--exceptchanges),
use `when: never`.

WARNING:
You can use `rules: changes` with other pipeline types, but it is not recommended
because `rules: changes` always evaluates to true when there is no Git `push` event.
Tag pipelines, scheduled pipelines, and so on do **not** have a Git `push` event
associated with them. A `rules: changes` job is **always** added to those pipeline
if there is no `if:` statement that limits the job to branch or merge request pipelines.

#### Variables in `rules:changes`

> - [Introduced](https://gitlab.com/gitlab-org/gitlab/-/issues/34272) in GitLab 13.6.
> - [Feature flag removed](https://gitlab.com/gitlab-org/gitlab/-/issues/267192) in GitLab 13.7.

You can use CI/CD variables in `rules:changes` expressions to determine when
to add jobs to a pipeline:

```yaml
docker build:
  variables:
    DOCKERFILES_DIR: 'path/to/files/'
  script: docker build -t my-image:$CI_COMMIT_REF_SLUG .
  rules:
    - changes:
        - $DOCKERFILES_DIR/*
```

You can use the `$` character for both variables and paths. For example, if the
`$DOCKERFILES_DIR` variable exists, its value is used. If it does not exist, the
`$` is interpreted as being part of a path.

### `rules:exists`

> [Introduced](https://gitlab.com/gitlab-org/gitlab/-/issues/24021) in GitLab 12.4.

Use `exists` to run a job when certain files exist in the repository.
You can use an array of paths.

In the following example, `job` runs if a `Dockerfile` exists anywhere in the repository:

```yaml
job:
  script: docker build -t my-image:$CI_COMMIT_REF_SLUG .
  rules:
    - exists:
        - Dockerfile
```

Paths are relative to the project directory (`$CI_PROJECT_DIR`) and can't directly link outside it.

You can use [glob](https://en.wikipedia.org/wiki/Glob_(programming))
patterns to match multiple files in any directory
in the repository:

```yaml
job:
  script: bundle exec rspec
  rules:
    - exists:
        - spec/**.rb
```

Glob patterns are interpreted with Ruby [`File.fnmatch`](https://docs.ruby-lang.org/en/2.7.0/File.html#method-c-fnmatch)
with the flags `File::FNM_PATHNAME | File::FNM_DOTMATCH | File::FNM_EXTGLOB`.

For performance reasons, GitLab matches a maximum of 10,000 `exists` patterns. After the 10,000th check, rules with patterned globs always match.

### `rules:allow_failure`

> [Introduced](https://gitlab.com/gitlab-org/gitlab/-/issues/30235) in GitLab 12.8.

You can use [`allow_failure: true`](#allow_failure) in `rules:` to allow a job to fail, or a manual job to
wait for action, without stopping the pipeline itself. All jobs that use `rules:` default to `allow_failure: false`
if you do not define `allow_failure:`.

The rule-level `rules:allow_failure` option overrides the job-level
[`allow_failure`](#allow_failure) option, and is only applied when
the particular rule triggers the job.

```yaml
job:
  script: echo "Hello, Rules!"
  rules:
    - if: '$CI_MERGE_REQUEST_TARGET_BRANCH_NAME == $CI_DEFAULT_BRANCH'
      when: manual
      allow_failure: true
```

In this example, if the first rule matches, then the job has `when: manual` and `allow_failure: true`.

### `rules:variables`

> - [Introduced](https://gitlab.com/gitlab-org/gitlab/-/issues/209864) in GitLab 13.7.
> - [Feature flag removed](https://gitlab.com/gitlab-org/gitlab/-/issues/289803) in GitLab 13.10.

Use [`variables`](#variables) in `rules:` to define variables for specific conditions.

For example:

```yaml
job:
  variables:
    DEPLOY_VARIABLE: "default-deploy"
  rules:
    - if: $CI_COMMIT_REF_NAME == $CI_DEFAULT_BRANCH
      variables:                              # Override DEPLOY_VARIABLE defined
        DEPLOY_VARIABLE: "deploy-production"  # at the job level.
    - if: $CI_COMMIT_REF_NAME =~ /feature/
      variables:
        IS_A_FEATURE: "true"                  # Define a new variable.
  script:
    - echo "Run script with $DEPLOY_VARIABLE as an argument"
    - echo "Run another script if $IS_A_FEATURE exists"
```

### Complex rule clauses

To conjoin `if`, `changes`, and `exists` clauses with an `AND`, use them in the
same rule.

In the following example:

- If the `Dockerfile` file or any file in `/docker/scripts` has changed, and `$VAR` == "string value",
  then the job runs manually
- Otherwise, the job isn't included in the pipeline.

```yaml
docker build:
  script: docker build -t my-image:$CI_COMMIT_REF_SLUG .
  rules:
    - if: '$VAR == "string value"'
      changes:  # Include the job and set to when:manual if any of the follow paths match a modified file.
        - Dockerfile
        - docker/scripts/*
      when: manual
      # - "when: never" would be redundant here. It is implied any time rules are listed.
```

Keywords such as `branches` or `refs` that are available for
`only`/`except` are not available in `rules`. They are being individually
considered for their usage and behavior in this context. Future keyword improvements
are being discussed in our [epic for improving `rules`](https://gitlab.com/groups/gitlab-org/-/epics/2783),
where anyone can add suggestions or requests.

You can use [parentheses](../variables/README.md#parentheses) with `&&` and `||` to build more complicated variable expressions.
[Introduced](https://gitlab.com/gitlab-org/gitlab/-/issues/230938) in GitLab 13.3:

```yaml
job1:
  script:
    - echo This rule uses parentheses.
  rules:
    if: ($CI_COMMIT_BRANCH == $CI_DEFAULT_BRANCH || $CI_COMMIT_BRANCH == "develop") && $MY_VARIABLE
```

WARNING:
[Before GitLab 13.3](https://gitlab.com/gitlab-org/gitlab/-/issues/230938),
rules that use both `||` and `&&` may evaluate with an unexpected order of operations.

## Specify when jobs run with `only` and `except`

You can use [`only`](../yaml/README.md#only--except) and [`except`](../yaml/README.md#only--except)
to control when to add jobs to pipelines.

- Use `only` to define when a job runs.
- Use `except` to define when a job **does not** run.

### `only:refs` / `except:refs` examples

`only` or `except` used without `refs` is the same as
[`only:refs` / `except/refs`](../yaml/README.md#onlyrefs--exceptrefs)

In the following example, `job` runs only for:

- Git tags
- [Triggers](../triggers/README.md#trigger-token)
- [Scheduled pipelines](../pipelines/schedules.md)

```yaml
job:
  # use special keywords
  only:
    - tags
    - triggers
    - schedules
```

To execute jobs only for the parent repository and not forks:

```yaml
job:
  only:
    - branches@gitlab-org/gitlab
  except:
    - main@gitlab-org/gitlab
    - /^release/.*$/@gitlab-org/gitlab
```

This example runs `job` for all branches on `gitlab-org/gitlab`,
except `main` and branches that start with `release/`.

### `only: variables` / `except: variables` examples

You can use [`except:variables`](../yaml/README.md#onlyvariables--exceptvariables) to exclude jobs based on a commit message:

```yaml
end-to-end:
  script: rake test:end-to-end
  except:
    variables:
      - $CI_COMMIT_MESSAGE =~ /skip-end-to-end-tests/
```

You can use [parentheses](../variables/README.md#parentheses) with `&&` and `||`
to build more complicated variable expressions:

```yaml
job1:
  script:
    - echo This rule uses parentheses.
  only:
    variables:
      - ($CI_COMMIT_BRANCH == "main" || $CI_COMMIT_BRANCH == "develop") && $MY_VARIABLE
```

### `only:changes` / `except:changes` examples

You can skip a job if a change is detected in any file with a
`.md` extension in the root directory of the repository:

```yaml
build:
  script: npm run build
  except:
    changes:
      - "*.md"
```

If you change multiple files, but only one file ends in `.md`,
the `build` job is still skipped. The job does not run for any of the files.

Read more about how to use `only:changes` and `except:changes`:

- [New branches or tags *without* pipelines for merge requests](#use-onlychanges-without-pipelines-for-merge-requests).
- [Scheduled pipelines](#use-onlychanges-with-scheduled-pipelines).

#### Use `only:changes` with pipelines for merge requests

With [pipelines for merge requests](../merge_request_pipelines/index.md),
it's possible to define a job to be created based on files modified
in a merge request.

Use this keyword with `only: [merge_requests]` so GitLab can find the correct base
SHA of the source branch. File differences are correctly calculated from any further
commits, and all changes in the merge requests are properly tested in pipelines.

For example:

```yaml
docker build service one:
  script: docker build -t my-service-one-image:$CI_COMMIT_REF_SLUG .
  only:
    refs:
      - merge_requests
    changes:
      - Dockerfile
      - service-one/**/*
```

In this scenario, if a merge request changes
files in the `service-one` directory or the `Dockerfile`, GitLab creates
the `docker build service one` job.

For example:

```yaml
docker build service one:
  script: docker build -t my-service-one-image:$CI_COMMIT_REF_SLUG .
  only:
    changes:
      - Dockerfile
      - service-one/**/*
```

In this example, the pipeline might fail because of changes to a file in `service-one/**/*`.

A later commit that doesn't have changes in `service-one/**/*`
but does have changes to the `Dockerfile` can pass. The job
only tests the changes to the `Dockerfile`.

GitLab checks the **most recent pipeline** that **passed**. If the merge request is mergeable,
it doesn't matter that an earlier pipeline failed because of a change that has not been corrected.

When you use this configuration, ensure that the most recent pipeline
properly corrects any failures from previous pipelines.

#### Use `only:changes` without pipelines for merge requests

Without [pipelines for merge requests](../merge_request_pipelines/index.md), pipelines
run on branches or tags that don't have an explicit association with a merge request.
In this case, a previous SHA is used to calculate the diff, which is equivalent to `git diff HEAD~`.
This can result in some unexpected behavior, including:

- When pushing a new branch or a new tag to GitLab, the policy always evaluates to true.
- When pushing a new commit, the changed files are calculated by using the previous commit
  as the base SHA.

#### Use `only:changes` with scheduled pipelines

`only:changes` always evaluates as true in [Scheduled pipelines](../pipelines/schedules.md).
All files are considered to have changed when a scheduled pipeline runs.

### Combine multiple keywords with `only` or `except`

If you use multiple keywords with `only` or `except`, the keywords are evaluated
as a single conjoined expression. That is:

- `only:` includes the job if **all** of the keys have at least one condition that matches.
- `except:` excludes the job if **any** of the keys have at least one condition that matches.

With `only`, individual keys are logically joined by an `AND`. A job is added to
the pipeline if the following is true:

- `(any listed refs are true) AND (any listed variables are true) AND (any listed changes are true) AND (any chosen Kubernetes status matches)`

In the following example, the `test` job is only created when **all** of the following are true:

- The pipeline is [scheduled](../pipelines/schedules.md) **or** runs for `main`.
- The `variables` keyword matches.
- The `kubernetes` service is active on the project.

```yaml
test:
  script: npm run test
  only:
    refs:
      - main
      - schedules
    variables:
      - $CI_COMMIT_MESSAGE =~ /run-end-to-end-tests/
    kubernetes: active
```

With `except`, individual keys are logically joined by an `OR`. A job is **not**
added if the following is true:

- `(any listed refs are true) OR (any listed variables are true) OR (any listed changes are true) OR (a chosen Kubernetes status matches)`

In the following example, the `test` job is **not** created when **any** of the following are true:

- The pipeline runs for the `main` branch.
- There are changes to the `README.md` file in the root directory of the repository.

```yaml
test:
  script: npm run test
  except:
    refs:
      - main
    changes:
      - "README.md"
```

## Use predefined CI/CD variables to run jobs only in specific pipeline types

You can use [predefined CI/CD variables](../variables/predefined_variables.md) to choose
which pipeline types jobs run in, with:

- [`rules`](../yaml/README.md#rules)
- [`only:variables`](../yaml/README.md#onlyvariables--exceptvariables)
- [`except:variables`](../yaml/README.md#onlyvariables--exceptvariables)

The following table lists some of the variables that you can use, and the pipeline
types the variables can control for:

- Branch pipelines that run for Git `push` events to a branch, like new commits or tags.
- Tag pipelines that run only when a new Git tag is pushed to a branch.
- [Merge request pipelines](../merge_request_pipelines/index.md) that run for changes
  to a merge request, like new commits or selecting the **Run pipeline** button
  in a merge request's pipelines tab.
- [Scheduled pipelines](../pipelines/schedules.md).

| Variables                                  | Branch | Tag | Merge request | Scheduled |
|--------------------------------------------|--------|-----|---------------|-----------|
| `CI_COMMIT_BRANCH`                         | Yes    |     |               | Yes       |
| `CI_COMMIT_TAG`                            |        | Yes |               | Yes, if the scheduled pipeline is configured to run on a tag. |
| `CI_PIPELINE_SOURCE = push`                | Yes    | Yes |               |           |
| `CI_PIPELINE_SOURCE = scheduled`           |        |     |               | Yes       |
| `CI_PIPELINE_SOURCE = merge_request_event` |        |     | Yes           |           |
| `CI_MERGE_REQUEST_IID`                     |        |     | Yes           |           |

For example, to configure a job to run for merge request pipelines and scheduled pipelines,
but not branch or tag pipelines:

```yaml
job1:
  script:
    - echo
  rules:
    - if: $CI_PIPELINE_SOURCE == "merge_request_event"
    - if: $CI_PIPELINE_SOURCE == "scheduled"
    - if: $CI_PIPELINE_SOURCE == "push"
      when: never
```

## Regular expressions

The `@` symbol denotes the beginning of a ref's repository path.
To match a ref name that contains the `@` character in a regular expression,
you must use the hex character code match `\x40`.

Only the tag or branch name can be matched by a regular expression.
The repository path, if given, is always matched literally.

To match the tag or branch name,
the entire ref name part of the pattern must be a regular expression surrounded by `/`.
For example, you can't use `issue-/.*/` to match all tag names or branch names
that begin with `issue-`, but you can use `/issue-.*/`.

Regular expression flags must be appended after the closing `/`. Pattern matching
is case-sensitive by default. Use the `i` flag modifier, like `/pattern/i`, to make
a pattern case-insensitive:

```yaml
job:
  # use regexp
  only:
    - /^issue-.*$/i
  # use special keyword
  except:
    - branches
```

Use anchors `^` and `$` to avoid the regular expression
matching only a substring of the tag name or branch name.
For example, `/^issue-.*$/` is equivalent to `/^issue-/`,
while just `/issue/` would also match a branch called `severe-issues`.

### `only` / `except` regex syntax

In GitLab 11.9.4, GitLab began internally converting the regexp used
in `only` and `except` keywords to [RE2](https://github.com/google/re2/wiki/Syntax).

[RE2](https://github.com/google/re2/wiki/Syntax) limits the set of available features
due to computational complexity, and some features, like negative lookaheads, became unavailable.
Only a subset of features provided by [Ruby Regexp](https://ruby-doc.org/core/Regexp.html)
are now supported.

From GitLab 11.9.7 to GitLab 12.0, GitLab provided a feature flag to
let you use unsafe regexp syntax. After migrating to safe syntax, you should disable
this feature flag again:

```ruby
Feature.enable(:allow_unsafe_ruby_regexp)
```
