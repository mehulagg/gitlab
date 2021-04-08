---
stage: Create
group: Ecosystem
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#assignments
---

# Redmine service **(FREE)**

Use [Redmine](https://www.redmine.org/) as the issue tracker.

To enable the Redmine integration in a project:

1. Go to the [Integrations page](overview.md#accessing-integrations).
1. Select **Redmine**.
1. Select the checkbox under **Enable integration**.
1. Fill in the required fields:

   - **Project URL**: The URL to the project in Redmine that is being linked to this GitLab project.
   - **Issue URL**: The URL to the issue in Redmine project that is being linked to this GitLab project.
     This URL must contain `:id`. This ID is used by GitLab as a placeholder to replace the issue number.
   - **New issue URL**: This is the URL to create a new issue in Redmine for the project linked to
     this GitLab project.
     <!-- The line below was originally added in January 2018: https://gitlab.com/gitlab-org/gitlab/-/commit/778b231f3a5dd42ebe195d4719a26bf675093350 -->
     **This is currently not being used and is planned be removed in a future release.**

After you have configured and enabled Redmine, you see the Redmine link on the GitLab project pages,
which takes you to your Redmine project.

For example, this is a configuration for a project named `gitlab-ci`:

- Project URL: `https://redmine.example.com/projects/gitlab-ci`
- Issue URL: `https://redmine.example.com/issues/:id`
- New issue URL: `https://redmine.example.com/projects/gitlab-ci/issues/new`

You can also disable [GitLab internal issue tracking](../issues/index.md) in this project.
Learn more about the consequences of disabling GitLab issues in
[Sharing and permissions](../settings/index.md#sharing-and-permissions).

To disable GitLab issues:

1. Go to **Settings > General** page.
1. Expand **Visibility, project features, permissions**.
1. Turn off the toggle under **Issues**.

## Reference issues in Redmine

Issues in Redmine can be referenced in two alternative ways:

- `#<ID>`, where `<ID>` is a number (example `#143`).
- `<PROJECT>-<ID>`, for example `API_32-143`, where:
  - `<PROJECT>` starts with a capital letter, followed by capital letters, numbers, or underscores.
  - `<ID>` is a number.

In links, the `<PROJECT>` part is ignored, and they always point to the address specified in **Issue URL**.

We suggest using the longer format (`<PROJECT>-<ID>`) if you have both internal and external issue
trackers enabled. If you use the shorter format, and an issue with the same ID exists in the
internal issue tracker, the internal issue is linked.
