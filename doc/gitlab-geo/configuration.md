# GitLab Geo configuration

>**Note:**
This is the documentation for the Omnibus GitLab packages. For installations
from source, follow the [**GitLab Geo nodes configuration for installations
from source**](configuration_source.md) guide.

>**Note:**
Stages of the setup process must be completed in the documented order.
Before attempting the steps in this stage, [complete all prior stages][toc].

This is the final step you need to follow in order to setup a Geo node.

You are encouraged to first read through all the steps before executing them
in your testing/production environment.

## Setting up GitLab

>**Notes:**
- **Do not** setup any custom authentication in the secondary nodes, this will be
  handled by the primary node.
- **Do not** add anything in the secondaries Geo nodes admin area
  (**Admin Area ➔ Geo Nodes**). This is handled solely by the primary node.

After having installed GitLab Enterprise Edition in the instance that will serve
as a Geo node and set up the [database replication](database.md), the next steps
can be summed up to:

1. Replicate some required configurations between the primary and the secondaries
1. Configure a second, tracking database on each secondary
1. Start GitLab on the secondary node's machine

### Prerequisites

This is the last step of configuring a Geo secondary node. Make sure you have
followed the first two steps of the [Setup instructions](README.md#setup-instructions):

1. You have already installed on the secondary server the same version of
   GitLab Enterprise Edition that is present on the primary server.
1. You have set up the database replication.
1. Your secondary node is allowed to communicate via HTTP/HTTPS with
   your primary node (make sure your firewall is not blocking that).
1. Your nodes must have an NTP service running to synchronize the clocks.
   You can use different timezones, but the hour relative to UTC can't be more
   than 60 seconds off from each node.

### Step 1. Copying the database encryption key

GitLab stores a unique encryption key in disk that we use to safely store
sensitive data in the database. Any secondary node must have the
**exact same value** for `db_key_base` as defined in the primary one.

1. SSH into the **primary** node and login as root:

    ```
    sudo -i
    ```

1. Execute the command below to display the current encryption key and copy it:

    ```
    gitlab-rake geo:db:show_encryption_key
    ```

1. SSH into the **secondary** node and login as root:

    ```
    sudo -i
    ```

1. Add the following to `/etc/gitlab/gitlab.rb`, replacing `encryption-key` with the output
   of the previous command:

    ```ruby
    gitlab_rails['db_key_base'] = 'encryption-key'
    ```

1. Reconfigure the secondary node for the change to take effect:

    ```
    gitlab-ctl reconfigure
    ```

Once reconfigured, the secondary will start automatically
replicating missing data from the primary in a process known as backfill.
Meanwhile, the primary node will start to notify changes to the secondary, which
will act on those notifications immediately. Make sure the secondary instance is
running and accessible.

### Step 2. Enabling hashed storage (optional, from GitLab 10.0)

>**Warning**
Hashed storage is in **Alpha**. It is considered experimental and not
production-ready. See [Hashed
Storage](../administration/repository_storage_types.md) for more detail.

Using hashed storage significantly improves Geo replication - project and group
renames no longer require synchronization between nodes.

1. Visit the **primary** node's **Admin Area ➔ Settings**
   (`/admin/application_settings`) in your browser
1. In the `Repository Storages` section, check `Create new projects using hashed storage paths`:

    ![](img/hashed-storage.png)

### Step 3. (Optional) Configuring the secondary to trust the primary

You can safely skip this step if your primary uses a CA-issued HTTPS certificate.

If your primary is using a self-signed certificate for *HTTPS* support, you will
need to add that certificate to the secondary's trust store. Retrieve the
certificate from the primary and follow
[these instructions](https://docs.gitlab.com/omnibus/settings/ssl.html)
on the secondary.

### Step 4. Enable Git access over HTTP/HTTPS

GitLab Geo synchronizes repositories over HTTP/HTTPS, and so requires this clone
method to be enabled. Navigate to **Admin Area ➔ Settings**
(`/admin/application_settings`) on the primary node, and set
`Enabled Git access protocols` to `Both SSH and HTTP(S)` or `Only HTTP(S)`.

### Step 5. Managing the secondary GitLab node

You can monitor the status of the syncing process on a secondary node
by visiting the primary node's **Admin Area ➔ Geo Nodes** (`/admin/geo_nodes`)
in your browser.

Please note that if `git_data_dirs` is customized on the primary for multiple
repository shards you must duplicate the same configuration on the secondary.

![GitLab Geo dashboard](img/geo-node-dashboard.png)

Disabling a secondary node stops the syncing process.

The two most obvious issues that replication can have here are:

1. Database replication not working well
1. Instance to instance notification not working. In that case, it can be
   something of the following:
     - You are using a custom certificate or custom CA (see the
       [Troubleshooting](configuration.md#troubleshooting) section)
     - Instance is firewalled (check your firewall rules)

Currently, this is what is synced:

* Git repositories
* Wikis
* LFS objects
* Issue, merge request, snippet and comment attachments
* User, group, and project avatars

## Next steps

Your nodes should now be ready to use. You can login to the secondary node
with the same credentials as used in the primary. Visit the secondary node's
**Admin Area ➔ Geo Nodes** (`/admin/geo_nodes`) in your browser to check if it's
correctly identified as a secondary Geo node and if Geo is enabled.

If your installation isn't working properly, check the
[troubleshooting](#troubleshooting) section.

Point your users to the ["Using a Geo Server" guide](using_a_geo_server.md).

## Selective replication

With GitLab 9.5, GitLab Geo now supports the first iteration of selective
replication, which allows admins to choose which groups should be
replicated by secondary nodes.

It is important to notice that selective replication:

1. Does not restrict permissions from secondary nodes.
1. Does not hide projects metadata from secondary nodes. Since Geo currently
relies on PostgreSQL replication, all project metadata gets replicated to
secondary nodes, but repositories that have not been selected will be empty.
1. Secondary nodes won't pull repositories that do not belong to the selected
groups to be replicated.

### Upgrading Geo

See the [updating the Geo nodes document](updating_the_geo_nodes.md).

## Troubleshooting

See the [troubleshooting document](troubleshooting.md).

[toc]: README.md#using-omnibus-gitlab
