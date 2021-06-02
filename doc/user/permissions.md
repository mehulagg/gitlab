---
stage: Manage
group: Access
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#assignments
---

# Permissions and roles **(FREE)**

Users have different abilities depending on the role they have in a
particular group or project. If a user is both in a project's group and the
project itself, the highest role is used.

On public and internal projects, the Guest role is not enforced. All users can:

- Create issues.
- Leave comments.
- Clone or download the project code.

When a member leaves a team's project, all the assigned [Issues](project/issues/index.md) and [merge requests](project/merge_requests/index.md)
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

The Owner role is only available at the group or personal namespace level (and for instance administrators) and is inherited by its projects.
While Maintainer is the highest project-level role, some actions can only be performed by a personal namespace or group owner, or an instance administrator, who receives all permissions.
For more information, see [projects members documentation](project/members/index.md).

The following table lists project permissions available for each role:

| Action                                            | Guest | Reporter | Developer | Maintainer | Owner |
|---------------------------------------------------|-------|----------|-----------|------------|-------|
| Download project                                  | **{check-circle}** Yes (*1*) | **{check-circle}** Yes | **{check-circle}** Yes | **{check-circle}** Yes | **{check-circle}** Yes |
| Leave comments                                    | **{check-circle}** Yes | **{check-circle}** Yes | **{check-circle}** Yes | **{check-circle}** Yes | **{check-circle}** Yes |
| View allowed and denied licenses **(ULTIMATE)**   | **{check-circle}** Yes (*1*) | **{check-circle}** Yes | **{check-circle}** Yes | **{check-circle}** Yes | **{check-circle}** Yes |
| View License Compliance reports **(ULTIMATE)**    | **{check-circle}** Yes (*1*) | **{check-circle}** Yes | **{check-circle}** Yes | **{check-circle}** Yes | **{check-circle}** Yes |
| View Security reports **(ULTIMATE)**              | **{check-circle}** Yes (*3*) | **{check-circle}** Yes | **{check-circle}** Yes | **{check-circle}** Yes | **{check-circle}** Yes |
| View Dependency list **(ULTIMATE)**               | **{check-circle}** Yes (*1*) | **{check-circle}** Yes | **{check-circle}** Yes | **{check-circle}** Yes | **{check-circle}** Yes |
| View License list **(ULTIMATE)**                  | **{check-circle}** Yes (*1*) | **{check-circle}** Yes | **{check-circle}** Yes | **{check-circle}** Yes | **{check-circle}** Yes |
| View licenses in Dependency list **(ULTIMATE)**   | **{check-circle}** Yes (*1*) | **{check-circle}** Yes | **{check-circle}** Yes | **{check-circle}** Yes | **{check-circle}** Yes |
| View [Design Management](project/issues/design_management.md) pages | **{check-circle}** Yes | **{check-circle}** Yes | **{check-circle}** Yes | **{check-circle}** Yes | **{check-circle}** Yes |
| View project code                                 | **{check-circle}** Yes (*1*) | **{check-circle}** Yes | **{check-circle}** Yes | **{check-circle}** Yes | **{check-circle}** Yes |
| Pull project code                                 | **{check-circle}** Yes (*1*) | **{check-circle}** Yes | **{check-circle}** Yes | **{check-circle}** Yes | **{check-circle}** Yes |
| View GitLab Pages protected by [access control](project/pages/introduction.md#gitlab-pages-access-control) | **{check-circle}** Yes | **{check-circle}** Yes | **{check-circle}** Yes | **{check-circle}** Yes | **{check-circle}** Yes |
| View wiki pages                                   | **{check-circle}** Yes | **{check-circle}** Yes | **{check-circle}** Yes | **{check-circle}** Yes | **{check-circle}** Yes |
| See a list of jobs                                | **{check-circle}** Yes (*3*) | **{check-circle}** Yes | **{check-circle}** Yes | **{check-circle}** Yes | **{check-circle}** Yes |
| See a job log                                     | **{check-circle}** Yes (*3*) | **{check-circle}** Yes | **{check-circle}** Yes | **{check-circle}** Yes | **{check-circle}** Yes |
| See a job with [debug logging](../ci/variables/README.md#debug-logging) | **{dotted-circle}** No | **{dotted-circle}** No | **{check-circle}** Yes | **{check-circle}** Yes | **{check-circle}** Yes |
| Download and browse job artifacts                 | **{check-circle}** Yes (*3*) | **{check-circle}** Yes | **{check-circle}** Yes | **{check-circle}** Yes | **{check-circle}** Yes |
| Create confidential issue                         | **{check-circle}** Yes | **{check-circle}** Yes | **{check-circle}** Yes | **{check-circle}** Yes | **{check-circle}** Yes |
| Create new issue                                  | **{check-circle}** Yes | **{check-circle}** Yes | **{check-circle}** Yes | **{check-circle}** Yes | **{check-circle}** Yes |
| See linked issues                                 | **{check-circle}** Yes | **{check-circle}** Yes | **{check-circle}** Yes | **{check-circle}** Yes | **{check-circle}** Yes |
| View [Releases](project/releases/index.md)        | **{check-circle}** Yes (*6*) | **{check-circle}** Yes | **{check-circle}** Yes | **{check-circle}** Yes | **{check-circle}** Yes |
| View requirements **(ULTIMATE)**                  | **{check-circle}** Yes | **{check-circle}** Yes | **{check-circle}** Yes | **{check-circle}** Yes | **{check-circle}** Yes |
| View Insights **(ULTIMATE)**                      | **{check-circle}** Yes | **{check-circle}** Yes | **{check-circle}** Yes | **{check-circle}** Yes | **{check-circle}** Yes |
| View issue analytics **(PREMIUM)**                | **{check-circle}** Yes | **{check-circle}** Yes | **{check-circle}** Yes | **{check-circle}** Yes | **{check-circle}** Yes |
| View merge request analytics **(STARTER)**        | **{check-circle}** Yes | **{check-circle}** Yes | **{check-circle}** Yes | **{check-circle}** Yes | **{check-circle}** Yes |
| View Value Stream analytics                       | **{check-circle}** Yes | **{check-circle}** Yes | **{check-circle}** Yes | **{check-circle}** Yes | **{check-circle}** Yes |
| Manage user-starred metrics dashboards (*7*)      | **{check-circle}** Yes | **{check-circle}** Yes | **{check-circle}** Yes | **{check-circle}** Yes | **{check-circle}** Yes |
| View confidential issues                          | **{check-circle}** Yes (*2*) | **{check-circle}** Yes | **{check-circle}** Yes | **{check-circle}** Yes | **{check-circle}** Yes |
| Assign issues                                     | **{dotted-circle}** No | **{check-circle}** Yes | **{check-circle}** Yes | **{check-circle}** Yes | **{check-circle}** Yes |
| Assign reviewers                                  | **{dotted-circle}** No | **{check-circle}** Yes | **{check-circle}** Yes | **{check-circle}** Yes | **{check-circle}** Yes |
| Label issues                                      | **{dotted-circle}** No | **{check-circle}** Yes | **{check-circle}** Yes | **{check-circle}** Yes | **{check-circle}** Yes |
| Set issue weight                                  | **{dotted-circle}** No | **{check-circle}** Yes | **{check-circle}** Yes | **{check-circle}** Yes | **{check-circle}** Yes |
| [Set issue estimate and record time spent](project/time_tracking.md) | **{dotted-circle}** No | **{check-circle}** Yes | **{check-circle}** Yes | **{check-circle}** Yes | **{check-circle}** Yes |
| View a time tracking report                       | **{check-circle}** Yes (*1*) | **{check-circle}** Yes | **{check-circle}** Yes | **{check-circle}** Yes | **{check-circle}** Yes |
| Lock issue threads                                | **{dotted-circle}** No | **{check-circle}** Yes | **{check-circle}** Yes | **{check-circle}** Yes | **{check-circle}** Yes |
| Manage issue tracker                              | **{dotted-circle}** No | **{check-circle}** Yes | **{check-circle}** Yes | **{check-circle}** Yes | **{check-circle}** Yes |
| Manage linked issues                              | **{dotted-circle}** No | **{check-circle}** Yes | **{check-circle}** Yes | **{check-circle}** Yes | **{check-circle}** Yes |
| Manage labels                                     | **{dotted-circle}** No | **{check-circle}** Yes | **{check-circle}** Yes | **{check-circle}** Yes | **{check-circle}** Yes |
| Create code snippets                              | **{dotted-circle}** No | **{check-circle}** Yes | **{check-circle}** Yes | **{check-circle}** Yes | **{check-circle}** Yes |
| See a commit status                               | **{dotted-circle}** No | **{check-circle}** Yes | **{check-circle}** Yes | **{check-circle}** Yes | **{check-circle}** Yes |
| See a container registry                          | **{dotted-circle}** No | **{check-circle}** Yes | **{check-circle}** Yes | **{check-circle}** Yes | **{check-circle}** Yes |
| See environments                                  | **{dotted-circle}** No | **{check-circle}** Yes | **{check-circle}** Yes | **{check-circle}** Yes | **{check-circle}** Yes |
| See [DORA metrics](analytics/ci_cd_analytics.md)  | **{dotted-circle}** No | **{check-circle}** Yes | **{check-circle}** Yes | **{check-circle}** Yes | **{check-circle}** Yes |
| See a list of merge requests                      | **{dotted-circle}** No | **{check-circle}** Yes | **{check-circle}** Yes | **{check-circle}** Yes | **{check-circle}** Yes |
| View CI/CD analytics                              | **{dotted-circle}** No | **{check-circle}** Yes | **{check-circle}** Yes | **{check-circle}** Yes | **{check-circle}** Yes |
| View Code Review analytics **(STARTER)**          | **{dotted-circle}** No | **{check-circle}** Yes | **{check-circle}** Yes | **{check-circle}** Yes | **{check-circle}** Yes |
| View Repository analytics                         | **{dotted-circle}** No | **{check-circle}** Yes | **{check-circle}** Yes | **{check-circle}** Yes | **{check-circle}** Yes |
| View Error Tracking list                          | **{dotted-circle}** No | **{check-circle}** Yes | **{check-circle}** Yes | **{check-circle}** Yes | **{check-circle}** Yes |
| View metrics dashboard annotations                | **{dotted-circle}** No | **{check-circle}** Yes | **{check-circle}** Yes | **{check-circle}** Yes | **{check-circle}** Yes |
| Archive/reopen requirements **(ULTIMATE)**        | **{dotted-circle}** No | **{check-circle}** Yes | **{check-circle}** Yes | **{check-circle}** Yes | **{check-circle}** Yes |
| Create/edit requirements **(ULTIMATE)**           | **{dotted-circle}** No | **{check-circle}** Yes | **{check-circle}** Yes | **{check-circle}** Yes | **{check-circle}** Yes |
| Import/export requirements **(ULTIMATE)**         | **{dotted-circle}** No | **{check-circle}** Yes | **{check-circle}** Yes | **{check-circle}** Yes | **{check-circle}** Yes |
| Create new [test case](../ci/test_cases/index.md) | **{dotted-circle}** No | **{check-circle}** Yes | **{check-circle}** Yes | **{check-circle}** Yes | **{check-circle}** Yes |
| Archive [test case](../ci/test_cases/index.md)    | **{dotted-circle}** No | **{check-circle}** Yes | **{check-circle}** Yes | **{check-circle}** Yes | **{check-circle}** Yes |
| Move [test case](../ci/test_cases/index.md)       | **{dotted-circle}** No | **{check-circle}** Yes | **{check-circle}** Yes | **{check-circle}** Yes | **{check-circle}** Yes |
| Reopen [test case](../ci/test_cases/index.md)     | **{dotted-circle}** No | **{check-circle}** Yes | **{check-circle}** Yes | **{check-circle}** Yes | **{check-circle}** Yes |
| Pull [packages](packages/index.md)                | **{dotted-circle}** No | **{check-circle}** Yes | **{check-circle}** Yes | **{check-circle}** Yes | **{check-circle}** Yes |
| Publish [packages](packages/index.md)             | **{dotted-circle}** No | **{dotted-circle}** No | **{check-circle}** Yes | **{check-circle}** Yes | **{check-circle}** Yes |
| Create/edit/delete a Cleanup policy               | **{dotted-circle}** No | **{dotted-circle}** No | **{check-circle}** Yes | **{check-circle}** Yes | **{check-circle}** Yes |
| Upload [Design Management](project/issues/design_management.md) files | **{dotted-circle}** No | **{dotted-circle}** No | **{check-circle}** Yes | **{check-circle}** Yes | **{check-circle}** Yes |
| Create/edit [releases](project/releases/index.md) | **{dotted-circle}** No | **{dotted-circle}** No | **{check-circle}** Yes | **{check-circle}** Yes | **{check-circle}** Yes |
| Delete [releases](project/releases/index.md)      | **{dotted-circle}** No | **{dotted-circle}** No | **{dotted-circle}** No | **{check-circle}** Yes | **{check-circle}** Yes |
| Manage merge approval rules (project settings)    | **{dotted-circle}** No | **{dotted-circle}** No | **{dotted-circle}** No | **{check-circle}** Yes | **{check-circle}** Yes |
| Create new merge request                          | **{dotted-circle}** No | **{dotted-circle}** No | **{check-circle}** Yes | **{check-circle}** Yes | **{check-circle}** Yes |
| Create new branches                               | **{dotted-circle}** No | **{dotted-circle}** No | **{check-circle}** Yes | **{check-circle}** Yes | **{check-circle}** Yes |
| Push to non-protected branches                    | **{dotted-circle}** No | **{dotted-circle}** No | **{check-circle}** Yes | **{check-circle}** Yes | **{check-circle}** Yes |
| Force push to non-protected branches              | **{dotted-circle}** No | **{dotted-circle}** No | **{check-circle}** Yes | **{check-circle}** Yes | **{check-circle}** Yes |
| Remove non-protected branches                     | **{dotted-circle}** No | **{dotted-circle}** No | **{check-circle}** Yes | **{check-circle}** Yes | **{check-circle}** Yes |
| Assign merge requests                             | **{dotted-circle}** No | **{dotted-circle}** No | **{check-circle}** Yes | **{check-circle}** Yes | **{check-circle}** Yes |
| Label merge requests                              | **{dotted-circle}** No | **{dotted-circle}** No | **{check-circle}** Yes | **{check-circle}** Yes | **{check-circle}** Yes |
| Lock merge request threads                        | **{dotted-circle}** No | **{dotted-circle}** No | **{check-circle}** Yes | **{check-circle}** Yes | **{check-circle}** Yes |
| Approve merge requests (*9*)                      | **{dotted-circle}** No | **{dotted-circle}** No | **{check-circle}** Yes | **{check-circle}** Yes | **{check-circle}** Yes |
| Manage/Accept merge requests                      | **{dotted-circle}** No | **{dotted-circle}** No | **{check-circle}** Yes | **{check-circle}** Yes | **{check-circle}** Yes |
| View project statistics                           | **{dotted-circle}** No | **{dotted-circle}** No | **{check-circle}** Yes | **{check-circle}** Yes | **{check-circle}** Yes |
| Create new environments                           | **{dotted-circle}** No | **{dotted-circle}** No | **{check-circle}** Yes | **{check-circle}** Yes | **{check-circle}** Yes |
| Stop environments                                 | **{dotted-circle}** No | **{dotted-circle}** No | **{check-circle}** Yes | **{check-circle}** Yes | **{check-circle}** Yes |
| Enable Review Apps                                | **{dotted-circle}** No | **{dotted-circle}** No | **{check-circle}** Yes | **{check-circle}** Yes | **{check-circle}** Yes |
| View Pods logs                                    | **{dotted-circle}** No | **{dotted-circle}** No | **{check-circle}** Yes | **{check-circle}** Yes | **{check-circle}** Yes |
| Read Terraform state                              | **{dotted-circle}** No | **{dotted-circle}** No | **{check-circle}** Yes | **{check-circle}** Yes | **{check-circle}** Yes |
| Add tags                                          | **{dotted-circle}** No | **{dotted-circle}** No | **{check-circle}** Yes | **{check-circle}** Yes | **{check-circle}** Yes |
| Cancel and retry jobs                             | **{dotted-circle}** No | **{dotted-circle}** No | **{check-circle}** Yes | **{check-circle}** Yes | **{check-circle}** Yes |
| Create or update commit status                    | **{dotted-circle}** No | **{dotted-circle}** No | **{check-circle}** Yes (*5*) | **{check-circle}** Yes | **{check-circle}** Yes |
| Update a container registry                       | **{dotted-circle}** No | **{dotted-circle}** No | **{check-circle}** Yes | **{check-circle}** Yes | **{check-circle}** Yes |
| Remove a container registry image                 | **{dotted-circle}** No | **{dotted-circle}** No | **{check-circle}** Yes | **{check-circle}** Yes | **{check-circle}** Yes |
| Create/edit/delete project milestones             | **{dotted-circle}** No | **{dotted-circle}** No | **{check-circle}** Yes | **{check-circle}** Yes | **{check-circle}** Yes |
| Use security dashboard **(ULTIMATE)**             | **{dotted-circle}** No | **{dotted-circle}** No | **{check-circle}** Yes | **{check-circle}** Yes | **{check-circle}** Yes |
| View vulnerability findings in Dependency list **(ULTIMATE)** | **{dotted-circle}** No | **{dotted-circle}** No | **{check-circle}** Yes | **{check-circle}** Yes | **{check-circle}** Yes |
| Create issue from vulnerability finding **(ULTIMATE)** | **{dotted-circle}** No | **{dotted-circle}** No | **{check-circle}** Yes | **{check-circle}** Yes | **{check-circle}** Yes |
| Dismiss vulnerability finding **(ULTIMATE)**      | **{dotted-circle}** No | **{dotted-circle}** No | **{check-circle}** Yes | **{check-circle}** Yes | **{check-circle}** Yes |
| View vulnerability **(ULTIMATE)**                 | **{dotted-circle}** No | **{dotted-circle}** No | **{check-circle}** Yes | **{check-circle}** Yes | **{check-circle}** Yes |
| Create vulnerability from vulnerability finding **(ULTIMATE)** | **{dotted-circle}** No | **{dotted-circle}** No | **{check-circle}** Yes | **{check-circle}** Yes | **{check-circle}** Yes |
| Resolve vulnerability **(ULTIMATE)**              | **{dotted-circle}** No | **{dotted-circle}** No | **{check-circle}** Yes | **{check-circle}** Yes | **{check-circle}** Yes |
| Dismiss vulnerability **(ULTIMATE)**              | **{dotted-circle}** No | **{dotted-circle}** No | **{check-circle}** Yes | **{check-circle}** Yes | **{check-circle}** Yes |
| Revert vulnerability to detected state **(ULTIMATE)** | **{dotted-circle}** No | **{dotted-circle}** No | **{check-circle}** Yes | **{check-circle}** Yes | **{check-circle}** Yes |
| Apply code change suggestions                     | **{dotted-circle}** No | **{dotted-circle}** No | **{check-circle}** Yes | **{check-circle}** Yes | **{check-circle}** Yes |
| Create and edit wiki pages                        | **{dotted-circle}** No | **{dotted-circle}** No | **{check-circle}** Yes | **{check-circle}** Yes | **{check-circle}** Yes |
| Rewrite/remove Git tags                           | **{dotted-circle}** No | **{dotted-circle}** No | **{check-circle}** Yes | **{check-circle}** Yes | **{check-circle}** Yes |
| Manage Feature Flags **(PREMIUM)**                | **{dotted-circle}** No | **{dotted-circle}** No | **{check-circle}** Yes | **{check-circle}** Yes | **{check-circle}** Yes |
| Create/edit/delete metrics dashboard annotations  | **{dotted-circle}** No | **{dotted-circle}** No | **{check-circle}** Yes | **{check-circle}** Yes | **{check-circle}** Yes |
| Run CI/CD pipeline against a protected branch     | **{dotted-circle}** No | **{dotted-circle}** No | **{check-circle}** Yes (*5*) | **{check-circle}** Yes | **{check-circle}** Yes |
| Delete [packages](packages/index.md)              | **{dotted-circle}** No | **{dotted-circle}** No | **{dotted-circle}** No | **{check-circle}** Yes | **{check-circle}** Yes |
| Request a CVE ID **(FREE SAAS)**                  | **{dotted-circle}** No | **{dotted-circle}** No | **{dotted-circle}** No | **{check-circle}** Yes | **{check-circle}** Yes |
| Use environment terminals                         | **{dotted-circle}** No | **{dotted-circle}** No | **{dotted-circle}** No | **{check-circle}** Yes | **{check-circle}** Yes |
| Run Web IDE's Interactive Web Terminals **(ULTIMATE SELF)** | **{dotted-circle}** No | **{dotted-circle}** No | **{dotted-circle}** No | **{check-circle}** Yes | **{check-circle}** Yes |
| Add new team members                              | **{dotted-circle}** No | **{dotted-circle}** No | **{dotted-circle}** No | **{check-circle}** Yes | **{check-circle}** Yes |
| Enable/disable branch protection                  | **{dotted-circle}** No | **{dotted-circle}** No | **{dotted-circle}** No | **{check-circle}** Yes | **{check-circle}** Yes |
| Push to protected branches                        | **{dotted-circle}** No | **{dotted-circle}** No | **{dotted-circle}** No | **{check-circle}** Yes | **{check-circle}** Yes |
| Turn on/off protected branch push for developers  | **{dotted-circle}** No | **{dotted-circle}** No | **{dotted-circle}** No | **{check-circle}** Yes | **{check-circle}** Yes |
| Enable/disable tag protections                    | **{dotted-circle}** No | **{dotted-circle}** No | **{dotted-circle}** No | **{check-circle}** Yes | **{check-circle}** Yes |
| Edit project settings                             | **{dotted-circle}** No | **{dotted-circle}** No | **{dotted-circle}** No | **{check-circle}** Yes | **{check-circle}** Yes |
| Edit project badges                               | **{dotted-circle}** No | **{dotted-circle}** No | **{dotted-circle}** No | **{check-circle}** Yes | **{check-circle}** Yes |
| Export project                                    | **{dotted-circle}** No | **{dotted-circle}** No | **{dotted-circle}** No | **{check-circle}** Yes | **{check-circle}** Yes |
| Share (invite) projects with groups               | **{dotted-circle}** No | **{dotted-circle}** No |**{dotted-circle}** No| **{check-circle}** Yes (*8*) | **{check-circle}** Yes (*8*) |
| Add deploy keys to project                        | **{dotted-circle}** No | **{dotted-circle}** No | **{dotted-circle}** No | **{check-circle}** Yes | **{check-circle}** Yes |
| Configure project hooks                           | **{dotted-circle}** No | **{dotted-circle}** No | **{dotted-circle}** No | **{check-circle}** Yes | **{check-circle}** Yes |
| Manage runners                                    | **{dotted-circle}** No | **{dotted-circle}** No | **{dotted-circle}** No | **{check-circle}** Yes | **{check-circle}** Yes |
| Manage job triggers                               | **{dotted-circle}** No | **{dotted-circle}** No | **{dotted-circle}** No | **{check-circle}** Yes | **{check-circle}** Yes |
| Manage CI/CD variables                            | **{dotted-circle}** No | **{dotted-circle}** No | **{dotted-circle}** No | **{check-circle}** Yes | **{check-circle}** Yes |
| Manage GitLab Pages                               | **{dotted-circle}** No | **{dotted-circle}** No | **{dotted-circle}** No | **{check-circle}** Yes | **{check-circle}** Yes |
| Manage GitLab Pages domains and certificates      | **{dotted-circle}** No | **{dotted-circle}** No | **{dotted-circle}** No | **{check-circle}** Yes | **{check-circle}** Yes |
| Remove GitLab Pages                               | **{dotted-circle}** No | **{dotted-circle}** No | **{dotted-circle}** No | **{check-circle}** Yes | **{check-circle}** Yes |
| Manage clusters                                   | **{dotted-circle}** No | **{dotted-circle}** No | **{dotted-circle}** No | **{check-circle}** Yes | **{check-circle}** Yes |
| Manage Project Operations                         | **{dotted-circle}** No | **{dotted-circle}** No | **{dotted-circle}** No | **{check-circle}** Yes | **{check-circle}** Yes |
| Manage Terraform state                            | **{dotted-circle}** No | **{dotted-circle}** No | **{dotted-circle}** No | **{check-circle}** Yes | **{check-circle}** Yes |
| Manage license policy **(ULTIMATE)**              | **{dotted-circle}** No | **{dotted-circle}** No | **{dotted-circle}** No | **{check-circle}** Yes | **{check-circle}** Yes |
| Edit comments (posted by any user)                | **{dotted-circle}** No | **{dotted-circle}** No | **{dotted-circle}** No | **{check-circle}** Yes | **{check-circle}** Yes |
| Reposition comments on images (posted by any user) | **{check-circle}** Yes (*10*) | **{check-circle}** Yes (*10*) | **{check-circle}** Yes (*10*) | **{check-circle}** Yes | **{check-circle}** Yes |
| Manage Error Tracking                             | **{dotted-circle}** No | **{dotted-circle}** No | **{dotted-circle}** No | **{check-circle}** Yes | **{check-circle}** Yes |
| Delete wiki pages                                 | **{dotted-circle}** No | **{dotted-circle}** No | **{dotted-circle}** No | **{check-circle}** Yes | **{check-circle}** Yes |
| View project Audit Events                         | **{dotted-circle}** No | **{dotted-circle}** No | **{check-circle}** Yes (*11*) | **{check-circle}** Yes | **{check-circle}** Yes |
| Manage [push rules](../push_rules/push_rules.md)  | **{dotted-circle}** No | **{dotted-circle}** No | **{dotted-circle}** No | **{check-circle}** Yes | **{check-circle}** Yes |
| Manage [project access tokens](project/settings/project_access_tokens.md) **(FREE SELF)** **(PREMIUM SAAS)** (*12*) | **{dotted-circle}** No | **{dotted-circle}** No | **{dotted-circle}** No | **{check-circle}** Yes | **{check-circle}** Yes |
| View 2FA status of members                        | **{dotted-circle}** No | **{dotted-circle}** No | **{dotted-circle}** No | **{check-circle}** Yes | **{check-circle}** Yes |
| Switch visibility level                           | **{dotted-circle}** No | **{dotted-circle}** No | **{dotted-circle}** No | **{dotted-circle}** No | **{check-circle}** Yes |
| Transfer project to another namespace             | **{dotted-circle}** No | **{dotted-circle}** No | **{dotted-circle}** No | **{dotted-circle}** No | **{check-circle}** Yes |
| Rename project                                    | **{dotted-circle}** No | **{dotted-circle}** No | **{dotted-circle}** No | **{dotted-circle}** No | **{check-circle}** Yes |
| Remove fork relationship                          | **{dotted-circle}** No | **{dotted-circle}** No | **{dotted-circle}** No | **{dotted-circle}** No | **{check-circle}** Yes |
| Delete project                                    | **{dotted-circle}** No | **{dotted-circle}** No | **{dotted-circle}** No | **{dotted-circle}** No | **{check-circle}** Yes |
| Archive project                                   | **{dotted-circle}** No | **{dotted-circle}** No | **{dotted-circle}** No | **{dotted-circle}** No | **{check-circle}** Yes |
| Delete issues                                     | **{dotted-circle}** No | **{dotted-circle}** No | **{dotted-circle}** No | **{dotted-circle}** No | **{check-circle}** Yes |
| Delete pipelines                                  | **{dotted-circle}** No | **{dotted-circle}** No | **{dotted-circle}** No | **{dotted-circle}** No | **{check-circle}** Yes |
| Delete merge request                              | **{dotted-circle}** No | **{dotted-circle}** No | **{dotted-circle}** No | **{dotted-circle}** No | **{check-circle}** Yes |
| Disable notification emails                       | **{dotted-circle}** No | **{dotted-circle}** No | **{dotted-circle}** No | **{dotted-circle}** No | **{check-circle}** Yes |
| Administer project compliance frameworks          | **{dotted-circle}** No | **{dotted-circle}** No | **{dotted-circle}** No | **{dotted-circle}** No | **{check-circle}** Yes |
| Force push to protected branches (*4*)            | **{dotted-circle}** No | **{dotted-circle}** No | **{dotted-circle}** No | **{dotted-circle}** No | **{dotted-circle}** No |
| Remove protected branches (*4*)                   | **{dotted-circle}** No | **{dotted-circle}** No | **{dotted-circle}** No | **{dotted-circle}** No | **{dotted-circle}** No |

1. Guest users are able to perform this action on public and internal projects, but not private projects. This doesn't apply to [external users](#external-users) where explicit access must be given even if the project is internal.
1. Guest users can only view the confidential issues they created themselves.
1. If **Public pipelines** is enabled in **Project Settings > CI/CD**.
1. Not allowed for Guest, Reporter, Developer, Maintainer, or Owner. See [protected branches](project/protected_branches.md).
1. If the [branch is protected](project/protected_branches.md#using-the-allowed-to-merge-and-allowed-to-push-settings), this depends on the access Developers and Maintainers are given.
1. Guest users can access GitLab [**Releases**](project/releases/index.md) for downloading assets but are not allowed to download the source code nor see repository information like tags and commits.
1. Actions are limited only to records owned (referenced) by user.
1. When [Share Group Lock](group/index.md#prevent-a-project-from-being-shared-with-groups) is enabled the project can't be shared with other groups. It does not affect group with group sharing.
1. For information on eligible approvers for merge requests, see
   [Eligible approvers](project/merge_requests/approvals/rules.md#eligible-approvers).
1. Applies only to comments on [Design Management](project/issues/design_management.md) designs.
1. Users can only view events based on their individual actions.
1. Project access tokens are supported for self-managed instances on Free and above. They are also
   supported on GitLab SaaS Premium and above (excluding [trial licenses](https://about.gitlab.com/free-trial)).

## Project features permissions

### Wiki and issues

Project features like [wikis](project/wiki/index.md) and issues can be hidden from users depending on
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
the group.

The following table lists group permissions available for each role:

| Action                                                 | Guest | Reporter | Developer | Maintainer | Owner |
|--------------------------------------------------------|-------|----------|-----------|------------|-------|
| Browse group                                           | **{check-circle}** Yes | **{check-circle}** Yes | **{check-circle}** Yes | **{check-circle}** Yes | **{check-circle}** Yes |
| View group wiki pages **(PREMIUM)**                    | **{check-circle}** Yes (6) | **{check-circle}** Yes | **{check-circle}** Yes | **{check-circle}** Yes | **{check-circle}** Yes |
| View Insights charts **(ULTIMATE)**                    | **{check-circle}** Yes | **{check-circle}** Yes | **{check-circle}** Yes | **{check-circle}** Yes | **{check-circle}** Yes |
| View group epic **(PREMIUM)**                          | **{check-circle}** Yes | **{check-circle}** Yes | **{check-circle}** Yes | **{check-circle}** Yes | **{check-circle}** Yes |
| Create/edit group epic **(PREMIUM)**                   | **{dotted-circle}** No | **{check-circle}** Yes | **{check-circle}** Yes | **{check-circle}** Yes | **{check-circle}** Yes |
| Manage group labels                                    | **{dotted-circle}** No | **{check-circle}** Yes | **{check-circle}** Yes | **{check-circle}** Yes | **{check-circle}** Yes |
| See a container registry                               | **{dotted-circle}** No | **{check-circle}** Yes | **{check-circle}** Yes | **{check-circle}** Yes | **{check-circle}** Yes |
| Pull [packages](packages/index.md)                     | **{dotted-circle}** No | **{check-circle}** Yes | **{check-circle}** Yes | **{check-circle}** Yes | **{check-circle}** Yes |
| Publish [packages](packages/index.md)                  | **{dotted-circle}** No | **{dotted-circle}** No | **{check-circle}** Yes | **{check-circle}** Yes | **{check-circle}** Yes |
| View metrics dashboard annotations                     | **{dotted-circle}** No | **{check-circle}** Yes | **{check-circle}** Yes | **{check-circle}** Yes | **{check-circle}** Yes |
| Create project in group                                | **{dotted-circle}** No | **{dotted-circle}** No | **{check-circle}** Yes (3)(5) | **{check-circle}** Yes (3) | **{check-circle}** Yes (3) |
| Share (invite) groups with groups                      | **{dotted-circle}** No | **{dotted-circle}** No |** {dotted-circle}** No | **{dotted-circle}** No | **{check-circle}** Yes |
| Create/edit/delete group milestones                    | **{dotted-circle}** No | **{dotted-circle}** No | **{check-circle}** Yes | **{check-circle}** Yes | **{check-circle}** Yes |
| Create/edit/delete iterations                          | **{dotted-circle}** No | **{dotted-circle}** No | **{check-circle}** Yes | **{check-circle}** Yes | **{check-circle}** Yes |
| Enable/disable a dependency proxy                      | **{dotted-circle}** No | **{dotted-circle}** No | **{check-circle}** Yes | **{check-circle}** Yes | **{check-circle}** Yes |
| Create and edit group wiki pages **(PREMIUM)**         | **{dotted-circle}** No | **{dotted-circle}** No | **{check-circle}** Yes | **{check-circle}** Yes | **{check-circle}** Yes |
| Use security dashboard **(ULTIMATE)**                  | **{dotted-circle}** No | **{dotted-circle}** No | **{check-circle}** Yes | **{check-circle}** Yes | **{check-circle}** Yes |
| Create/edit/delete metrics dashboard annotations       | **{dotted-circle}** No | **{dotted-circle}** No | **{check-circle}** Yes | **{check-circle}** Yes | **{check-circle}** Yes |
| View/manage group-level Kubernetes cluster             | **{dotted-circle}** No | **{dotted-circle}** No | **{dotted-circle}** No | **{check-circle}** Yes | **{check-circle}** Yes |
| Create subgroup                                        | **{dotted-circle}** No | **{dotted-circle}** No | **{dotted-circle}** No | **{check-circle}** Yes (1) | **{check-circle}** Yes |
| Delete group wiki pages **(PREMIUM)**                  | **{dotted-circle}** No | **{dotted-circle}** No | **{dotted-circle}** No | **{check-circle}** Yes | **{check-circle}** Yes |
| Edit epic comments (posted by any user) **(ULTIMATE)** | **{dotted-circle}** No | **{dotted-circle}** No | **{dotted-circle}** No | **{check-circle}** Yes (2) | **{check-circle}** Yes (2) |
| Edit group settings                                    | **{dotted-circle}** No | **{dotted-circle}** No | **{dotted-circle}** No | **{dotted-circle}** No | **{check-circle}** Yes |
| Manage group level CI/CD variables                     | **{dotted-circle}** No | **{dotted-circle}** No | **{dotted-circle}** No | **{dotted-circle}** No | **{check-circle}** Yes |
| List group deploy tokens                               | **{dotted-circle}** No | **{dotted-circle}** No | **{dotted-circle}** No | **{check-circle}** Yes | **{check-circle}** Yes |
| Create/Delete group deploy tokens                      | **{dotted-circle}** No | **{dotted-circle}** No | **{dotted-circle}** No | **{dotted-circle}** No | **{check-circle}** Yes |
| Manage group members                                   | **{dotted-circle}** No | **{dotted-circle}** No | **{dotted-circle}** No | **{dotted-circle}** No | **{check-circle}** Yes |
| Delete group                                           | **{dotted-circle}** No | **{dotted-circle}** No | **{dotted-circle}** No | **{dotted-circle}** No | **{check-circle}** Yes |
| Delete group epic **(PREMIUM)**                        | **{dotted-circle}** No | **{dotted-circle}** No | **{dotted-circle}** No | **{dotted-circle}** No | **{check-circle}** Yes |
| Edit SAML SSO Billing **(PREMIUM SAAS)**               | **{check-circle}** Yes | **{check-circle}** Yes | **{check-circle}** Yes | **{check-circle}** Yes | **{check-circle}** Yes (4) |
| View group Audit Events                                | **{dotted-circle}** No | **{dotted-circle}** No | **{check-circle}** Yes (7) | **{check-circle}** Yes (7) | **{check-circle}** Yes |
| Disable notification emails                            | **{dotted-circle}** No | **{dotted-circle}** No | **{dotted-circle}** No | **{dotted-circle}** No | **{check-circle}** Yes |
| View Contribution analytics                            | **{check-circle}** Yes | **{check-circle}** Yes | **{check-circle}** Yes | **{check-circle}** Yes | **{check-circle}** Yes |
| View Group DevOps Adoption **(ULTIMATE)**              | **{dotted-circle}** No | **{check-circle}** Yes | **{check-circle}** Yes | **{check-circle}** Yes | **{check-circle}** Yes |
| View Insights **(ULTIMATE)**                           | **{check-circle}** Yes | **{check-circle}** Yes | **{check-circle}** Yes | **{check-circle}** Yes | **{check-circle}** Yes |
| View Issue analytics **(PREMIUM)**                     | **{check-circle}** Yes | **{check-circle}** Yes | **{check-circle}** Yes | **{check-circle}** Yes | **{check-circle}** Yes |
| View Productivity analytics **(PREMIUM)**              | **{dotted-circle}** No | **{check-circle}** Yes | **{check-circle}** Yes | **{check-circle}** Yes | **{check-circle}** Yes |
| View Value Stream analytics                            | **{check-circle}** Yes | **{check-circle}** Yes | **{check-circle}** Yes | **{check-circle}** Yes | **{check-circle}** Yes |
| View Billing **(FREE SAAS)**                           | **{dotted-circle}** No | **{dotted-circle}** No | **{dotted-circle}** No | **{dotted-circle}** No | **{check-circle}** Yes (4) |
| View Usage Quotas **(FREE SAAS)**                      | **{dotted-circle}** No | **{dotted-circle}** No | **{dotted-circle}** No | **{dotted-circle}** No | **{check-circle}** Yes (4) |
| Manage [group push rules](group/index.md#group-push-rules) **(PREMIUM)** | **{dotted-circle}** No | **{dotted-circle}** No | **{dotted-circle}** No | **{check-circle}** Yes | **{check-circle}** Yes |
| View 2FA status of members                             | **{dotted-circle}** No | **{dotted-circle}** No | **{dotted-circle}** No | **{dotted-circle}** No | **{check-circle}** Yes |
| Filter members by 2FA status                           | **{dotted-circle}** No | **{dotted-circle}** No | **{dotted-circle}** No | **{dotted-circle}** No | **{check-circle}** Yes |
| Administer project compliance frameworks               | **{dotted-circle}** No | **{dotted-circle}** No | **{dotted-circle}** No | **{dotted-circle}** No | **{check-circle}** Yes |

1. Groups can be set to [allow either Owners or Owners and
  Maintainers to create subgroups](group/subgroups/index.md#creating-a-subgroup)
1. Introduced in GitLab 12.2.
1. Default project creation role can be changed at:
   - The [instance level](admin_area/settings/visibility_and_access_controls.md#default-project-creation-protection).
   - The [group level](group/index.md#specify-who-can-add-projects-to-a-group).
1. Does not apply to subgroups.
1. Developers can push commits to the default branch of a new project only if the [default branch protection](group/index.md#change-the-default-branch-protection-of-a-group) is set to "Partially protected" or "Not protected".
1. In addition, if your group is public or internal, all users who can see the group can also see group wiki pages.
1. Users can only view events based on their individual actions.

### Subgroup permissions

When you add a member to a subgroup, they inherit the membership and
permission level from the parent group(s). This model allows access to
nested groups if you have membership in one of its parents.

To learn more, read through the documentation on
[subgroups memberships](group/subgroups/index.md#membership).

## External users **(FREE SELF)**

In cases where it is desired that a user has access only to some internal or
private projects, there is the option of creating **External Users**. This
feature may be useful when for example a contractor is working on a given
project and should only have access to that project.

External users:

- Can only create projects (including forks), subgroups, and snippets within the top-level group to which they belong.
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

Additionally users can be set as external users using [SAML groups](../integration/saml.md#external-groups)
and [LDAP groups](../administration/auth/ldap/index.md#external-groups).

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

## Auditor users **(PREMIUM SELF)**

>[Introduced](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/998) in [GitLab Premium](https://about.gitlab.com/pricing/) 8.17.

Auditor users are given read-only access to all projects, groups, and other
resources on the GitLab instance.

An Auditor user should be able to access all projects and groups of a GitLab instance
with the permissions described on the documentation on [auditor users permissions](../administration/auditor_users.md#permissions-and-restrictions-of-an-auditor-user).

[Read more about Auditor users.](../administration/auditor_users.md)

## Users with minimal access **(PREMIUM)**

>[Introduced](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/40942) in [GitLab Premium](https://about.gitlab.com/pricing/) 13.4.

Owners can add members with a "minimal access" role to a parent group. Such users don't
automatically have access to projects and subgroups underneath. To support such access, owners must explicitly add these "minimal access" users to the specific subgroups/projects.

Users with minimal access can list the group in the UI and through the API. However, they cannot see
details such as projects or subgroups. They do not have access to the group's page or list any of its subgroups or projects.

### Minimal access users take license seats

Users with even a "minimal access" role are counted against your number of license seats. This
requirement does not apply for [GitLab Ultimate](https://about.gitlab.com/pricing/)
subscriptions.

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
Read through the documentation on [Project aliases](../user/project/import/index.md#project-aliases) to learn more.
