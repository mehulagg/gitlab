---
stage: Create
group: Source Code
info: "To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#assignments"
type: reference, concepts
---

# Merge request approval settings

You can configure the settings for [merge request approvals](index.md) to
ensure the approval rules meet your use case. You can also configure
[approval rules](rules.md), which define the number and type of users who must
approve work before it is merged. Merge request approval settings define how
those rules are applied as a merge request moves toward completion.

## Edit merge request approval settings

To view or edit merge request approval settings:

1. Go to your project's **Settings > General** page.
1. Expand **Merge request (MR) approvals**.

In this section of general settings, you can configure the settings described on this page.

## Prevent overrides of default approvals

By default, users can override the approval rules you [create for a project](rules.md)
on a per-merge request basis. If you do not want users to change approval rules
on merge requests, you can disable this setting:

1. Go to your project's **Settings > General** page.
1. Expand **Merge request (MR) approvals**.
1. Select the **Prevent users from modifying MR approval rules in merge requests.** checkbox.
1. Select **Save changes**.

TODO This change affects all open merge requests.

## Reset approvals on push

By default, an approval on a merge request remains in place, even if you add more changes
after the approval. If you want to remove all existing approvals on a merge request
when more changes are added to it:

1. Go to your project's **Settings > General** page.
1. Expand **Merge request (MR) approvals**.
1. Select the **Require new approvals when new commits are added to an MR** checkbox.
1. Select **Save changes**.

Approvals are not reset when a merge request is [rebased from the UI](../fast_forward_merge.md)
However, approvals are reset if the target branch is changed.

## Prevent authors from approving their own work **(PREMIUM)**

> - [Introduced](https://gitlab.com/gitlab-org/gitlab/-/issues/3349) in GitLab 11.3.
> - Moved to GitLab Premium in 13.9.

By default, the author of a merge request cannot approve it. To change this setting:

1. Go to your project's **Settings > General** page.
1. Expand **Merge request (MR) approvals**.
1. Deselect the **Prevent MR approval by the author.** checkbox.
1. Select **Save changes**.

Authors can still edit the approval rule in an individual merge request and override
this setting, unless you configure one of these options:

- [Prevent overrides of default approvals](#prevent-overrides-of-default-approvals) at
  the project level.
- *(Self-managed instances only)* Prevent overrides of default approvals
  [at the instance level](../../../admin_area/merge_requests_approvals.md). When configured
  at the instance level, this setting can't be edited at the project or individual
  merge request level.

## Prevent committers from approving their own work **(PREMIUM)**

> - [Introduced](https://gitlab.com/gitlab-org/gitlab/-/issues/10441) in GitLab 11.10.
> - Moved to GitLab Premium in 13.9.

By default, users who commit to a merge request can still approve it. You can prevent,
at the project level or [instance level](../../../admin_area/merge_requests_approvals.md),
committers from approving that is partially their own:

1. Go to your project's **Settings > General** page.
1. Expand **Merge request (MR) approvals**.
1. Select the **Prevent MR approvals from users who make commits to the MR** checkbox.
   If this checkbox is disabled, an administrator has disabled it
   [at the instance level](../../../admin_area/merge_requests_approvals.md), and
   it can't be changed at the project level.
1. Select **Save changes**.

Even with this configuration, [code owners](../../code_owners.md) who contribute
to a merge request can still approve merge requests that affect files they own.

To learn more about the [differences between authors and committers](https://git-scm.com/book/en/v2/Git-Basics-Viewing-the-Commit-History),
read the official Git documentation for an explanation.

## Require authentication for approvals

> - [Introduced](https://gitlab.com/gitlab-org/gitlab/-/issues/5981) in GitLab 12.0.
> - Moved to GitLab Premium in 13.9.

You can force potential approvers to first authenticate with a password. This
permission enables an electronic signature for approvals, such as the one defined by
[Code of Federal Regulations (CFR) Part 11](https://www.accessdata.fda.gov/scripts/cdrh/cfdocs/cfcfr/CFRSearch.cfm?CFRPart=11&showFR=1&subpartNode=21:1.0.1.1.8.3)):

1. Enable password authentication for the web interface, as described in the
   [sign-in restrictions documentation](../../../admin_area/settings/sign_in_restrictions.md#password-authentication-enabled).
1. Go to your project's **Settings > General** page.
1. Expand **Merge request (MR) approvals**.
1. Select the **Require user password for approvals.** checkbox.
1. Click **Save changes**.

## Security approvals in merge requests **(ULTIMATE)**

You can require that a member of your security team approve a merge request, if a
merge request could introduce a vulnerability. To learn more, read
[Security approvals in merge requests](../../../application_security/index.md#security-approvals-in-merge-requests).

## Related links

- [Instance-level merge request approval settings](../../../admin_area/merge_requests_approvals.md)
- [Compliance Dashboard](../../../compliance/compliance_dashboard/index.md) **(ULTIMATE)**
- [Merge request approvals API](../../../../api/merge_request_approvals.md)
