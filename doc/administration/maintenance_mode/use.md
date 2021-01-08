---
stage: Enablement
group: Geo
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#assignments
---

# How to use maintenance mode

This document describes how to put a GitLab instance in maintenance mode.

## Enabling maintenance mode

**Requirements**
TBD

There are three ways to enable maintenance mode:

1. Web UI (only admins)
    Go to `<gitlab-url>/admin/application_settings/general` and toggle maintenance mode. You can optionally add a message for the banner here.

1. API (only admins)
    `curl --request PUT --header "PRIVATE-TOKEN:$ADMIN_TOKEN" "<gitlab-url>/api/v4/application/settings?maintenance_mode=true"`

1. Rails console ([How to start a rails console](https://docs.gitlab.com/ee/administration/operations/rails_console.html#starting-a-rails-console-session))
    `::Gitlab::CurrentSettings.update_attributes!(maintenance_mode: true)`
    `::Gitlab::CurrentSettings.update_attributes!(maintenance_mode_message: "New message")`

## Disabling maintenance mode

There are three ways to disable maintenance mode:

1. Web UI (only admins)
    Go to `<gitlab-url>/admin/application_settings/general` and toggle maintenance mode.

1. API (only admins)
    `curl --request PUT --header "PRIVATE-TOKEN:$ADMIN_TOKEN" "<gitlab-url>/api/v4/application/settings?maintenance_mode=false"`

1. Rails console ([How to start a rails console](https://docs.gitlab.com/ee/administration/operations/rails_console.html#starting-a-rails-console-session))
    `::Gitlab::CurrentSettings.update_attributes!(maintenance_mode: false)`
