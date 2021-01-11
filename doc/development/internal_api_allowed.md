---
stage: Create
group: Source Code
info: "To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#assignments"
type: reference, api
---

# `/api/:version/internal/allowed`

## What does the endpoint do?

The `internal/allowed` endpoint is used for assessing whether a user has permission to perform certain operations on the git repository. It performs multiple checks, such as ensuring the branch or tag name is acceptable, and whether the user has the authority to perform that action.

## Where is it defined?

The internal API endpoints are defined under [`lib/api/internal`](), and the `/allowed` path is in [`lib/api/internal/base.rb`]().

## When is the endpoint used?

`internal/allowed` is called when performing the following actions:

- Pushing to the repository
- Performing actions on the repository through the GitLab GUI, such as applying suggestions or using the GitLab IDE


It is typically called by Gitaly, and is only called "internally", i.e. by other parts of the application, rather than by external users of the API.

## Push checks

One of the key parts of the `internal/allowed` flow is the call to `EE::Gitlab::Checks::PushRuleCheck`. This can perform the following checks:

### `EE::Gitlab::Checks::PushRules::CommitCheck`

RPCs called:

- `ListNewCommits`
- `GetNewLFSPointers`?

###`EE::Gitlab::Checks::PushRules::TagCheck`

RPCs called:

- ?

### `EE::Gitlab::Checks::PushRules::BranchCheck`

RPCs called:

- `ListNewCommits`

### `EE::Gitlab::Checks::PushRules::FileSizeCheck`

RPCs called:

- `ListNewBlobs`
- `GetBlobs`?

## Recursion

Some of the Gitaly RPCs that are called by `internal/allowed` then themselves make calls back to `internal/allowed`. These [are now correlated]() with the original request, as of {version}. Gitaly relies on the Rails application for authorisation and maintains no permissions model itself.

These calls show up in the logs differently to the initial requests. {example}

Because this endpoint can be called recursively, slow performance on this endpoint can result in an exponential performance impact. This documentation is in fact adapted from [the investigation into its performance](https://gitlab.com/gitlab-org/gitlab/-/issues/222247).

## Known performance issues

### Refs

The number of [`refs`](https://git-scm.com/book/en/v2/Git-Internals-Git-References) on the Git repository have a notable effect on the performance of `git` commands, and thus Gitaly RPCs, that are called upon it. Certain `git` commands will scan through all refs, and this causes a notable impact on the speed of those commands.

On the `internal/allowed` endpoint, ref counts have an exponential impact on performance due to the recursive nature of the RPC calls.

#### Environment refs

As of writing we know that [stale environment refs](https://gitlab.com/gitlab-org/gitlab/-/issues/296625) are a common example of excessive refs causing performance issues, often numbering into the tens of thousands on busy repositories as they aren't cleared up automatically.

#### Dangling refs

Dangling refs are created to prevent accidental deletion of objects from object pools. It's possible for there to be a large number of this type of ref, which may have potential performance implications. There is existing discussion around this issue in [gitaly#1900](https://gitlab.com/gitlab-org/gitaly/-/issues/1900). Currently this appears to have less of an impact than stale environment refs.

### Pool repositories

When a fork is created on GitLab, a central "pool" repository is created and the forks linked to it. This pool repository is used to prevent duplication of data by storing data common to other forks. However the pool repository is [cleaned up differently]() to the standard repositories and so is more prone to the refs issue above.

## Feature flags

### `:parallel_push_checks`

This is an experimental feature flag which is disabled by default. It enables the endpoint to run multiple RPCs simultaneously, reducing the overall time taken by roughly half. This is achieved via threading and thus has some potential side-effects at large scale. On GitLab.com this is currently enabled only for `gitlab-org/gitlab` and `gitlab-com/www-gitlab-com` as without it those projects will routinely time out requests to the endpoint. When it was rolled out across all of GitLab.com it caused some pushes to fail, presumably because of exhausting our database connection pools or some other resource.

It is recommended that this feature flag is only enabled if you are experiencing timeouts, and then, only enabled for that specific project.
