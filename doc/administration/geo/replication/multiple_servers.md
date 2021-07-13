---
stage: Enablement
group: Geo
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#assignments
type: howto
---

# Geo for multiple servers **(PREMIUM SELF)**

This document describes a minimal reference architecture for running Geo
in a multi-server configuration. If your multi-server setup differs from the one
described, it is possible to adapt these instructions to your needs.

## Architecture overview

![Geo multi-server diagram](img/geo-ha-diagram.png)

_[diagram source - GitLab employees only](https://docs.google.com/drawings/d/1z0VlizKiLNXVVVaERFwgsIOuEgjcUqDTWPdQYsE7Z4c/edit)_

The topology above assumes the **primary** and **secondary** Geo clusters
are located in two separate locations, on their own virtual network
with private IP addresses. The network is configured such that all machines in
one geographic location can communicate with each other using their private IP addresses.
The IP addresses given are examples and may be different depending on the
network topology of your deployment.

The only external way to access the two Geo sites is by HTTPS at
`gitlab.us.example.com` and `gitlab.eu.example.com` in the example above.

NOTE:
The **primary** and **secondary** Geo sites must be able to communicate to each other over HTTPS.

## Redis and PostgreSQL for multiple servers

Geo supports:

- Redis and PostgreSQL on the Geo **primary** site configured for multiple servers.
- Redis on Geo **secondary** sites configured for multiple servers.

NOTE:
Support for PostgreSQL on Geo **secondary** sites in multi-server configuration
[is planned](https://gitlab.com/groups/gitlab-org/-/epics/2536).

Because of the additional complexity involved in setting up this configuration
for PostgreSQL and Redis, it is not covered by this Geo multi-server documentation.

For more information on setting up a multi-server PostgreSQL cluster and Redis cluster using the Omnibus GitLab package, see:

- [PostgreSQL multi-server documentation](../../postgresql/replication_and_failover.md)
- [Redis multi-server documentation](../../redis/replication_and_failover.md)

NOTE:
It is possible to use cloud hosted services for PostgreSQL and Redis, but this is beyond the scope of this document.

## Prerequisites: Two working GitLab multi-server clusters

One GitLab instance serves as the Geo **primary** site. Use the
[GitLab multi-server documentation](../../reference_architectures/index.md) to set this up. If
you already have a working GitLab instance that is in-use, it can be used as a
**primary** site.

The second GitLab instance serves as the Geo **secondary** site. Again, use the
[GitLab multi-server documentation](../../reference_architectures/index.md) to set this up.
It's a good idea to log in and test it. However, be aware that its data is
wiped out as part of the process of replicating from the **primary** site.

## Configure a GitLab instance to be the Geo **primary** site

The following steps enable a GitLab instance to serve as the Geo **primary** site.

### Step 1: Configure the **primary** frontend servers

1. Edit `/etc/gitlab/gitlab.rb` and add the following:

   ```ruby
   ##
   ## The unique identifier for the Geo site. It's recommended to use a
   ## physical location as a name, for example "us-east", instead of
   ## "secondary" or "geo". It's case-sensitive, and most characters are
   ## allowed. It should be the same for all servers in a Geo site.
   ##
   gitlab_rails['geo_node_name'] = '<node_name_here>'

   ##
   ## Disable automatic migrations
   ##
   gitlab_rails['auto_migrate'] = false
   ```

After making these changes, [reconfigure GitLab](../../restart_gitlab.md#omnibus-gitlab-reconfigure) so the changes take effect.

NOTE:
PostgreSQL and Redis should have already been disabled on the
application servers during normal GitLab multi-server setup. Connections
from the application servers to services on the backend servers should
have also been configured. See multi-server configuration documentation for
[PostgreSQL](../../postgresql/replication_and_failover.md#configuring-the-application-nodes)
and [Redis](../../redis/replication_and_failover.md#example-configuration-for-the-gitlab-application).

## Configure a GitLab instance to be a Geo **secondary** site

A **secondary** site is similar to any other GitLab multi-server instance, with two
major differences:

- The main PostgreSQL database is a read-only replica of the Geo **primary** site's
  PostgreSQL database.
- There is an additional PostgreSQL database for each Geo **secondary** site,
  called the "Geo tracking database", which tracks the replication and verification
  state of various resources.

Therefore, we set up the multi-server components one by one and include deviations
from the normal multi-server setup. However, we highly recommend configuring a
brand-new GitLab instance first, as if it were not part of a Geo setup. This allows
verifying that it is a working GitLab instance. And only then should it be modified
for use as a Geo **secondary** site. This helps to separate Geo setup problems from
unrelated multi-server configuration problems.

### Step 1: Configure the Redis and Gitaly services on the Geo **secondary** site

Configure the following services, again using the non-Geo multi-server
documentation:

- [Configuring Redis for GitLab](../../redis/replication_and_failover.md#example-configuration-for-the-gitlab-application) for multiple servers.
- [Gitaly](../../gitaly/index.md), which stores data that is
  synchronized from the Geo **primary** site.

NOTE:
[NFS](../../nfs.md) can be used in place of Gitaly but is not
recommended.

### Step 2: Configure Postgres streaming replication

Follow the [Geo database replication document](../setup/database.md).

If using an external PostgreSQL instance, refer also to
[Geo with external PostgreSQL instances](../setup/external_database.md).

### Step 3: Configure the Geo tracking database on the Geo **secondary** site

If you want to run the Geo tracking database in a multi-server PostgreSQL cluster,
then follow [Configuring Patroni cluster for the tracking PostgreSQL database](../setup/database.md#configuring-patroni-cluster-for-the-tracking-postgresql-database).

If you want to run the Geo tracking database on a single server, then follow
the instructions below.

1. Generate an MD5 hash of the desired password for the database user that the
   GitLab application uses to access the tracking database:

   Note that the username (`gitlab_geo` by default) is incorporated into the
   hash.

   ```shell
   gitlab-ctl pg-password-md5 gitlab_geo
   # Enter password: <your_password_here>
   # Confirm password: <your_password_here>
   # fca0b89a972d69f00eb3ec98a5838484
   ```

   Use this hash to fill in `<tracking_database_password_md5_hash>` in the next
   step.

1. On the machine where the Geo tracking database is intended to run, add the
   following to `/etc/gitlab/gitlab.rb`:

   ```ruby
   ##
   ## Enable the Geo secondary tracking database
   ##
   geo_postgresql['enable'] = true
   geo_postgresql['listen_address'] = '<ip_address_of_this_host>'
   geo_postgresql['sql_user_password'] = '<tracking_database_password_md5_hash>'

   ##
   ## Configure PostgreSQL connection to the replica database
   ##
   geo_postgresql['md5_auth_cidr_addresses'] = ['<replica_database_ip>/32']
   gitlab_rails['db_host'] = '<replica_database_ip>'

   # Prevent reconfigure from attempting to run migrations on the replica database
   gitlab_rails['auto_migrate'] = false

   ##
   ## Ensure unnecessary services are disabled
   ##
   alertmanager['enable'] = false
   consul['enable'] = false
   geo_logcursor['enable'] = false
   gitaly['enable'] = false
   gitlab_exporter['enable'] = false
   gitlab_workhorse['enable'] = false
   nginx['enable'] = false
   node_exporter['enable'] = false
   pgbouncer_exporter['enable'] = false
   postgresql['enable'] = false
   prometheus['enable'] = false
   redis['enable'] = false
   redis_exporter['enable'] = false
   patroni['enable'] = false
   sidekiq['enable'] = false
   sidekiq_cluster['enable'] = false
   puma['enable'] = false
   ```

After making these changes, [reconfigure GitLab](../../restart_gitlab.md#omnibus-gitlab-reconfigure) so the changes take effect.

If using an external PostgreSQL instance, refer also to
[Geo with external PostgreSQL instances](../setup/external_database.md).

### Step 4: Configure the frontend application servers on the Geo **secondary** site

In the architecture overview, there are two machines running the GitLab
application services. These services are enabled selectively in the
configuration.

Configure the GitLab Rails application servers following the relevant steps
outlined in the [reference architectures](../../reference_architectures/index.md),
then make the following modifications:

1. Edit `/etc/gitlab/gitlab.rb` on each application server in the Geo **secondary**
   site, and add the following:

   ```ruby
   ##
   ## Enable GitLab application services. The application_role enables many services.
   ## Alternatively, you can choose to enable or disable specific services on
   ## different servers to aid in horizontal scaling and separation of concerns.
   ##
   roles ['application_role']

   ##
   ## The unique identifier for the Geo site. It's recommended to use a
   ## physical location as a name, for example "eu-west", instead of
   ## "secondary" or "geo". It's case-sensitive, and most characters are
   ## allowed. It should be the same for all servers in a Geo site.
   ##
   gitlab_rails['geo_node_name'] = '<node_name_here>'

   ##
   ## Disable automatic migrations
   ##
   gitlab_rails['auto_migrate'] = false

   ##
   ## Configure the connection to the tracking database
   ##
   geo_secondary['db_host'] = '<geo_tracking_db_host>'
   geo_secondary['db_password'] = '<geo_tracking_db_password>'

   ##
   ## Configure connection to the streaming replica database, if you haven't
   ## already
   ##
   gitlab_rails['db_host'] = '<replica_database_host>'
   gitlab_rails['db_password'] = '<replica_database_password>'

   ##
   ## Configure connection to Redis, if you haven't already
   ##
   gitlab_rails['redis_host'] = '<redis_host>'
   gitlab_rails['redis_password'] = '<redis_password>'

   ##
   ## If you are using custom users not managed by Omnibus, you need to specify
   ## UIDs and GIDs like below, and ensure they match between servers in a
   ## cluster to avoid permissions issues
   ##
   user['uid'] = 9000
   user['gid'] = 9000
   web_server['uid'] = 9001
   web_server['gid'] = 9001
   registry['uid'] = 9002
   registry['gid'] = 9002
   ```

NOTE:
If you had set up PostgreSQL cluster using the omnibus package and had set
`postgresql['sql_user_password'] = 'md5 digest of secret'`, keep in
mind that `gitlab_rails['db_password']` and `geo_secondary['db_password']`
contains the plaintext passwords. This is used to let the Rails
servers connect to the databases.

NOTE:
Make sure that current server's IP is listed in
`postgresql['md5_auth_cidr_addresses']` setting of the read-replica database to
allow Rails on this server to connect to Postgres.

After making these changes [Reconfigure GitLab](../../restart_gitlab.md#omnibus-gitlab-reconfigure) so the changes take effect.

On the secondary the following GitLab frontend services are enabled:

- `geo-logcursor`
- `gitlab-pages`
- `gitlab-workhorse`
- `logrotate`
- `nginx`
- `registry`
- `remote-syslog`
- `sidekiq`
- `puma`

Verify these services by running `sudo gitlab-ctl status` on the frontend
application servers.

### Step 5: Set up the LoadBalancer for the Geo **secondary** site

In this topology, a load balancer is required at each geographic location to
route traffic to the application servers.

See [Load Balancer for GitLab with multiple servers](../../load_balancer.md) for
more information.

### Step 6: Configure the backend application servers on the Geo **secondary** site

The minimal reference architecture diagram above shows all application services
running together on the same machines. However, for multiple servers we
[strongly recommend running all services separately](../../reference_architectures/index.md).

For example, a Sidekiq server could be configured similarly to the frontend
application servers above, with some changes to run only the `sidekiq` service:

1. Edit `/etc/gitlab/gitlab.rb` on each Sidekiq server in the Geo **secondary**
   site, and add the following:

   ```ruby
   ##
   ## Enable the Sidekiq service
   ##
   sidekiq['enable'] = true

   ##
   ## The unique identifier for the Geo site. It's recommended to use a
   ## physical location as a name, for example "eu-west", instead of
   ## "secondary" or "geo". It's case-sensitive, and most characters are
   ## allowed. It should be the same for all servers in a Geo site.
   ##
   gitlab_rails['geo_node_name'] = '<node_name_here>'

   ##
   ## Disable automatic migrations
   ##
   gitlab_rails['auto_migrate'] = false

   ##
   ## Configure the connection to the tracking database
   ##
   geo_secondary['db_host'] = '<geo_tracking_db_host>'
   geo_secondary['db_password'] = '<geo_tracking_db_password>'

   ##
   ## Configure connection to the streaming replica database, if you haven't
   ## already
   ##
   gitlab_rails['db_host'] = '<replica_database_host>'
   gitlab_rails['db_password'] = '<replica_database_password>'

   ##
   ## Configure connection to Redis, if you haven't already
   ##
   gitlab_rails['redis_host'] = '<redis_host>'
   gitlab_rails['redis_password'] = '<redis_password>'

   ##
   ## If you are using custom users not managed by Omnibus, you need to specify
   ## UIDs and GIDs like below, and ensure they match between servers in a
   ## cluster to avoid permissions issues
   ##
   user['uid'] = 9000
   user['gid'] = 9000
   web_server['uid'] = 9001
   web_server['gid'] = 9001
   registry['uid'] = 9002
   registry['gid'] = 9002
   ```

   You can similarly configure a server to run only the `geo-logcursor` service
   with `geo_logcursor['enable'] = true` and disabling Sidekiq with
   `sidekiq['enable'] = false`.

   These servers do not need to be attached to the load balancer.
