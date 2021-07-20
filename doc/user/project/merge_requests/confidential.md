---
stage: Create
group: Code Review
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#assignments
---

# Merge requests for confidential issues

> [Introduced](https://gitlab.com/gitlab-org/gitlab-foss/-/issues/58583) in GitLab 12.1.

Merge requests in a public repository are also public, even when the merge
request is created for a [confidential issue](../issues/confidential_issues.md).
To avoid leaking confidential information when working on a confidential issue,
create your merge request from a private fork.

Roles are inherited from parent groups. If you create your private fork in the
same group or subgroup as the original (public) repository, developers receive
the same permissions in your fork. This inheritance ensures Developer users have
the needed permissions to both view confidential issues and resolve them, without
you needing to grant individual users access to your fork.

## Create a confidential merge request

WARNING:
To create a confidential merge request, you must create a private fork. This fork
may expose confidential information, if you create your fork in another namespace
that may have other members.

Branches are public by default. To protect the confidentiality of your work, you
must create your changes in a private fork:

1. *If you have not already forked the repository,* create a private fork:
   1. Go to the project's page and, in the upper right corner, select **Fork**.
   1. Configure the forked project, and select a **Visibility level** of
      _Private_ or _Internal_, depending on your need.
1. Go to the confidential issue's page. Scroll below the issue description and
   select **Create confidential merge request**.
1. Select the item that meets your needs:
   - *To create both a branch and a merge request,* select
     **Create confidential merge request and branch**. Your merge request will
     target the default branch of your fork, *not* the default branch of the
     public upstream project.
   - *To create only a branch,* select **Create branch**.
1. Select a **Project** to use. These projects have merge requests enabled, and
   you have the Developer role (or greater) in them.
1. Provide a **Branch name**, and select a **Source (branch or tag)**. GitLab
   checks whether these branches are available in your private fork, because both
   branches must be available in your selected fork.
1. Select **Create**.

If you created a branch in your private fork, developers can push code to
that branch to fix the confidential issue.

As your merge request targets your private fork, not the public upstream project,
your branch, merge request, and commits do not enter the public repository. This
prevents prematurely revealing confidential information.

To make a confidential commit public, open a merge request from the private fork
to the public upstream project.

## Related links

- [Confidential issues](../issues/confidential_issues.md)
