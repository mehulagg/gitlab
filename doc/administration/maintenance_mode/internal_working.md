---
stage: Enablement
group: Geo
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#assignments
---

# Internal workings of maintenance mode **(PREMIUM SELF)**

## Where is maintenance mode enforced?

Maintenance mode **only** blocks HTTP and SSH requests at the application level in 3 key places within the rails application. The database itself is not in read-only mode and can be written to from sources other than the ones blocked. 

The guards are placed in the following places in the code:

1. [the read-only middleware](https://gitlab.com/gitlab-org/gitlab/-/blob/master/ee/lib/ee/gitlab/middleware/read_only/controller.rb), where HTTP requests that cause database writes are blocked, unless explicitly allowed.
1. [Git push access via SSH is denied](https://gitlab.com/gitlab-org/gitlab/-/blob/master/ee/lib/ee/gitlab/git_access.rb#L13) by returning 401 when `gitlab-shell` POSTs to `/internal/allowed` to check if access is allowed.
1. [Container registry authentication service](https://gitlab.com/gitlab-org/gitlab/-/blob/master/ee/app/services/ee/auth/container_registry_authentication_service.rb#L12), where updates to the container registry are blocked.

## Which HTTP requests are still allowed?

In maintenance mode most HTTP requests that write to the database will be blocked. 

However a few POST/PUT requests are allowed, e.g. `POST /users/sign_in` and `POST /users/sign_out`

## Why are some database writes allowed and some are not?

While maintenance mode blocks most HTTP and SSH requests, some other sources can still write to the database.

e.g. user sign-ins and background jobs will cause database writes, but allowing these actions is a trade-off between further degrading the service during maintenance and blocking 100% writes. 

In the use case of a planned failover, a few writes still landing in the primary database are acceptable, since they will be replicated quickly and are not significant in number.

For the same reason we don't automatically block background jobs when maintenance mode is enabled.

The resulting database writes are acceptable. The trade-off is between more service degradation and the completion of replication. 

However, during a planned failover, we ask users to turn off non-geo cron jobs manually. In the absence of new database writes and non-Geo cron jobs, new background jobs would either not be created at all or be minimal.

Unfortunately a complete disabling of database writes would involve categorizing and analyzing every background job, and understanding it's significance and what it means to stop it during maintenance mode.

Maintenance mode is aimed at offering a viable solution that is a trade-off between continued service and limiting writes to the database so that some important use cases are resolved, even though not all.

## How does maintenance mode affect services that GitLab relies on?

Maintenance mode will only affect the following related services:

| Service | in maintenance mode|
|---------|----|
|GitLab Shell| Access requests to the rails application for Git pushes  over SSH are denied |
|Geo nodes|Git pushes that are proxied from secondary to primary will be blocked. Replication and verification will continue. Secondary will be in maintenance mode too once primary is in maintenance mode.|
| Registry| Push to container registry is blocked, pull is allowed|
