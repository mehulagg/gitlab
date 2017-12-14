# GitLab Geo database replication

>**Note:**
This is the documentation for the Omnibus GitLab packages. For installations
from source, follow the
[**database replication for installations from source**](database_source.md) guide.

>**Note:**
Stages of the setup process must be completed in the documented order.
Before attempting the steps in this stage, [complete all prior stages][toc].

This document describes the minimal steps you have to take in order to
replicate your GitLab database into another server. You may have to change
some values according to your database setup, how big it is, etc.

You are encouraged to first read through all the steps before executing them
in your testing/production environment.

## PostgreSQL replication

The GitLab primary node where the write operations happen will connect to
primary database server, and the secondary ones which are read-only will
connect to secondary database servers (which are read-only too).

>**Note:**
In many databases documentation you will see "primary" being referenced as "master"
and "secondary" as either "slave" or "standby" server (read-only).

We recommend using [PostgreSQL replication
slots](https://medium.com/@tk512/replication-slots-in-postgresql-b4b03d277c75)
to ensure the primary retains all the data necessary for the secondaries to
recover. See below for more details.

### Prerequisites

The following guide assumes that:

- You are using PostgreSQL 9.6 or later which includes the
  [`pg_basebackup` tool][pgback]. If you are using Omnibus it includes the required
  PostgreSQL version for Geo.
- You have a primary server already set up (the GitLab server you are
  replicating from), running Omnibus' PostgreSQL (or equivalent version), and you
  have a new secondary server set up on the same OS and PostgreSQL version. Also
  make sure the GitLab version is the same on all nodes.
- The IP of the primary server for our examples will be `1.2.3.4`, whereas the
  secondary's IP will be `5.6.7.8`. Note that the primary and secondary servers
  **must** be able to communicate over these addresses. These IP addresses can
  either be public or private.

If your GitLab installation is using external PostgreSQL, the Omnibus roles
will not be able to perform all necessary configuration steps. Refer to
[External PostreSQL][external postgresql] for additional instructions.

### Step 1. Configure the primary server

1. SSH into your GitLab **primary** server and login as root:

    ```
    sudo -i
    ```

1. Execute the command below to define the node as primary Geo node:

    ```
    gitlab-ctl set-geo-primary-node
    ```

    This command will use your defined `external_url` in `/etc/gitlab/gitlab.rb`.

1. Omnibus GitLab already has a replication user called `gitlab_replicator`.
   You must set its password manually. You will be prompted to enter a
   password:

    ```bash
    gitlab-ctl set-replication-password
    ```

    This command will also read `postgresql['sql_replication_user']` Omnibus
    setting in case you have changed `gitlab_replicator` username to something
    else.

1. Configure PostgreSQL to listen on network interfaces

    For security reasons, PostgreSQL does not listen on any network interfaces
    by default. However, GitLab Geo requires the secondary to be able to
    connect to the primary's database. For this reason, we need the address of
    each node.

    If you are using a cloud provider, you can lookup the addresses for each
    Geo node through their management console. A table of terminology is
    provided below because terminology varies between vendors.

    | GitLab Terminology | Amazon Web Services | Google Cloud Platform |
    |-----|-----|-----|-----|
    | Private address | Private address | Internal address |
    | Public address | Public address | External address |

    To lookup the address of a Geo node, SSH in to the Geo node and execute:

    ```bash
    ##
    ## Private address
    ##
    ip route get 255.255.255.255 | awk '{print "Private address:", $NF; exit}'

    ##
    ## Public address
    ##
    echo "External address: $(curl ipinfo.io/ip)"
    ```

    In most cases, the following addresses will be used to configure GitLab
    Geo:

    | Configuration | Address |
    |-----|-----|
    | `postgresql['listen_address']` | Primary's private address |
    | `postgresql['trust_auth_cidr_addresses']` | Primary's private address |
    | `postgresql['md5_auth_cidr_addresses']` | Secondary's public addresses |

    The `listen_address` option opens PostgreSQL up to network connections
    with the interface corresponding to the given address. See [the PostgreSQL
    documentation](https://www.postgresql.org/docs/9.6/static/runtime-config-connection.html)
    for more details.

    Depending on your network configuration, the suggested addresses may not
    be correct. If your primary and secondary connect over a local
    area network, or a virtual network connecting availability zones like
    Amazon's [VPC](https://aws.amazon.com/vpc/) of Google's [VPC](https://cloud.google.com/vpc/)
    you should use the secondary's private address for `postgresql['md5_auth_cidr_addresses']`.

    Edit `/etc/gitlab/gitlab.rb` and add the following, replacing the IP
    addresses with addresses appropriate to your network configuration:

    ```ruby
    geo_primary_role['enable'] = true

    ##
    ## Primary address
    ## - replace '1.2.3.4' with the primary private address
    ##
    postgresql['listen_address'] = '1.2.3.4'
    postgresql['trust_auth_cidr_addresses'] = ['127.0.0.1/32','1.2.3.4/32']

    ##
    # Secondary addresses
    # - replace '5.6.7.8' with the secondary public address
    ##
    postgresql['md5_auth_cidr_addresses'] = ['5.6.7.8/32']

    ##
    ## Replication settings
    ## - set this to be the number of Geo secondary nodes you have
    ##
    postgresql['max_replication_slots'] = 1
    # postgresql['max_wal_senders'] = 10
    # postgresql['wal_keep_segments'] = 10

    ##
    ## Disable automatic database migrations temporarily
    ## (until PostgreSQL is restarted and listening on the private address).
    ##
    gitlab_rails['auto_migrate'] = false
    ```

    For external PostgreSQL instances, [see additional instructions][external postgresql].

1. Optional: If you want to add another secondary, the relevant setting would look like:

    ```ruby
    postgresql['md5_auth_cidr_addresses'] = ['5.6.7.8/32','9.10.11.12/32']
    ```

    You may also want to edit the `wal_keep_segments` and `max_wal_senders` to
    match your database replication requirements. Consult the [PostgreSQL -
    Replication documentation](https://www.postgresql.org/docs/9.6/static/runtime-config-replication.html)
    for more information.

1. Save the file and reconfigure GitLab for the database listen changes and
   the replication slot changes to be applied.

    ```bash
    gitlab-ctl reconfigure
    ```

    Restart PostgreSQL for its changes to take effect:

    ```bash
    gitlab-ctl restart postgresql
    ```

1. Re-enable migrations now that PostgreSQL is restarted and listening on the
   private address.

    Edit `/etc/gitlab/gitlab.rb` and **change** the configuration to `true`:

    ```ruby
    gitlab_rails['auto_migrate'] = true
    ```

    Save the file and reconfigure GitLab:

    ```bash
    gitlab-ctl reconfigure
    ```

1. Now that the PostgreSQL server is set up to accept remote connections, run
   `netstat -plnt` to make sure that PostgreSQL is listening on port `5432` to
   the primary server's private address.

1. Make a copy of the PostgreSQL `server.crt` file.

    A certificate was automatically generated when GitLab was reconfigured. This
    will be used automatically to protect your PostgreSQL traffic from
    eavesdroppers, but to protect against active ("man-in-the-middle") attackers,
    the secondary needs a copy of the certificate.

    Run this command:

    ```
    cat ~gitlab-psql/data/server.crt
    ```

    Copy the output into a file on your local computer called `server.crt`. You
    will need it when setting up the secondary! The certificate is not sensitive
    data.

1. Verify that clock synchronization is enabled.

    >**Important:**
    For Geo to work correctly, all nodes must have their clocks
    synchronized. It is not required for all nodes to be set to the same time
    zone, but when the respective times are converted to UTC time, the clocks
    must be synchronized to within 60 seconds of each other.

    If you are using Ubuntu, verify NTP sync is enabled:

    ```bash
    timedatectl status | grep 'NTP synchronized'
    ```

    Refer to your Linux distribution documentation to setup clock
    synchronization. This can easily be done using any NTP-compatible daemon.

### Step 2. Add the secondary GitLab node

To prevent the secondary geo node trying to act as the primary once the
database is replicated, the secondary geo node must be configured on the
primary before the database is replicated.

1. Visit the **primary** node's **Admin Area ➔ Geo Nodes**
   (`/admin/geo_nodes`) in your browser.
1. Add the secondary node by providing its full URL. **Do NOT** check the box
   'This is a primary node'.
1. Optionally, choose which namespaces should be replicated by the
   secondary node. Leave blank to replicate all. Read more in
   [selective replication](#selective-replication).
1. Click the **Add node** button.

The new secondary geo node will have the status **Unhealthy**. This is expected
because we have not yet configured the secondary server. This is the next step.

### Step 3. Configure the secondary server

1. From your **local machine**, copy `server.crt` to the secondary:

    ```
    scp server.crt secondary.geo.example.com:
    ```

1. SSH into your GitLab **secondary** server and login as root:

    ```
    sudo -i
    ```

1. Set up PostgreSQL TLS verification on the secondary

    Install the `server.crt` file:

    ```bash
    install -D -o gitlab-psql -g gitlab-psql -m 0400 -T server.crt ~gitlab-psql/.postgresql/root.crt
    ```

    PostgreSQL will now only recognize that exact certificate when verifying TLS
    connections. The certificate can only be replicated by someone with access
    to the private key, which is **only** present on the primary node.

1. Test that the remote connection to the primary server works (as the
   `gitlab-psql` user):

    ```bash
    sudo -u gitlab-psql /opt/gitlab/embedded/bin/psql --list -U gitlab_replicator -d "dbname=gitlabhq_production sslmode=verify-ca" -W -h 1.2.3.4
    ```

    When prompted enter the password you set in the first step for the
    `gitlab_replicator` user. If all worked correctly, you should see the
    database prompt.

    A failure to connect here indicates that the TLS or networking configuration
    is incorrect. Ensure that you've used the correct certificates and IP
    addresses throughout. If you have a firewall, ensure that the secondary is
    permitted to access the primary on port 5432.

1. Edit `/etc/gitlab/gitlab.rb` and add the following:

    ```ruby
    geo_secondary_role['enable'] = true
    ```

    For external PostgreSQL instances, [see additional instructions][external postgresql].

1. [Reconfigure GitLab][] for the changes to take effect.

1. Verify that clock synchronization is enabled.

    >**Important:**
    For Geo to work correctly, all nodes must have their clocks
    synchronized. It is not required for all nodes to be set to the same time
    zone, but when the respective times are converted to UTC time, the clocks
    must be synchronized to within 60 seconds of each other.

    If you are using Ubuntu, verify NTP sync is enabled:

    ```bash
    timedatectl status | grep 'NTP synchronized'
    ```

    Refer to your Linux distribution documentation to setup clock
    synchronization. This can easily be done using any NTP-compatible daemon.

### Step 4. Initiate the replication process

Below we provide a script that connects to the primary server, replicates the
database and creates the needed files for replication.

The directories used are the defaults that are set up in Omnibus. If you have
changed any defaults or are using a source installation, configure it as you
see fit replacing the directories and paths.

>**Warning:**
Make sure to run this on the **secondary** server as it removes all PostgreSQL's
data before running `pg_basebackup`.

1. SSH into your GitLab **secondary** server and login as root:

    ```
    sudo -i
    ```

1. Choose a database-friendly name to use for your secondary to
   use as the replication slot name. For example, if your domain is
   `secondary.geo.example.com`, you may use `secondary_example` as the slot
   name as shown in the commands below.

1. Execute the command below to start a backup/restore and begin the replication:

    ```
    gitlab-ctl replicate-geo-database --slot-name=secondary_example --host=1.2.3.4
    ```

    If PostgreSQL is listening on a non-standard port, add `--port=` as well.

    If your database is too large to be transferred in 30 minutes, you will need
    to increase the timeout, e.g., `--backup-timeout=3600` if you expect the
    initial replication to take under an hour.

    Pass `--sslmode=disable` to skip PostgreSQL TLS authentication altogether
    (e.g., you know the network path is secure, or you are using a site-to-site
    VPN). This is **not** safe over the public Internet!

    You can read more details about each `sslmode` in the
    [PostgreSQL documentation](https://www.postgresql.org/docs/9.6/static/libpq-ssl.html#LIBPQ-SSL-PROTECTION);
    the instructions above are carefully written to ensure protection against
    both passive eavesdroppers and active "man-in-the-middle" attackers.

    When prompted, enter the password you set up for the `gitlab_replicator`
    user in the first step.

    New for 9.4: Change the `--slot-name` to the name of the replication slot
    to be used on the primary database. The script will attempt to create the
    replication slot automatically if it does not exist.

    This command also takes a number of additional options. You can use `--help`
    to list them all, but here are a couple of tips:

    If you're setting up replication on a brand-new secondary that has no data,
    you may want to pass `--no-wait --skip-backup` to speed up the process - but
    be **certain** that you're running it against the right GitLab installation
    first! It **will** cause data loss otherwise.

    If you're repurposing an old server into a Geo secondary, you'll need to
    add `--force` to the command line.

The replication process is now over.

### External PostgreSQL instances

For installations using external PostgreSQL instances, the `geo_primary_role`
and `geo_secondary_role` includes configuration changes that must be applied
manually.

The `geo_primary_role` makes configuration changes to `pg_hba.conf` and
`postgresql.conf` on the primary:

```
##
## GitLab Geo Primary
## - pg_hba.conf
##
host    replication gitlab_replicator <trusted secondary IP>/32     md5
```

```
##
## Geo Primary Role
## - postgresql.conf
##
sql_replication_user = gitlab_replicator
wal_level = hot_standby
max_wal_senders = 10
wal_keep_segments = 50
max_replication_slots = 1 # number of secondary instances
hot_standby = on
```

Th `geo_secondary_role` makes configuration changes to `postgresql.conf` and
enables the Geo Log Cursor (`geo_logcursor`) and secondary tracking database
on the secondary. The PostgreSQL settings for this database it adds to
the default settings:

```
##
## Geo Secondary Role
## - postgresql.conf
##
wal_level = hot_standby
max_wal_senders = 10
wal_keep_segments = 10
hot_standby = on
```

Geo secondary nodes use a tracking database to keep track of replication
status and recover automatically from some replication issues. Follow the
instructions for [enabling tracking database on the secondary server][tracking].

## MySQL replication

We don't support MySQL replication for GitLab Geo.

## Troubleshooting

Read the [troubleshooting document](troubleshooting.md).

[pgback]: http://www.postgresql.org/docs/9.2/static/app-pgbasebackup.html
[external postgresql]: #external-postgresql-instances
[tracking]: database_source.md#enable-tracking-database-on-the-secondary-server
[toc]: README.md#using-omnibus-gitlab
