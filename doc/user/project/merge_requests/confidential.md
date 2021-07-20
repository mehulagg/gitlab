---
stage: Create
group: Code Review
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#assignments
---

# Merge requests for confidential issues

> [Introduced](https://gitlab.com/gitlab-org/gitlab-foss/-/issues/58583) in GitLab 12.1.

To help prevent confidential information being leaked from a public project
in the process of resolving a confidential issue, [confidential issues](../issues/confidential_issues.md) can be
resolved by creating a merge request from a private fork.

The created merge request targets the default branch of the private fork,
not the default branch of the public upstream project. This prevents the merge
request, branch, and commits entering the public repository, and revealing
confidential information prematurely. To make a confidential commit public,
open a merge request from the private fork to the public upstream project.

Permissions are inherited from parent groups. Developers have the same permissions
for private forks created in the same group or in a subgroup of the original
Permissions are inherited from parent groups. When private forks are created
in the same group or subgroup as the original upstream repository, users
receive the same permissions in both projects. This inheritance ensures
Developer users have the needed permissions to both view confidential issues and
resolve them.

## How it works

On a confidential issue, a **Create confidential merge request** button is
available. Clicking on it opens a dropdown where you can choose to
**Create confidential merge request and branch** or **Create branch**:

| Create confidential merge request | Create branch |
| :-------------------------------: | :-----------: |
| ![Create Confidential Merge Request Dropdown](img/confidential_mr_dropdown_v12_1.png) | ![Create Confidential Branch Dropdown](img/confidential_mr_branch_dropdown_v12_1.png) |

The **Project** dropdown includes the list of private forks the user is a member
of as at least a Developer and merge requests are enabled.

Whenever the **Branch name** and **Source (branch or tag)** fields change, the
availability of the target and source branch are checked. Both branches should
be available in the selected private fork.

By clicking the **Create confidential merge request** button, GitLab creates
the branch and merge request in the private fork. When you choose
**Create branch**, GitLab creates only the branch.

After the branch is created in the private fork, developers can push code to
that branch to fix the confidential issue.

## Related links

- [Confidential issues](../issues/confidential_issues.md)
