---
stage: Manage
group: Compliance
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#assignments
type: reference, concepts
---

# Only allow merge requests to be merged if there is an associated Jira issue **(ULTIMATE)**

> [Introduced](https://gitlab.com/gitlab-org/gitlab/-/issues/280766) in [GitLab Premium](https://about.gitlab.com/pricing/) 13.12 behind a feature flag, enabled by default.

You can prevent merge requests from being merged if it does not [refer to a Jira issue](../../../integration/jira/development_panel.md#use-the-integration).

To enforce this, navigate to your project's setting page, and select the **Require an associated issue from Jira** check box and click **Save** for the changes to take effect.

![Require an associated issue from Jira](./img/require_an_associated_issue_from_jia_v13_12.png)

Once enabled, you won't be able to merge until the merge request has an associated Jira issue.

![Merge request must mention Jira issue](./img/merge_request_jira_issue_required_v13_12.png)
