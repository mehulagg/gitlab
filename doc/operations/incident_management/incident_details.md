---
stage: Monitor
group: Health
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#designated-technical-writers
---

# Incident details page

Navigate to the Incident details view by visiting the
[Incident list](./incidents.md) and selecting an incident from the
list. You need at least Developer [permissions](../../user/permissions.md) to access
incidents.

TIP: **Tip:**
To review live examples of GitLab incidents, visit the
[incident list](https://gitlab.com/gitlab-examples/ops/incident-setup/everyone/tanuki-inc/-/incidents)
for this demo project. Click any incident in the list to examine its incident details
page.

## Update an incident's severity

> [Introduced](https://gitlab.com/gitlab-org/gitlab/-/issues/229402) in GitLab 13.4.

The Incident detail view enables you to update the Incident Severity.
See [Create and manage incindents in GitLab](./incidents.md) for more details.

## Incident system notes

When you take some actions on an incident, this is logged as a system note,
which is visible in the Incident Details view. This gives you a linear
timeline of the incident's updates.

The following actions will result in a system note:

- [Updating the severity of an incident](#update-an-incidents-severity)
  [Introduced](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/42358) in GitLab 13.5.
