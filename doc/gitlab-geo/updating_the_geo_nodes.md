# Updating the Geo nodes

Depending on which version of Geo you are updating to/from, there may be
different steps.

## General update steps

In order to update the GitLab Geo nodes when a new GitLab version is released,
all you need to do is update GitLab itself:

1. Log into each node (primary and secondaries)
1. [Update GitLab][update]
1. [Update tracking database on secondary node](#update-tracking-database-on-secondary-node) when
   the tracking database is enabled.
1. [Test](#check-status-after-updating) primary and secondary nodes, and check version in each.

## Upgrading to GitLab 10.3

### Support for SSH repository synchronization removed

In GitLab 10.2, synchronizing secondaries over SSH was deprecated. In 10.3,
support is removed entirely. All installations will switch to the HTTP/HTTPS
cloning method instead. Before upgrading, ensure that all your Geo nodes are
configured to use this method and that it works for your installation. In
particular, ensure that [Git access over HTTP/HTTPS is enabled](configuration.md#step-4-enable-git-access-over-http-https).

Synchronizing repositories over the public Internet using HTTP is insecure, so
you should ensure that you have HTTPS configured before upgrading. Note that
file synchronization is **also** insecure in these cases!

## Upgrading to GitLab 10.2

### Secure PostgreSQL replication 

Support for TLS-secured PostgreSQL replication has been added. If you are
currently using PostgreSQL replication across the open internet without an
external means of securing the connection (e.g., a site-to-site VPN), then you
should immediately reconfigure your primary and secondary PostgreSQL instances
according to the [updated instructions](#database.md).

If you *are* securing the connections externally and wish to continue doing so,
ensure you include the new option `--sslmode=prefer` in future invocations of
`gitlab-ctl replicate-geo-database`.

### HTTPS repository sync

Support for replicating repositories and wikis over HTTP/HTTPS has been added.
Replicating over SSH has been deprecated, and support for this option will be
removed in a future release.

To switch to HTTP/HTTPS replication, log into the primary node as an admin and visit
**Admin Area ➔ Geo Nodes** (`/admin/geo_nodes`). For each secondary listed,
press the "Edit" button, change the "Repository cloning" setting from
"SSH (deprecated)" to "HTTP/HTTPS", and press "Save changes". This should take
effect immediately.

Any new secondaries should be created using HTTP/HTTPS replication - this is the
default setting.

After you've verified that HTTP/HTTPS replication is working, you should remove
the now-unused SSH keys from your secondaries, as they may cause problems if the
secondary if ever promoted to a primary:

1. **[secondary]** Login to **all** your secondary nodes and run:

    ```ruby
    sudo -u git -H rm ~git/.ssh/id_rsa ~git/.ssh/id_rsa.pub
    ```

### Hashed Storage

>**Warning**
Hashed storage is in **Alpha**. It is considered experimental and not
production-ready. See [Hashed
Storage](../administration/repository_storage_types.md) for more detail.

If you previously enabled Hashed Storage and migrated all your existing
projects to Hashed Storage, disabling hashed storage will not migrate projects
to their previous project based storage path. As such, once enabled and
migrated we recommend leaving Hashed Storage enabled.

## Upgrading to GitLab 10.1

>**Warning**
Hashed storage is in **Alpha**. It is considered experimental and not
production-ready. See [Hashed
Storage](../administration/repository_storage_types.md) for more detail.

[Hashed storage](../administration/repository_storage_types.md) was introduced
in GitLab 10.0, and a [migration path](../administration/raketasks/storage.md)
for existing repositories was added in GitLab 10.1.

## Upgrading to GitLab 10.0

Since GitLab 10.0, we require all **Geo** systems to [use SSH key lookups via
the database](ssh.md) to avoid having to maintain consistency of the
`authorized_keys` file for SSH access. Failing to do this will prevent users
from being able to clone via SSH.

Note that in older versions of Geo, attachments downloaded on the secondary
nodes would be saved to the wrong directory. We recommend that you do the
following to clean this up.

On the SECONDARY Geo nodes, run as root:

```sh
mv /var/opt/gitlab/gitlab-rails/working /var/opt/gitlab/gitlab-rails/working.old
mkdir /var/opt/gitlab/gitlab-rails/working
chmod 700 /var/opt/gitlab/gitlab-rails/working
chown git:git /var/opt/gitlab/gitlab-rails/working
```

You may delete `/var/opt/gitlab/gitlab-rails/working.old` any time.

Once this is done, we advise restarting GitLab on the secondary nodes for the
new working directory to be used:

```
sudo gitlab-ctl restart
```

## Upgrading from GitLab 9.3 or older

If you started running Geo on GitLab 9.3 or older, we recommend that you
resync your secondary PostgreSQL databases to use replication slots. If you
started using Geo with GitLab 9.4 or 10.x, no further action should be
required because replication slots are used by default. However, if you
started with GitLab 9.3 and upgraded later, you should still follow the
instructions below.

When in doubt, it does not hurt to do a resync. The easiest way to do this in
Omnibus is the following:

  1. Install GitLab on the primary server
  1. Run `gitlab-ctl reconfigure` and `gitlab-ctl restart postgresql`. This will enable replication slots on the primary database.
  1. Install GitLab on the secondary server.
  1. Re-run the [database replication process](database.md#step-3-initiate-the-replication-process).

## Special update notes for 9.0.x

> **IMPORTANT**:
With GitLab 9.0, the PostgreSQL version is upgraded to 9.6 and manual steps are
required in order to update the secondary nodes and keep the Streaming
Replication working. Downtime is required, so plan ahead.

The following steps apply only if you upgrade from a 8.17 GitLab version to
9.0+. For previous versions, update to GitLab 8.17 first before attempting to
upgrade to 9.0+.

---

Make sure to follow the steps in the exact order as they appear below and pay
extra attention in what node (primary/secondary) you execute them! Each step
is prepended with the relevant node for better clarity:

1. **[secondary]** Login to **all** your secondary nodes and stop all services:

    ```ruby
    sudo gitlab-ctl stop
    ```

1. **[secondary]** Make a backup of the `recovery.conf` file on **all**
   secondary nodes to preserve PostgreSQL's credentials:

    ```
    sudo cp /var/opt/gitlab/postgresql/data/recovery.conf /var/opt/gitlab/
    ```

1. **[primary]** Update the primary node to GitLab 9.0 following the
   [regular update docs][update]. At the end of the update, the primary node
   will be running with PostgreSQL 9.6.

1. **[primary]** To prevent a de-synchronization of the repository replication,
   stop all services except `postgresql` as we will use it to re-initialize the
   secondary node's database:

    ```
    sudo gitlab-ctl stop
    sudo gitlab-ctl start postgresql
    ```

1. **[secondary]** Run the following steps on each of the secondaries:

    1. **[secondary]**  Stop all services:

        ```
        sudo gitlab-ctl stop
        ```

    1. **[secondary]** Prevent running database migrations:

        ```
        sudo touch /etc/gitlab/skip-auto-migrations
        ```

    1. **[secondary]** Move the old database to another directory:

        ```
        sudo mv /var/opt/gitlab/postgresql{,.bak}
        ```

    1. **[secondary]** Update to GitLab 9.0 following the [regular update docs][update].
       At the end of the update, the node will be running with PostgreSQL 9.6.

    1. **[secondary]** Make sure all services are up:

        ```
        sudo gitlab-ctl start
        ```

    1. **[secondary]** Reconfigure GitLab:

        ```
        sudo gitlab-ctl reconfigure
        ```

    1. **[secondary]** Run the PostgreSQL upgrade command:

          ```
          sudo gitlab-ctl pg-upgrade
          ```

    1. **[secondary]** See the stored credentials for the database that you will
       need to re-initialize the replication:

        ```
        sudo grep -s primary_conninfo /var/opt/gitlab/recovery.conf
        ```

    1. **[secondary]** Create the `replica.sh` script as described in the
       [database configuration document](database.md#step-3-initiate-the-replication-process).

    1. **[secondary]** Run the recovery script using the credentials from the
       previous step:

        ```
        sudo bash /tmp/replica.sh
        ```

    1. **[secondary]** Reconfigure GitLab:

        ```
        sudo gitlab-ctl reconfigure
        ```

    1. **[secondary]** Start all services:

        ```
        sudo gitlab-ctl start
        ```

    1. **[secondary]** Repeat the steps for the rest of the secondaries.

1. **[primary]** After all secondaries are updated, start all services in
   primary:

    ```
    sudo gitlab-ctl start
    ```

## Check status after updating

Now that the update process is complete, you may want to check whether
everything is working correctly:

1. Run the Geo raketask on all nodes, everything should be green:

    ```
    sudo gitlab-rake gitlab:geo:check
    ```

1. Check the primary's Geo dashboard for any errors
1. Test the data replication by pushing code to the primary and see if it
   is received by the secondaries

## Update tracking database on secondary node

After updating a secondary node, you might need to run migrations on
the tracking database. The tracking database was added in GitLab 9.1,
and it is required since 10.0.

1. Run database migrations on tracking database

    ```
    sudo gitlab-rake geo:db:migrate
    ```

1. Repeat this step for every secondary node

[update]: ../update/README.md
