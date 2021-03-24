---
stage: Create
group: Ecosystem
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#assignments
---

# GitLab Jira Development panel integration **(FREE)**

> - [Moved](https://gitlab.com/gitlab-org/gitlab/-/issues/233149) to GitLab Free in 13.4.

The Jira Development panel integration allows you to reference Jira issues in GitLab, displaying
activity in the [Development panel](https://support.atlassian.com/jira-software-cloud/docs/view-development-information-for-an-issue/)
in the issue.

It complements the [GitLab Jira integration](../../user/project/integrations/jira.md). You may choose
to configure both integrations to take advantage of both sets of features. See a
[feature comparison](../../user/project/integrations/jira_integrations.md).

## Features

| Your mention of Jira issue ID in GitLab context   | Automated effect in Jira issue                                                                         |
|---------------------------------------------------|--------------------------------------------------------------------------------------------------------|
| In a merge request                                | Link to the MR is displayed in Development panel.                                                      |
| In a branch name                                  | Link to the branch is displayed in Development panel.                                                  |
| In a commit message                               | Link to the commit is displayed in Development panel.                                                  |
| In a commit message with Jira Smart Commit format | Displays your custom comment or logged time spent and/or performs specified issue transition on merge. |

With this integration, you can access related GitLab merge requests, branches, and commits directly from a Jira issue, reflecting your work in GitLab. From the Development panel, you can open a detailed view and take actions including creating a new merge request from a branch. For more information, see [Usage](#usage).

This integration connects all GitLab projects to projects in the Jira instance in either:

- A top-level group. A top-level GitLab group is one that does not have any parent group itself. All
  the projects of that top-level group, as well as projects of the top-level group's subgroups nesting
  down, are connected.
- A personal namespace, which then connects the projects in that personal namespace to Jira.

This differs from the [Jira integration](../../user/project/integrations/jira.md), where the mapping is between one GitLab project and the entire Jira instance.

## Configuration

<i class="fa fa-youtube-play youtube" aria-hidden="true"></i>
For an overview of how to configure Jira Development panel integration, see [Agile Management - GitLab Jira Development panel integration](https://www.youtube.com/watch?v=VjVTOmMl85M&feature=youtu.be).

We recommend that a GitLab group maintainer or group owner, or instance administrator (in the case of
self-managed GitLab) set up the integration to simplify administration.

| If you use Jira on: | GitLab.com customers need: | GitLab self-managed customers need: |
|-|-|-|
| [Atlassian cloud](https://www.atlassian.com/cloud) | The [GitLab.com for Jira Cloud](https://marketplace.atlassian.com/apps/1221011/gitlab-com-for-jira-cloud?hosting=cloud&tab=overview) application installed from the [Atlassian Marketplace](https://marketplace.atlassian.com). This offers real-time sync between GitLab and Jira. | The [GitLab.com for Jira Cloud](https://marketplace.atlassian.com/apps/1221011/gitlab-com-for-jira-cloud?hosting=cloud&tab=overview), using a workaround process. See a [relevant issue](https://gitlab.com/gitlab-org/gitlab/-/issues/268278) for more information. |
| Your own server | The Jira DVCS (distributed version control system) connector. This syncs data hourly. | The [Jira DVCS Connector](dvcs.md). |

### GitLab for Jira app **(FREE SAAS)**

You can integrate GitLab.com and Jira Cloud using the
[GitLab for Jira](https://marketplace.atlassian.com/apps/1221011/gitlab-com-for-jira-cloud)
app in the Atlassian Marketplace. The user configuring GitLab for Jira must have
[Maintainer](../../user/permissions.md) permissions in the GitLab namespace.

This method is recommended when using GitLab.com and Jira Cloud because data is synchronized in real-time. The DVCS connector updates data only once per hour. If you are not using both of these environments, use the [Jira DVCS Connector](dvcs.md) method.

<i class="fa fa-youtube-play youtube" aria-hidden="true"></i>
For a walkthrough of the integration with GitLab for Jira, watch [Configure GitLab Jira Integration using Marketplace App](https://youtu.be/SwR-g1s1zTo) on YouTube.

1. Go to **Jira Settings > Apps > Find new apps**, then search for GitLab.
1. Click **GitLab for Jira**, then click **Get it now**, or go to the
   [App in the marketplace directly](https://marketplace.atlassian.com/apps/1221011/gitlab-com-for-jira-cloud).

   ![Install GitLab App on Jira](img/jira_dev_panel_setup_com_1.png)
1. After installing, click **Get started** to go to the configurations page.
   This page is always available under **Jira Settings > Apps > Manage apps**.

   ![Start GitLab App configuration on Jira](img/jira_dev_panel_setup_com_2.png)
1. If not already signed in to GitLab.com, you must sign in as a user with
   [Maintainer](../../user/permissions.md) permissions to add namespaces.

   ![Sign in to GitLab.com in GitLab Jira App](img/jira_dev_panel_setup_com_3_v13_9.png)
1. Select **Add namespace** to open the list of available namespaces.

1. Identify the namespace you want to link, and select **Link**.

   ![Link namespace in GitLab Jira App](img/jira_dev_panel_setup_com_4_v13_9.png)

NOTE:
The GitLab user only needs access when adding a new namespace. For syncing with
Jira, we do not depend on the user's token.

After a namespace is added:

- All future commits, branches, and merge requests of all projects under that namespace
  are synced to Jira.
- From GitLab 13.8, past merge request data is synced to Jira.

Support for syncing past branch and commit data [is planned](https://gitlab.com/gitlab-org/gitlab/-/issues/263240).

For more information, see [Usage](#usage).

#### Troubleshooting GitLab for Jira

The GitLab for Jira App uses an iframe to add namespaces on the settings page. Some browsers block cross-site cookies. This can lead to a message saying that the user needs to log in on GitLab.com even though the user is already logged in.

> "You need to sign in or sign up before continuing."

In this case, use [Firefox](https://www.mozilla.org/en-US/firefox/) or enable cross-site cookies in your browser.

## Usage

After the integration is set up on GitLab and Jira, you can:

- Refer to any Jira issue by its ID in GitLab branch names, commit messages, and merge request
  titles.
- See the linked branches, commits, and merge requests in Jira issues (merge requests are
  called "pull requests" in Jira issues).

Jira issue IDs must be formatted in uppercase for the integration to work.

![Branch, Commit and Pull Requests links on Jira issue](img/jira_dev_panel_jira_setup_3.png)

Click the links to see your GitLab repository data.

![GitLab commits details on a Jira issue](img/jira_dev_panel_jira_setup_4.png)

![GitLab merge requests details on a Jira issue](img/jira_dev_panel_jira_setup_5.png)

For more information on using Jira Smart Commits to track time against an issue, specify an issue transition, or add a custom comment, see the Atlassian page [Using Smart Commits](https://confluence.atlassian.com/fisheye/using-smart-commits-960155400.html).

## Limitations

This integration is not supported on GitLab instances under a
[relative URL](https://docs.gitlab.com/omnibus/settings/configuration.html#configuring-a-relative-url-for-gitlab).
For example, `http://example.com/gitlab`.
