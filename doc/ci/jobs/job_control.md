---
stage: Verify
group: Continuous Integration
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#assignments
---

# Job control placeholder header

Concepts.

## Control jobs with `rules`

See [reference](../yaml/README.md#rules)

### Rules clauses

Available rule clauses are:

| Clause                     | Description                                                                                                                        |
|----------------------------|------------------------------------------------------------------------------------------------------------------------------------|
| [`if`](#rulesif)           | Add or exclude jobs from a pipeline by evaluating an `if` statement. Similar to [`only:variables`](#onlyvariablesexceptvariables). |
| [`changes`](#ruleschanges) | Add or exclude jobs from a pipeline based on what files are changed. Same as [`only:changes`](#onlychangesexceptchanges).          |
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
to [`except: merge_requests`](#onlyexcept-basic), so `job-with-no-rules`
runs in all cases except merge requests.

### Common `if` clauses for `rules`

For behavior similar to the [`only`/`except` keywords](#onlyexcept-basic), you can
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

### Variables in `rules:changes`

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

#### Complex rule clauses

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
    if: ($CI_COMMIT_BRANCH == "master" || $CI_COMMIT_BRANCH == "develop") && $MY_VARIABLE
```

WARNING:
[Before GitLab 13.3](https://gitlab.com/gitlab-org/gitlab/-/issues/230938),
rules that use both `||` and `&&` may evaluate with an unexpected order of operations.

## Control jobs with `needs`

See [reference](../yaml/README.md#needs)

### `needs` examples

## Control jobs with `only` and `except`

See [reference](../yaml/README.md#only-except-basic)

### `only` / `except` examples

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
    - master@gitlab-org/gitlab
    - /^release/.*$/@gitlab-org/gitlab
```

This example runs `job` for all branches on `gitlab-org/gitlab`,
except `master` and branches that start with `release/`.

If a job does not have an `only` rule, `only: ['branches', 'tags']` is set by
default. If the job does not have an `except` rule, it's empty.

For example, `job1` and `job2` are essentially the same:

```yaml
job1:
  script: echo 'test'

job2:
  script: echo 'test'
  only: ['branches', 'tags']
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

Read more about how to use this feature with:

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

Regular expression flags must be appended after the closing `/`.

NOTE:
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

## Control jobs with CI/CD variable

> - [Introduced](https://gitlab.com/gitlab-org/gitlab-foss/-/issues/37397) in GitLab 10.7 for [the `only` and `except` CI keywords](../yaml/README.md#onlyexcept-advanced)
> - [Expanded](https://gitlab.com/gitlab-org/gitlab/-/issues/27863) in GitLab 12.3 with [the `rules` keyword](../yaml/README.md#rules)

Use variable expressions to limit which jobs are created
in a pipeline after changes are pushed to GitLab.

In `.gitlab-ci.yml`, variable expressions work with both:

- [`rules`](../yaml/README.md#rules), which is the recommended approach, and
- [`only` and `except`](../yaml/README.md#onlyexcept-basic), which are candidates for deprecation.

This is particularly useful in combination with variables and triggered
pipeline variables.

```yaml
deploy:
  script: cap staging deploy
  environment: staging
  only:
    variables:
      - $RELEASE == "staging"
      - $STAGING
```

Each expression provided is evaluated before a pipeline is created.

If any of the conditions in `variables` evaluates to true when using `only`,
a new job is created. If any of the expressions evaluates to true
when `except` is being used, a job is not created.

This follows the usual rules for [`only` / `except` policies](../yaml/README.md#onlyexcept-advanced).

### Check if a variable matches a string

Examples:

- `$VARIABLE == "some value"`
- `$VARIABLE != "some value"` (introduced in GitLab 11.11)

You can use equality operator `==` or `!=` to compare a variable content to a
string. We support both, double quotes and single quotes to define a string
value, so both `$VARIABLE == "some value"` and `$VARIABLE == 'some value'`
are supported. `"some value" == $VARIABLE` is correct too.

### Check for an undefined value

Examples:

- `$VARIABLE == null`
- `$VARIABLE != null` (introduced in GitLab 11.11)

It sometimes happens that you want to check whether a variable is defined
or not. To do that, you can compare a variable to `null` keyword, like
`$VARIABLE == null`. This expression evaluates to true if
variable is not defined when `==` is used, or to false if `!=` is used.

### Check for an empty variable

Examples:

- `$VARIABLE == ""`
- `$VARIABLE != ""` (introduced in GitLab 11.11)

To check if a variable is defined but empty, compare it to:

- An empty string: `$VARIABLE == ''`
- A non-empty string: `$VARIABLE != ""`

### Compare two variables

Examples:

- `$VARIABLE_1 == $VARIABLE_2`
- `$VARIABLE_1 != $VARIABLE_2` (introduced in GitLab 11.11)

It is possible to compare two variables. This compares values
of these variables.

### Check for the presence of a variable

Example: `$STAGING`

To create a job when there is some variable present, meaning it is defined and non-empty,
use the variable name as an expression, like `$STAGING`. If the `$STAGING` variable
is defined, and is non empty, expression evaluates to `true`.
`$STAGING` value needs to be a string, with length higher than zero.
Variable that contains only whitespace characters is not an empty variable.

### Regex pattern matching

> [Introduced](https://gitlab.com/gitlab-org/gitlab-foss/-/issues/43601) in GitLab 11.0

Examples:

- `=~`: True if pattern is matched. Ex: `$VARIABLE =~ /^content.*/`
- `!~`: True if pattern is not matched. Ex: `$VARIABLE_1 !~ /^content.*/` ([Introduced](https://gitlab.com/gitlab-org/gitlab-foss/-/issues/61900) in GitLab 11.11)

Variable pattern matching with regular expressions uses the
[RE2 regular expression syntax](https://github.com/google/re2/wiki/Syntax).
Expressions evaluate as `true` if:

- Matches are found when using `=~`.
- Matches are *not* found when using `!~`.

Pattern matching is case-sensitive by default. Use `i` flag modifier, like
`/pattern/i` to make a pattern case-insensitive.

### Conjunction / Disjunction

> [Introduced](https://gitlab.com/gitlab-org/gitlab-foss/-/issues/62867) in GitLab 12.0

Examples:

- `$VARIABLE1 =~ /^content.*/ && $VARIABLE2 == "something"`
- `$VARIABLE1 =~ /^content.*/ && $VARIABLE2 =~ /thing$/ && $VARIABLE3`
- `$VARIABLE1 =~ /^content.*/ || $VARIABLE2 =~ /thing$/ && $VARIABLE3`

It is possible to join multiple conditions using `&&` or `||`. Any of the otherwise
supported syntax may be used in a conjunctive or disjunctive statement.
Precedence of operators follows the
[Ruby 2.5 standard](https://ruby-doc.org/core-2.5.0/doc/syntax/precedence_rdoc.html),
so `&&` is evaluated before `||`.

### Use parentheses in expressions

> - [Introduced](https://gitlab.com/gitlab-org/gitlab/-/issues/230938) in GitLab 13.3.
> - [Feature flag removed](https://gitlab.com/gitlab-org/gitlab/-/issues/238174) in GitLab 13.5.

It is possible to use parentheses to group conditions. Parentheses have the highest
precedence of all operators. Expressions enclosed in parentheses are evaluated first,
and the result is used for the rest of the expression.

Many nested parentheses can be used to create complex conditions, and the inner-most
expressions in parentheses are evaluated first. For an expression to be valid an equal
number of `(` and `)` need to be used.

Examples:

- `($VARIABLE1 =~ /^content.*/ || $VARIABLE2) && ($VARIABLE3 =~ /thing$/ || $VARIABLE4)`
- `($VARIABLE1 =~ /^content.*/ || $VARIABLE2 =~ /thing$/) && $VARIABLE3`
- `$CI_COMMIT_BRANCH == "my-branch" || (($VARIABLE1 == "thing" || $VARIABLE2 == "thing") && $VARIABLE3)`

### Store regular expressions in variables

It is possible to store a regular expression in a variable, to be used for pattern matching.
The following example tests whether `$RELEASE` contains either the
string `staging0` or the string `staging1`:

```yaml
variables:
  STAGINGRELS: '/staging0|staging1/'

deploy_staging:
  script: do.sh deploy staging
  environment: staging
  rules:
    - if: '$RELEASE =~ $STAGINGRELS'
```

NOTE:
The available regular expression syntax is limited. See [related issue](https://gitlab.com/gitlab-org/gitlab/-/issues/35438)
for more details.

If needed, you can use a test pipeline to determine whether a regular expression works in a variable. The example below tests the `^mast.*` regular expression directly,
as well as from in a variable:

```yaml
variables:
  MYSTRING: 'master'
  MYREGEX: '/^mast.*/'

testdirect:
  script: /bin/true
  rules:
    - if: '$MYSTRING =~ /^mast.*/'

testvariable:
  script: /bin/true
  rules:
    - if: '$MYSTRING =~ $MYREGEX'
```
