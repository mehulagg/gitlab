---
stage: Configure
group: Configure
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#assignments
---

# Chatops on GitLab.com

ChatOps on GitLab.com allows GitLab team members to run various automation tasks on GitLab.com using Slack.

## Requesting access

GitLab team-members may need access to Chatops on GitLab.com for administration
tasks such as:

- Configuring feature flags.
- Running `EXPLAIN` queries against the GitLab.com production replica.
- Get deployment status of all of our environments or for a specific commit: `/chatops run auto_deploy status [commit_sha]`

To request access to Chatops on GitLab.com:

1. Log into <https://ops.gitlab.net/users/sign_in> **using the same username** as for GitLab.com (you may have to rename it).

    - You could also use the "Sign in with" Google button to sign in, with your GitLab.com email address.
    <br>
1. Make sure that your username in [ops](https://ops.gitlab.net/) is the same as your username in [.com](https://gitlab.com/). If it is not, update the username in [ops](https://ops.gitlab.net/).

1. Make a comment in your onboarding issue tagging your onboarding buddy and your manager, asking them to add you to the chatops project in ops by running this command: `/chatops run member add <username> gitlab-com/chatops --ops` in the `#chat-ops-test` slack channel. Replace <username> with your username. Please find an example below: 

    - “Hi __BUDDY_HANDLE__ and __MANAGER_HANDLE__, could you please add me to the chatops project in Ops by running this command: `/chatops run member add <username> gitlab-com/chatops --ops` in the `#chat-ops-test` slack channel? Thanks in advance”.
    <br>
1. After being added to chatops project, run the command: `/chatops run user find <username>` to check your user status and to make sure that you can execute commands in the `#chat-ops-test` slack channel. You will have to setup 2FA for this command to work. The bot will guide you through the process of allowing your user to execute commands in the `#chat-ops-test` slack channel.

1. If you had to change your username for GitLab.com on the first step, make sure [to reflect this information](https://gitlab.com/gitlab-com/www-gitlab-com#adding-yourself-to-the-team-page) on [the team page](https://about.gitlab.com/company/team/).

## See also

- [Chatops Usage](../ci/chatops/README.md)
- [Understanding EXPLAIN plans](understanding_explain_plans.md)
- [Feature Groups](feature_flags/development.md#feature-groups)
