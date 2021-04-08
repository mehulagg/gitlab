---
stage: Verify
group: Continuous Integration
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#assignments
---

# Job control placeholder header

Concepts.

## Control jobs with `rules`

See [reference](../yaml/README.md#rules)

### `rules` examples

## Control jobs with `needs`

See [reference](../yaml/README.md#needs)

### `needs` examples

## Control jobs with `only` and `except`

See [reference](../yaml/README.md#only-except-basic)

### `only` / `except` examples

### Regular expressions

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
