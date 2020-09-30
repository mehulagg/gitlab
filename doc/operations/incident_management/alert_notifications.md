stage: Monitor
group: Health
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#designated-technical-writers
---

# Alert Notifications

GitLab can react to alerts triggered from your applications. When an alert is triggered in GitLab via [managed-Prometheus](https://docs.gitlab.com/ee/user/project/integrations/prometheus.html#managed-prometheus-on-kubernetes) or triggered via an external source and received via an integration, it important for a responder to be notified. Below is a list of the different ways responders can receive a notification.

## Slack Notifications

> [Introduced](https://gitlab.com/gitlab-org/gitlab/-/issues/216326) in GitLab 13.1.

You can be alerted via a Slack message when a new alert has been triggered.

See the [Slack Notifications Service docs](../../user/project/integrations/slack.md) for information on how to set this up.

## Email Notifications

If a project has been [configured to create incidents automatically for triggered alerts](./incidents.md#configure-incidents), projects members with the **Owner** or **Maintainer** role will be sent an email notification. To send additional email notifications to project members with the Developer role, check the configuration box located at **Settings > Operations > Incidents > Alert Integration** to **Send a separate email notification to Developers**.

