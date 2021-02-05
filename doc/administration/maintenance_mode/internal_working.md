---
stage: Enablement
group: Geo
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#assignments
---

# Internal workings of maintenance mode **(PREMIUM SELF)**

## Where is maintenance mode enforced?

Maintenance mode **only** blocks database write requests at the application level in 3 key places within the rails application. The database itself is not in read-only mode and can be written to from sources other than the ones blocked. 

The guards are placed in the following places in the code:

1. in the read-only middleware, where the database writes causing HTTP requests are blocked unless explicitly allowed.
1. Git pushes are blocked in
1. container registry updates are blocked in

Users with access to the database via the rails console or write access directly to the database can still write to it.

## Which database writes are still allowed?

In maintenance mode HTTP requests that write to the database will be blocked. 

However a few POST/PUT requests are allowed, e.g. signing in/out. 

The users are given the option to manually stop cron jobs that generate other background jobs. This is particularly needed in the case of a planned failover.

## Why are some database writes allowed and some are not?

User sign ins and several background jobs will cause database writes, but allowing these actions is a trade-off between further degrading the service during maintenance and blocking 100% writes. 

In the use case of a planned failover, a few writes still coming to the primary database are acceptable, since they will be replicated quickly and are not significant in number.

For the same reason we don't automatically block background jobs when maintenance mode is enabled.

The resulting database writes are acceptable. The trade-off is between more service degradation and the completion of replication. 

That said, we give the users the option to turn off cron jobs manually, that would stop new background jobs. 

However, during a planned failover, we ask users to keep the Geo related cron jobs running. In the absence of new database writes and non-Geo cron jobs, new background jobs would either not be created at all or be minimal.

Unfortunately a complete disabling of database writes would involve categorizing and analyzing every background job we have, and understanding it's significance and what it means to stop it during maintenance mode.

Maintenance mode is aimed at offering a viable solution that is a trade-off between continued service and limiting writes to the database so that some important use cases are resolved, even though not all.

## How does maintenance mode affect services that GitLab relies on?
