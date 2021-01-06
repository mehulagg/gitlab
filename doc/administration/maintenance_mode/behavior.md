---
stage: Enablement
group: Geo
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#assignments
---

# GitLab behavior in maintenance mode

This document describes what you can expect from a GitLab instance in maintenance mode.

In maintenance mode, database writes are disabled at the application level.

However, some database write actions are allowed, e.g. to allow users to log in and log out and admins are allowed to edit application settings.

**Visual feedback**

When maintenance mode is enabled, a banner is displayed at the top of the page.

An error is displayed when a user tries to perform a write operation that isn't allowed.

In some cases the visual feedback from an action could be misleading, e.g. on starring a project, the `Star` button changes to show `Unstar` action, however, this is only the frontend update that does not take into account the failed status of the POST request. These visual bugs are to be fixed in follow-up iterations.

The API will return a 403 or 503 for failed write requests.

## Application Settings

In maintenance mode, admins can edit application settings. This will allow them to disable maintenance mode after it's been enabled.

## Logging in/logging out

All users can log in and out of the GitLab instance.

If Geo is enabled, logging out of secondary is allowed too. But logging back into secondary is currently broken. If a user is already logged into a secondary when maintenance mode is enabled, they will continue to be logged in, unless they log out themselves.

## CI/CD

In maintenance mode, no new jobs are started. Already running jobs stay in 'running' status but their logs are no longer updated.

Once maintenance mode is disabled, new jobs are be picked up again. The jobs that were in the running state before enabling maintenance mode, will resume.
Their logs will start getting updated again.

If the job has been in 'running' state for longer than the project's time limit, it will **not** timeout.

Pipelines cannot be started, retried or cancelled in maintenance mode.
No new jobs can be created either.

## Git actions

All read-only Git operations will continue to work in maintenance mode, e.g. `git clone` and `git pull`, but all write operations will fail, both through the CLI and Web IDE.

Geo secondaries are read-only instances that allow Git pushes because they are proxied to the primary instance. However in mainteance mode, Git pushes to both primary and secondaries will fail.

## Merge Requests/Issues, etc

All write actions except those mentioned above will fail. So, in maintenace mode, a user cannot update merge requests, issues, etc.

## Docker registry

In maintenance mode, `docker push` is blocked, but `docker pull` is available.

## Deploys

TBD

## Background Jobs

TBD

## Geo secondaries

A change in maintenance mode setting will be propagated to the secondary as they sync up.

Logging back into a secondary during maintenance mode is currently broken and is being tracked [here](https://gitlab.com/gitlab-org/gitlab/-/issues/296534).

**Replication and Verification**

TBD

**Pausing/resuming of syncing**

TBD
