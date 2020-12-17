---
stage: Manage
group: Access
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#assignments
---

# Permissions

Users have different abilities depending on the access level they have in a
particular group or project. If a user is both in a project's group and the
project itself, the highest permission level is used.

On public and internal projects, the Guest role is not enforced. All users can:

- Create issues.
- Leave comments.
- Clone or download the project code.

When a member leaves a team's project, all the assigned [Issues](project/issues/index.md) and [Merge Requests](project/merge_requests/index.md)
are unassigned automatically.

GitLab [administrators](../administration/index.md) receive all permissions.

To add or import a user, you can follow the
[project members documentation](project/members/index.md).

## Principles behind permissions

See our [product handbook on permissions](https://about.gitlab.com/handbook/product/gitlab-the-product/#permissions-in-gitlab).

## Instance-wide user permissions

By default, users can create top-level groups and change their
usernames. A GitLab administrator can configure the GitLab instance to
[modify this behavior](../administration/user_settings.md).

## Project members permissions

NOTE:
In GitLab 11.0, the Master role was renamed to Maintainer.

While Maintainer is the highest project-level role, some actions can only be performed by a personal namespace or group owner,
or an instance administrator, who receives all permissions. For more information, see [projects members documentation](project/members/index.md).

The following table depicts the various user permission levels in a project.

| Action                                                                                                            | Guest    | Reporter | Developer | Maintainer | Owner (*10*) |
|-------------------------------------------------------------------------------------------------------------------|----------|----------|-----------|------------|--------------|
| [**Analytics**](analytics/index.md): View Issue analytics **(PREMIUM)**                                           | ✓        | ✓        | ✓         | ✓          | ✓            |
| [**Analytics**](analytics/index.md): View Merge Request analytics **(STARTER)**                                   | ✓        | ✓        | ✓         | ✓          | ✓            |
| [**Analytics**](analytics/index.md): View Value Stream analytics                                                  | ✓        | ✓        | ✓         | ✓          | ✓            |
| [**Analytics**](analytics/index.md): View CI/CD analytics                                                         |          | ✓        | ✓         | ✓          | ✓            |
| [**Analytics**](analytics/index.md): View Code Review analytics **(STARTER)**                                     |          | ✓        | ✓         | ✓          | ✓            |
| [**Analytics**](analytics/index.md): View Repository analytics                                                    |          | ✓        | ✓         | ✓          | ✓            |
| [**CI/CD**](../ci/README.md): Download and browse job artifacts                                                   | ✓ (*3*)  | ✓        | ✓         | ✓          | ✓            |
| [**CI/CD**](../ci/README.md): View a job log                                                                      | ✓ (*3*)  | ✓        | ✓         | ✓          | ✓            |
| [**CI/CD**](../ci/README.md): View list of jobs                                                                   | ✓ (*3*)  | ✓        | ✓         | ✓          | ✓            |
| [**CI/CD**](../ci/README.md): Cancel and retry jobs                                                               |          |          | ✓         | ✓          | ✓            |
| [**CI/CD**](../ci/README.md): Run CI/CD pipeline against a protected branch                                       |          |          | ✓ (*5*)   | ✓          | ✓            |
| [**CI/CD**](../ci/README.md): View a job with [debug logging](../ci/variables/README.md#debug-logging)            |          |          | ✓         | ✓          | ✓            |
| [**CI/CD**](../ci/README.md): Manage job triggers                                                                 |          |          |           | ✓          | ✓            |
| [**CI/CD**](../ci/README.md): Manage runners                                                                      |          |          |           | ✓          | ✓            |
| [**CI/CD**](../ci/README.md): Manage variables                                                                    |          |          |           | ✓          | ✓            |
| [**CI/CD**](../ci/README.md): Run Web IDE's Interactive Web Terminals **(ULTIMATE ONLY)**                         |          |          |           | ✓          | ✓            |
| [**CI/CD**](../ci/README.md): Delete pipelines                                                                    |          |          |           |            | ✓            |
| [**Clusters**](project/clusters/index.md): View Pods logs                                                         |          |          | ✓         | ✓          | ✓            |
| [**Clusters**](project/clusters/index.md): Manage clusters                                                        |          |          |           | ✓          | ✓            |
| [**Dependency scanning**](application_security/dependency_scanning/index.md): View Dependency list **(ULTIMATE)** | ✓ (*1*)  | ✓        | ✓         | ✓          | ✓            |
| [**Environments**](../ci/environments/index.md): View environments                                                |          | ✓        | ✓         | ✓          | ✓            |
| [**Environments**](../ci/environments/index.md): Create new environments                                          |          |          | ✓         | ✓          | ✓            |
| [**Environments**](../ci/environments/index.md): Stop environments                                                |          |          | ✓         | ✓          | ✓            |
| [**Environments**](../ci/environments/index.md): Use environment terminals                                        |          |          |           | ✓          | ✓            |
| [**Error Tracking**](../operations/error_tracking.md): View list                                                  |          | ✓        | ✓         | ✓          | ✓            |
| [**Error Tracking**](../operations/error_tracking.md): Manage                                                     |          |          |           | ✓          | ✓            |
| [**Feature Flags**](../operations/feature_flags.md): Manage **(PREMIUM)**                                         |          |          | ✓         | ✓          | ✓            |
| [**GitLab Pages**](project/pages/index.md): View Pages protected by [access control](project/pages/introduction.md#gitlab-pages-access-control) | ✓   | ✓   | ✓   | ✓   | ✓     |
| [**GitLab Pages**](project/pages/index.md): Manage                                                                |          |          |           | ✓          | ✓            |
| [**GitLab Pages**](project/pages/index.md): Manage GitLab Pages domains and certificates                          |          |          |           | ✓          | ✓            |
| [**GitLab Pages**](project/pages/index.md): Remove GitLab Pages                                                   |          |          |           | ✓          | ✓            |
| [**Issues**](project/issues/index.md): Create                                                                     | ✓        | ✓        | ✓         | ✓          | ✓            |
| [**Issues**](project/issues/index.md): Create confidential                                                        | ✓        | ✓        | ✓         | ✓          | ✓            |
| [**Issues**](project/issues/index.md): See related issues                                                         | ✓        | ✓        | ✓         | ✓          | ✓            |
| [**Issues**](project/issues/index.md): View [Design Management](project/issues/design_management.md) pages        | ✓        | ✓        | ✓         | ✓          | ✓            |
| [**Issues**](project/issues/index.md): View confidential                                                          | (*2*)    | ✓        | ✓         | ✓          | ✓            |
| [**Issues**](project/issues/index.md): Add Labels                                                                 |          | ✓        | ✓         | ✓          | ✓            |
| [**Issues**](project/issues/index.md): Assign                                                                     |          | ✓        | ✓         | ✓          | ✓            |
| [**Issues**](project/issues/index.md): Lock threads                                                               |          | ✓        | ✓         | ✓          | ✓            |
| [**Issues**](project/issues/index.md): Manage related issues                                                      |          | ✓        | ✓         | ✓          | ✓            |
| [**Issues**](project/issues/index.md): Manage tracker                                                             |          | ✓        | ✓         | ✓          | ✓            |
| [**Issues**](project/issues/index.md): Set weight                                                                 |          | ✓        | ✓         | ✓          | ✓            |
| [**Issues**](project/issues/index.md): Upload [Design Management](project/issues/design_management.md) files      |          |          | ✓         | ✓          | ✓            |
| [**Issues**](project/issues/index.md): Delete                                                                     |          |          |           |            | ✓            |
| [**License Compliance**](compliance/license_compliance/index.md): View License Compliance reports **(ULTIMATE)**  | ✓ (*1*)  | ✓        | ✓         | ✓          | ✓            |
| [**License Compliance**](compliance/license_compliance/index.md): View License list **(ULTIMATE)**                | ✓ (*1*)  | ✓        | ✓         | ✓          | ✓            |
| [**License Compliance**](compliance/license_compliance/index.md): View allowed and denied licenses **(ULTIMATE)** | ✓ (*1*)  | ✓        | ✓         | ✓          | ✓            |
| [**License Compliance**](compliance/license_compliance/index.md): View licenses in Dependency list **(ULTIMATE)** | ✓ (*1*)  | ✓        | ✓         | ✓          | ✓            |
| [**License Compliance**](compliance/license_compliance/index.md): Manage license policy **(ULTIMATE)**            |          |          |           | ✓          | ✓            |
| [**Merge requests**](project/merge_requests/index.md) Create                                                      |          | ✓        | ✓         | ✓          | ✓            |
| [**Merge requests**](project/merge_requests/index.md) See list                                                    |          | ✓        | ✓         | ✓          | ✓            |
| [**Merge requests**](project/merge_requests/index.md) Apply code change suggestions                               |          |          | ✓         | ✓          | ✓            |
| [**Merge requests**](project/merge_requests/index.md) Approve (*9*)                                               |          |          | ✓         | ✓          | ✓            |
| [**Merge requests**](project/merge_requests/index.md) Assign                                                      |          |          | ✓         | ✓          | ✓            |
| [**Merge requests**](project/merge_requests/index.md) Label merge requests                                        |          |          | ✓         | ✓          | ✓            |
| [**Merge requests**](project/merge_requests/index.md) Lock threads                                                |          |          | ✓         | ✓          | ✓            |
| [**Merge requests**](project/merge_requests/index.md) Manage/Accept                                               |          |          | ✓         | ✓          | ✓            |
| [**Merge requests**](project/merge_requests/index.md) Delete                                                      |          |          |           |            | ✓            |
| [**Metrics**](../operations/metrics/index.md): Manage user-starred metrics dashboards (*7*)                       | ✓        | ✓        | ✓         | ✓          | ✓            |
| [**Metrics**](../operations/metrics/index.md): View metrics dashboard annotations                                 |          | ✓        | ✓         | ✓          | ✓            |
| [**Metrics**](../operations/metrics/index.md): Create/edit/delete metrics dashboard annotations                   |          |          | ✓         | ✓          | ✓            |
| [**Milestones**](project/milestones/index.md): Create/edit/delete                                                 |          |          | ✓         | ✓          | ✓            |
| [**Packages**](packages/index.md): Pull                                                                           |          | ✓        | ✓         | ✓          | ✓            |
| [**Packages**](packages/index.md): See a container registry                                                       |          | ✓        | ✓         | ✓          | ✓            |
| [**Packages**](packages/index.md): Create/edit/delete cleanup policies                                            |          |          | ✓         | ✓          | ✓            |
| [**Packages**](packages/index.md): Publish                                                                        |          |          | ✓         | ✓          | ✓            |
| [**Packages**](packages/index.md): Remove a container registry image                                              |          |          | ✓         | ✓          | ✓            |
| [**Packages**](packages/index.md): Update a container registry                                                    |          |          | ✓         | ✓          | ✓            |
| [**Packages**](packages/index.md): Delete                                                                         |          |          |           | ✓          | ✓            |
| [**Projects**](project/index.md): Leave comments                                                                  | ✓        | ✓        | ✓         | ✓          | ✓            |
| [**Projects**](project/index.md): Download project                                                                | ✓ (*1*)  | ✓        | ✓         | ✓          | ✓            |
| [**Projects**](project/index.md): Reposition comments on images (posted by any user)                              | ✓ (*11*) | ✓ (*11*) | ✓ (*11*)  | ✓          | ✓            |
| [**Projects**](project/index.md): View Insights **(ULTIMATE)**                                                    | ✓        | ✓        | ✓         | ✓          | ✓            |
| [**Projects**](project/index.md): View project code                                                               | ✓ (*1*)  | ✓        | ✓         | ✓          | ✓            |
| [**Projects**](project/index.md): View Requirements **(ULTIMATE)**                                                | ✓        | ✓        | ✓         | ✓          | ✓            |
| [**Projects**](project/index.md): Manage labels                                                                   |          | ✓        | ✓         | ✓          | ✓            |
| [**Projects**](project/index.md): Enable Review Apps                                                              |          |          | ✓         | ✓          | ✓            |
| [**Projects**](project/index.md): View project Audit Events                                                       |          |          | ✓ (*12*)  | ✓          | ✓            |
| [**Projects**](project/index.md): View project statistics                                                         |          |          | ✓         | ✓          | ✓            |
| [**Projects**](project/index.md): Add deploy keys                                                                 |          |          |           | ✓          | ✓            |
| [**Projects**](project/index.md): Add new team members                                                            |          |          |           | ✓          | ✓            |
| [**Projects**](project/index.md): Configure hooks                                                                 |          |          |           | ✓          | ✓            |
| [**Projects**](project/index.md): Edit comments (posted by any user)                                              |          |          |           | ✓          | ✓            |
| [**Projects**](project/index.md): Edit project badges                                                             |          |          |           | ✓          | ✓            |
| [**Projects**](project/index.md): Edit project settings                                                           |          |          |           | ✓          | ✓            |
| [**Projects**](project/index.md): Export project                                                                  |          |          |           | ✓          | ✓            |
| [**Projects**](project/index.md): Manage [project access tokens](project/settings/project_access_tokens.md) **(CORE ONLY)** |        |        |         | ✓        | ✓          |
| [**Projects**](project/index.md): Manage Project Operations                                                       |          |          |           | ✓          | ✓            |
| [**Projects**](project/index.md): Share (invite) projects with groups                                             |          |          |           | ✓ (*8*)    | ✓ (*8*)      |
| [**Projects**](project/index.md): Archive project                                                                 |          |          |           |            | ✓            |
| [**Projects**](project/index.md): Delete project                                                                  |          |          |           |            | ✓            |
| [**Projects**](project/index.md): Disable notification emails                                                     |          |          |           |            | ✓            |
| [**Projects**](project/index.md): Rename project                                                                  |          |          |           |            | ✓            |
| [**Projects**](project/index.md): Switch visibility level                                                         |          |          |           |            | ✓            |
| [**Projects**](project/index.md): Transfer project to another namespace                                           |          |          |           |            | ✓            |
| [**Releases**](project/releases/index.md): View                                                                   | ✓ (*6*)  | ✓        | ✓         | ✓          | ✓            |
| [**Releases**](project/releases/index.md): Create/edit/delete                                                     |          |          | ✓         | ✓          | ✓            |
| [**Repository**](project/repository/index.md): Pull project code                                                  | ✓ (*1*)  | ✓        | ✓         | ✓          | ✓            |
| [**Repository**](project/repository/index.md): Add tags                                                           |          |          | ✓         | ✓          | ✓            |
| [**Repository**](project/repository/index.md): See a commit status                                                |          | ✓        | ✓         | ✓          | ✓            |
| [**Repository**](project/repository/index.md): Create new branches                                                |          |          | ✓         | ✓          | ✓            |
| [**Repository**](project/repository/index.md): Create or update commit status                                     |          |          | ✓ (*5*)   | ✓          | ✓            |
| [**Repository**](project/repository/index.md): Force push to non-protected branches                               |          |          | ✓         | ✓          | ✓            |
| [**Repository**](project/repository/index.md): Push to non-protected branches                                     |          |          | ✓         | ✓          | ✓            |
| [**Repository**](project/repository/index.md): Remove non-protected branches                                      |          |          | ✓         | ✓          | ✓            |
| [**Repository**](project/repository/index.md): Rewrite/remove Git tags                                            |          |          | ✓         | ✓          | ✓            |
| [**Repository**](project/repository/index.md): Enable/disable branch protection                                   |          |          |           | ✓          | ✓            |
| [**Repository**](project/repository/index.md): Enable/disable tag protections                                     |          |          |           | ✓          | ✓            |
| [**Repository**](project/repository/index.md): Manage [push rules](../push_rules/push_rules.md)                   |          |          |           | ✓          | ✓            |
| [**Repository**](project/repository/index.md): Push to protected branches                                         |          |          |           | ✓          | ✓            |
| [**Repository**](project/repository/index.md): Turn on/off protected branch push for developers                   |          |          |           | ✓          | ✓            |
| [**Repository**](project/repository/index.md): Remove fork relationship                                           |          |          |           |            | ✓            |
| [**Repository**](project/repository/index.md): Force push to protected branches (*4*)                             |          |          |           |            |              |
| [**Repository**](project/repository/index.md): Remove protected branches (*4*)                                    |          |          |           |            |              |
| [**Requirements Management**](project/requirements/index.md): Archive/reopen **(ULTIMATE)**                       |          | ✓        | ✓         | ✓          | ✓            |
| [**Requirements Management**](project/requirements/index.md): Create/edit **(ULTIMATE)**                          |          | ✓        | ✓         | ✓          | ✓            |
| [**Requirements Management**](project/requirements/index.md): Import **(ULTIMATE)**                               |          | ✓        | ✓         | ✓          | ✓            |
| [**Security dashboard**](application_security/security_dashboard/index.md#vulnerability-report): View Security reports **(ULTIMATE)**                           | ✓ (*3*)  | ✓ | ✓ | ✓ | ✓ |
| [**Security dashboard**](application_security/security_dashboard/index.md#vulnerability-report): Create issue from vulnerability finding **(ULTIMATE)**         |          |   | ✓ | ✓ | ✓ |
| [**Security dashboard**](application_security/security_dashboard/index.md#vulnerability-report): Create vulnerability from vulnerability finding **(ULTIMATE)** |          |   | ✓ | ✓ | ✓ |
| [**Security dashboard**](application_security/security_dashboard/index.md#vulnerability-report): Dismiss vulnerability **(ULTIMATE)**                           |          |   | ✓ | ✓ | ✓ |
| [**Security dashboard**](application_security/security_dashboard/index.md#vulnerability-report): Dismiss vulnerability finding **(ULTIMATE)**                   |          |   | ✓ | ✓ | ✓ |
| [**Security dashboard**](application_security/security_dashboard/index.md#vulnerability-report): Resolve vulnerability **(ULTIMATE)**                           |          |   | ✓ | ✓ | ✓ |
| [**Security dashboard**](application_security/security_dashboard/index.md#vulnerability-report): Revert vulnerability to detected state **(ULTIMATE)**          |          |   | ✓ | ✓ | ✓ |
| [**Security dashboard**](application_security/security_dashboard/index.md#vulnerability-report): Use security dashboard **(ULTIMATE)**                          |          |   | ✓ | ✓ | ✓ |
| [**Security dashboard**](application_security/security_dashboard/index.md#vulnerability-report): View vulnerability **(ULTIMATE)**                              |          |   | ✓ | ✓ | ✓ |
| [**Security dashboard**](application_security/security_dashboard/index.md#vulnerability-report): View vulnerability findings in Dependency list **(ULTIMATE)**  |          |   | ✓ | ✓ | ✓ |
| [**Security dashboard**](application_security/security_dashboard/index.md#vulnerability-report): Request a CVE ID **(FREE ONLY)**                               |          |   |   | ✓ | ✓ |
| [**Snippets**](snippets.md): Create                                                                               |          | ✓        | ✓         | ✓          | ✓            |
| [**Terraform**](infrastructure/index.md): Read Terraform state                                                    |          |          | ✓         | ✓          | ✓            |
| [**Terraform**](infrastructure/index.md): Manage Terraform state                                                  |          |          |           | ✓          | ✓            |
| [**Test cases**](../ci/test_cases/index.md): Archive                                                              |          | ✓        | ✓         | ✓          | ✓            |
| [**Test cases**](../ci/test_cases/index.md): Create                                                               |          | ✓        | ✓         | ✓          | ✓            |
| [**Test cases**](../ci/test_cases/index.md): Move                                                                 |          | ✓        | ✓         | ✓          | ✓            |
| [**Test cases**](../ci/test_cases/index.md): Reopen                                                               |          | ✓        | ✓         | ✓          | ✓            |
| [**Wiki**](project/wiki/index.md): View                                                                           | ✓        | ✓        | ✓         | ✓          | ✓            |
| [**Wiki**](project/wiki/index.md): Create, edit                                                                   |          |          | ✓         | ✓          | ✓            |
| [**Wiki**](project/wiki/index.md): Delete                                                                         |          |          |           | ✓          | ✓            |

1. Guest users are able to perform this action on public and internal projects, but not private projects. This doesn't apply to [external users](#external-users) where explicit access must be given even if the project is internal.
1. Guest users can only view the confidential issues they created themselves.
1. If **Public pipelines** is enabled in **Project Settings > CI/CD**.
1. Not allowed for Guest, Reporter, Developer, Maintainer, or Owner. See [Protected Branches](project/protected_branches.md).
1. If the [branch is protected](project/protected_branches.md#using-the-allowed-to-merge-and-allowed-to-push-settings), this depends on the access Developers and Maintainers are given.
1. Guest users can access GitLab [**Releases**](project/releases/index.md) for downloading assets but are not allowed to download the source code nor see repository information like tags and commits.
1. Actions are limited only to records owned (referenced) by user.
1. When [Share Group Lock](group/index.md#share-with-group-lock) is enabled the project can't be shared with other groups. It does not affect group with group sharing.
1. For information on eligible approvers for merge requests, see
   [Eligible approvers](project/merge_requests/merge_request_approvals.md#eligible-approvers).
1. Owner permission is only available at the group or personal namespace level (and for instance admins) and is inherited by its projects.
1. Applies only to comments on [Design Management](project/issues/design_management.md) designs.
1. Users can only view events based on their individual actions.

## Project features permissions

### Wiki and issues

Project features like wiki and issues can be hidden from users depending on
which visibility level you select on project settings.

- Disabled: disabled for everyone
- Only team members: only team members can see even if your project is public or internal
- Everyone with access: everyone can see depending on your project's visibility level
- Everyone: enabled for everyone (only available for GitLab Pages)

### Protected branches

Additional restrictions can be applied on a per-branch basis with [protected branches](project/protected_branches.md).
Additionally, you can customize permissions to allow or prevent project
Maintainers and Developers from pushing to a protected branch. Read through the documentation on
[Allowed to Merge and Allowed to Push settings](project/protected_branches.md#using-the-allowed-to-merge-and-allowed-to-push-settings)
to learn more.

### Value Stream Analytics permissions

Find the current permissions on the Value Stream Analytics dashboard, as described in
[related documentation](analytics/value_stream_analytics.md#permissions).

### Issue Board permissions

Find the current permissions for interacting with the Issue Board feature in the
[Issue Boards permissions page](project/issue_board.md#permissions).

### File Locking permissions **(PREMIUM)**

The user that locks a file or directory is the only one that can edit and push their changes back to the repository where the locked objects are located.

Read through the documentation on [permissions for File Locking](project/file_lock.md#permissions) to learn more.

### Confidential Issues permissions

Confidential issues can be accessed by users with reporter and higher permission levels,
as well as by guest users that create a confidential issue. To learn more,
read through the documentation on [permissions and access to confidential issues](project/issues/confidential_issues.md#permissions-and-access-to-confidential-issues).

## Group members permissions

NOTE:
In GitLab 11.0, the Master role was renamed to Maintainer.

Any user can remove themselves from a group, unless they are the last Owner of
the group. The following table depicts the various user permission levels in a
group.

| Action                                                 | Guest | Reporter | Developer | Maintainer | Owner |
|--------------------------------------------------------|-------|----------|-----------|------------|-------|
| Browse group                                           | ✓     | ✓        | ✓         | ✓          | ✓     |
| View group wiki pages **(PREMIUM)**                    | ✓ (6) | ✓        | ✓         | ✓          | ✓     |
| View Insights charts **(ULTIMATE)**                    | ✓     | ✓        | ✓         | ✓          | ✓     |
| View group epic **(PREMIUM)**                         | ✓     | ✓        | ✓         | ✓          | ✓     |
| Create/edit group epic **(PREMIUM)**                  |       | ✓        | ✓         | ✓          | ✓     |
| Manage group labels                                    |       | ✓        | ✓         | ✓          | ✓     |
| See a container registry                               |       | ✓        | ✓         | ✓          | ✓     |
| Pull [packages](packages/index.md)                     |       | ✓        | ✓         | ✓          | ✓     |
| Publish [packages](packages/index.md)                  |       |          | ✓         | ✓          | ✓     |
| View metrics dashboard annotations                     |       | ✓        | ✓         | ✓          | ✓     |
| Create project in group                                |       |          | ✓ (3)(5)  | ✓ (3)      | ✓ (3) |
| Share (invite) groups with groups                      |       |          |           |            | ✓     |
| Create/edit/delete group milestones                    |       |          | ✓         | ✓          | ✓     |
| Create/edit/delete iterations                          |       |          | ✓         | ✓          | ✓     |
| Enable/disable a dependency proxy                      |       |          | ✓         | ✓          | ✓     |
| Create and edit group wiki pages **(PREMIUM)**         |       |          | ✓         | ✓          | ✓     |
| Use security dashboard **(ULTIMATE)**                  |       |          | ✓         | ✓          | ✓     |
| Create/edit/delete metrics dashboard annotations       |       |          | ✓         | ✓          | ✓     |
| View/manage group-level Kubernetes cluster             |       |          |           | ✓          | ✓     |
| Create subgroup                                        |       |          |           | ✓ (1)      | ✓     |
| Delete group wiki pages **(PREMIUM)**                  |       |          |           | ✓          | ✓     |
| Edit epic comments (posted by any user) **(ULTIMATE)** |       |          |           | ✓ (2)      | ✓ (2) |
| Edit group settings                                    |       |          |           |            | ✓     |
| Manage group level CI/CD variables                     |       |          |           |            | ✓     |
| List group deploy tokens                               |       |          |           | ✓          | ✓     |
| Create/Delete group deploy tokens                      |       |          |           |            | ✓     |
| Manage group members                                   |       |          |           |            | ✓     |
| Delete group                                           |       |          |           |            | ✓     |
| Delete group epic **(PREMIUM)**                       |       |          |           |            | ✓     |
| Edit SAML SSO Billing **(SILVER ONLY)**                | ✓     | ✓        | ✓         | ✓          | ✓ (4) |
| View group Audit Events                                |       |          | ✓ (7)     | ✓ (7)      | ✓     |
| Disable notification emails                            |       |          |           |            | ✓     |
| View Contribution analytics                            | ✓     | ✓        | ✓         | ✓          | ✓     |
| View Insights **(ULTIMATE)**                           | ✓     | ✓        | ✓         | ✓          | ✓     |
| View Issue analytics **(PREMIUM)**                     | ✓     | ✓        | ✓         | ✓          | ✓     |
| View Productivity analytics **(PREMIUM)**              |       | ✓        | ✓         | ✓          | ✓     |
| View Value Stream analytics                            | ✓     | ✓        | ✓         | ✓          | ✓     |
| View Billing **(FREE ONLY)**                           |       |          |           |            | ✓ (4) |
| View Usage Quotas **(FREE ONLY)**                      |       |          |           |            | ✓ (4) |
| Filter members by 2FA status                           |       |          |           |            | ✓     |

1. Groups can be set to [allow either Owners or Owners and
  Maintainers to create subgroups](group/subgroups/index.md#creating-a-subgroup)
1. Introduced in GitLab 12.2.
1. Default project creation role can be changed at:
   - The [instance level](admin_area/settings/visibility_and_access_controls.md#default-project-creation-protection).
   - The [group level](group/index.md#default-project-creation-level).
1. Does not apply to subgroups.
1. Developers can push commits to the default branch of a new project only if the [default branch protection](group/index.md#changing-the-default-branch-protection-of-a-group) is set to "Partially protected" or "Not protected".
1. In addition, if your group is public or internal, all users who can see the group can also see group wiki pages.
1. Users can only view events based on their individual actions.

### Subgroup permissions

When you add a member to a subgroup, they inherit the membership and
permission level from the parent group(s). This model allows access to
nested groups if you have membership in one of its parents.

To learn more, read through the documentation on
[subgroups memberships](group/subgroups/index.md#membership).

## External users **(CORE ONLY)**

In cases where it is desired that a user has access only to some internal or
private projects, there is the option of creating **External Users**. This
feature may be useful when for example a contractor is working on a given
project and should only have access to that project.

External users:

- Cannot create groups, projects, or personal snippets.
- Can only access public projects and projects to which they are explicitly granted access,
  thus hiding all other internal or private ones from them (like being
  logged out).
- Can only access public groups and groups to which they are explicitly granted access,
  thus hiding all other internal or private ones from them (like being
  logged out).
- Can only access public snippets.

Access can be granted by adding the user as member to the project or group.
Like usual users, they receive a role in the project or group with all
the abilities that are mentioned in the [permissions table above](#project-members-permissions).
For example, if an external user is added as Guest, and your project is internal or
private, they do not have access to the code; you need to grant the external
user access at the Reporter level or above if you want them to have access to the code. You should
always take into account the
[project's visibility and permissions settings](project/settings/index.md#sharing-and-permissions)
as well as the permission level of the user.

NOTE:
External users still count towards a license seat.

An administrator can flag a user as external by either of the following methods:

- Either [through the API](../api/users.md#user-modification).
- Or by navigating to the **Admin Area > Overview > Users** to create a new user
  or edit an existing one. There, you can find the option to flag the user as
  external.

### Setting new users to external

By default, new users are not set as external users. This behavior can be changed
by an administrator on the **Admin Area > Settings > General** page, under **Account and limit**.

If you change the default behavior of creating new users as external, you
have the option to narrow it down by defining a set of internal users.
The **Internal users** field allows specifying an email address regex pattern to
identify default internal users. New users whose email address matches the regex
pattern are set to internal by default rather than an external collaborator.

The regex pattern format is in Ruby, but it needs to be convertible to JavaScript,
and the ignore case flag is set (`/regex pattern/i`). Here are some examples:

- Use `\.internal@domain\.com$` to mark email addresses ending with
  `.internal@domain.com` as internal.
- Use `^(?:(?!\.ext@domain\.com).)*$\r?` to mark users with email addresses
  NOT including `.ext@domain.com` as internal.

WARNING:
Be aware that this regex could lead to a
[regular expression denial of service (ReDoS) attack](https://en.wikipedia.org/wiki/ReDoS).

## Free Guest users **(ULTIMATE)**

When a user is given Guest permissions on a project, group, or both, and holds no
higher permission level on any other project or group on the GitLab instance,
the user is considered a guest user by GitLab and does not consume a license seat.
There is no other specific "guest" designation for newly created users.

If the user is assigned a higher role on any projects or groups, the user
takes a license seat. If a user creates a project, the user becomes a Maintainer
on the project, resulting in the use of a license seat. Also, note that if your
project is internal or private, Guest users have all the abilities that are
mentioned in the [permissions table above](#project-members-permissions) (they
are unable to browse the project's repository, for example).

NOTE:
To prevent a guest user from creating projects, as an admin, you can edit the
user's profile to mark the user as [external](#external-users).
Beware though that even if a user is external, if they already have Reporter or
higher permissions in any project or group, they are **not** counted as a
free guest user.

## Auditor users **(PREMIUM ONLY)**

>[Introduced](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/998) in [GitLab Premium](https://about.gitlab.com/pricing/) 8.17.

Auditor users are given read-only access to all projects, groups, and other
resources on the GitLab instance.

An Auditor user should be able to access all projects and groups of a GitLab instance
with the permissions described on the documentation on [auditor users permissions](../administration/auditor_users.md#permissions-and-restrictions-of-an-auditor-user).

[Read more about Auditor users.](../administration/auditor_users.md)

## Users with minimal access **(PREMIUM)**

>[Introduced](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/40942) in [GitLab Premium](https://about.gitlab.com/pricing/) 13.4.

Administrators can add members with a "minimal access" role to a parent group. Such users don't
automatically have access to projects and subgroups underneath. To support such access, administrators must explicitly add these "minimal access" users to the specific subgroups/projects.

Users with minimal access can list the group in the UI and through the API. However, they cannot see
details such as projects or subgroups. They do not have access to the group's page or list any of its subgroups or projects.

### Minimal access users take license seats

Users with even a "minimal access" role are counted against your number of license seats. This
requirement does not apply for [GitLab Gold/Ultimate](https://about.gitlab.com/pricing/) subscriptions.

## Project features

Project features like wiki and issues can be hidden from users depending on
which visibility level you select on project settings.

- Disabled: disabled for everyone
- Only team members: only team members will see even if your project is public or internal
- Everyone with access: everyone can see depending on your project visibility level
- Everyone: enabled for everyone (only available for GitLab Pages)

## GitLab CI/CD permissions

NOTE:
In GitLab 11.0, the Master role was renamed to Maintainer.

GitLab CI/CD permissions rely on the role the user has in GitLab. There are four
permission levels in total:

- admin
- maintainer
- developer
- guest/reporter

The admin user can perform any action on GitLab CI/CD in scope of the GitLab
instance and project. In addition, all admins can use the admin interface under
`/admin/runners`.

| Action                                | Guest, Reporter | Developer   |Maintainer| Admin  |
|---------------------------------------|-----------------|-------------|----------|--------|
| See commits and jobs                  | ✓               | ✓           | ✓        | ✓      |
| Retry or cancel job                   |                 | ✓           | ✓        | ✓      |
| Erase job artifacts and job logs      |                 | ✓ (*1*)     | ✓        | ✓      |
| Delete project                        |                 |             | ✓        | ✓      |
| Create project                        |                 |             | ✓        | ✓      |
| Change project configuration          |                 |             | ✓        | ✓      |
| Add specific runners                  |                 |             | ✓        | ✓      |
| Add shared runners                    |                 |             |          | ✓      |
| See events in the system              |                 |             |          | ✓      |
| Admin interface                       |                 |             |          | ✓      |

1. Only if the job was:
   - Triggered by the user
   - [In GitLab 13.0](https://gitlab.com/gitlab-org/gitlab/-/issues/35069) and later, not run for a protected branch

### Job permissions

NOTE:
In GitLab 11.0, the Master role was renamed to Maintainer.

NOTE:
GitLab 8.12 has a completely redesigned job permissions system.
Read all about the [new model and its implications](project/new_ci_build_permissions_model.md).

This table shows granted privileges for jobs triggered by specific types of
users:

| Action                                      | Guest, Reporter | Developer   |Maintainer| Admin   |
|---------------------------------------------|-----------------|-------------|----------|---------|
| Run CI job                                  |                 | ✓           | ✓        | ✓       |
| Clone source and LFS from current project   |                 | ✓           | ✓        | ✓       |
| Clone source and LFS from public projects   |                 | ✓           | ✓        | ✓       |
| Clone source and LFS from internal projects |                 | ✓ (*1*)     | ✓  (*1*) | ✓       |
| Clone source and LFS from private projects  |                 | ✓ (*2*)     | ✓  (*2*) | ✓ (*2*) |
| Pull container images from current project  |                 | ✓           | ✓        | ✓       |
| Pull container images from public projects  |                 | ✓           | ✓        | ✓       |
| Pull container images from internal projects|                 | ✓ (*1*)     | ✓  (*1*) | ✓       |
| Pull container images from private projects |                 | ✓ (*2*)     | ✓  (*2*) | ✓ (*2*) |
| Push container images to current project    |                 | ✓           | ✓        | ✓       |
| Push container images to other projects     |                 |             |          |         |
| Push source and LFS                         |                 |             |          |         |

1. Only if the user is not an external one
1. Only if the user is a member of the project

### New CI job permissions model

GitLab 8.12 has a completely redesigned job permissions system. To learn more,
read through the documentation on the [new CI/CD permissions model](project/new_ci_build_permissions_model.md#new-ci-job-permissions-model).

## Running pipelines on protected branches

The permission to merge or push to protected branches is used to define if a user can
run CI/CD pipelines and execute actions on jobs that are related to those branches.

See [Security on protected branches](../ci/pipelines/index.md#pipeline-security-on-protected-branches)
for details about the pipelines security model.

## LDAP users permissions

In GitLab 8.15 and later, LDAP user permissions can now be manually overridden by an admin user.
Read through the documentation on [LDAP users permissions](group/index.md#manage-group-memberships-via-ldap) to learn more.

## Project aliases

Project aliases can only be read, created and deleted by a GitLab administrator.
Read through the documentation on [Project aliases](../user/project/index.md#project-aliases) to learn more.
