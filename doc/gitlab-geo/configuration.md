# GitLab Geo configuration

1. Install GitLab Enterprise Edition from the [Omnibus package][install-ee]
   or [source][install-ee-source] on the server that will serve
   as the secondary Geo node. Do not login or set up anything else in the
   secondary node for the moment.
1. [Setup the database replication](database.md)  (`primary (read-write) <-> secondary (read-only)` topology).
1. [Configure SSH authorizations to use the database](ssh.md)
1. **Configure GitLab to set the primary and secondary nodes.**
1. [Follow the after setup steps](after_setup.md).

[install-ee]: https://about.gitlab.com/downloads-ee/ "GitLab Enterprise Edition Omnibus packages downloads page"
[install-ee-source]: https://docs.gitlab.com/ee/install/installation.html "GitLab Enterprise Edition installation from source"

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

1. Configure the primary node
1. Replicate some required configurations between the primary and the secondaries
1. Configure a second, tracking database on each secondary
1. Configure every secondary node in the primary's Admin screen
1. Start GitLab on the secondary node's machine

### Prerequisites

This is the last step of configuring a Geo node. Make sure you have followed the
first two steps of the [Setup instructions](README.md#setup-instructions):

1. You have already installed on the secondary server the same version of
   GitLab Enterprise Edition that is present on the primary server.
1. You have set up the database replication.
1. Your secondary node is allowed to communicate via HTTP/HTTPS with
   your primary node (make sure your firewall is not blocking that).
1. Your nodes must have an NTP service running to synchronize the clocks.
   You can use different timezones, but the hour relative to UTC can't be more
   than 60 seconds off from each node.
1. You have set up another PostgreSQL database that can store writes for the secondary.
   Note that this MUST be on another instance, since the primary replicated database
   is read-only.

Some of the following steps require to configure the primary and secondary
nodes almost at the same time. For your convenience make sure you have SSH
logins opened on all nodes as we will be moving back and forth.

### Step 1. Adding the primary GitLab node

1. SSH into the **primary** node and login as root:

    ```
    sudo -i
    ```

1. Define this node as the primary Geo node.

    For installations from **Omnibus GitLab packages** execute the command:

    ```bash
    gitlab-ctl set-geo-primary-node
    ```

    For installations from **source** execute the command:

    ```bash
    bundle exec rake geo:set_primary_node
    ```

    This command will use your defined `external_url` in `gitlab.rb`

### Step 2. Copying the database encryption key

GitLab stores a unique encryption key in disk that we use to safely store
sensitive data in the database. Any secondary node must have the
**exact same value** for `db_key_base` as defined in the primary one.

1. SSH into the **primary** node and login as root:

    ```
    sudo -i
    ```

1. Retrieve the current database encryption key and copy it.

    For installations from **Omnibus GitLab packages** execute the command
    below and copy the encryption key:

    ```bash
    gitlab-rake geo:db:show_encryption_key
    ```

    For installations from **source** execute the command below and copy the
    encryption key:

    ```bash
    bundle exec rake geo:db:show_encryption_key
    ```

1. SSH into the **secondary** node and login as root:

    ```
    sudo -i
    ```

1. Open the secrets file and paste the value of `db_key_base` you copied in the
   previous step:

    ```
    editor /etc/gitlab/gitlab-secrets.json
    ```

1. Save and close the file.

1. For installations from **Omnibus GitLab packages** reconfigure for the
   change to take effect.

    ```bash
    gitlab-ctl reconfigure
    ```

### Step 3. Enabling hashed storage (from GitLab 10.0)

1. Visit the **primary** node's **Admin Area ➔ Settings**
   (`/admin/application_settings`) in your browser
1. In the `Repository Storages` section, check `Create new projects using hashed storage paths`:

    ![](img/hashed-storage.png)

Using hashed storage significantly improves Geo replication - project and group
renames no longer require synchronization between nodes - so we recommend it is
used for all GitLab Geo installations.

### Step 4. Enabling the secondary GitLab node

1. Visit the **primary** node's **Admin Area ➔ Geo Nodes** (`/admin/geo_nodes`)
   in your browser.
1. Add the secondary node by providing its full URL. **Do NOT** check the box
   'This is a primary node'.
1. Added in GitLab 9.5: Choose which namespaces should be replicated by the secondary node. Leave blank to replicate all. Read more in [selective replication](#selective-replication).
1. Click the **Add node** button.
1. Restart GitLab on the secondary.

    For installations from **Omnibus GitLab packages**:

    ```bash
    gitlab-ctl restart
    ```

    For installations from **source**

    ```bash
    sudo service gitlab restart
    ```
---

After the **Add Node** button is pressed, the secondary will start automatically
replicating missing data from the primary in a process known as backfill.
Meanwhile, the primary node will start to notify changes to the secondary, which
will act on those notifications immediately. Make sure the secondary instance is
running and accessible.

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

You can monitor the status of the syncing process on a secondary node
by visiting the primary node's **Admin Area ➔ Geo Nodes** (`/admin/geo_nodes`)
in your browser.

Please note that if `git_data_dirs` is customized on the primary for multiple
repository shards you must duplicate the same configuration on the secondary.

![GitLab Geo dashboard](img/geo-node-dashboard.png)

Disabling a secondary node stops the syncing process.

## Next steps

Your nodes should now be ready to use. You can login to the secondary node
with the same credentials as used in the primary. Visit the secondary node's
**Admin Area ➔ Geo Nodes** (`/admin/geo_nodes`) in your browser to check if it's
correctly identified as a secondary Geo node and if Geo is enabled.

If your installation isn't working properly, check the
[troubleshooting](#troubleshooting) section.

Point your users to the [after setup steps](after_setup.md).

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

## Adding another secondary Geo node

To add another Geo node in an already Geo configured infrastructure, just follow
[the steps starting from step 2](#step-2-copying-the-database-encryption-key)
Just omit the first step that sets up the primary node.

## Replicating wikis and repositories over SSH

In GitLab 10.2, replicating repositories and wikis over SSH was deprecated.
Support for this option will be removed within a few releases, but if you need
to add a new secondary in the short term, you can follow these instructions:

1. SSH into the **secondary** node and login as root:

    ```bash
    sudo -i
    ```

1. Add the primary's SSH key fingerprint to the `known_hosts` file.

   ```bash
     sudo -u git -H ssh git@<primary-node-url>
   ```

    Replace `<primary-node-url>` with the FQDN of the primary node. You should
    manually check the displayed fingerprint against a trusted record of the
    expected value before accepting it!

1. Generate a *passphraseless* SSH keypair for the `git` user, and capture the
   public component:

    ```bash
    test -e ~git/.ssh/id_rsa || sudo -u git -H ssh-keygen -q -t rsa -b 4096 -f ~git/.ssh/id_rsa
    cat ~git/.ssh/id_rsa.pub
    ```

Follow the steps above to set up the new Geo node. When you reach
[Step 4: Enabling the secondary GitLab node](#step-4-enabling-the-secondary-gitlab-node)
select "SSH (deprecated)" instead of "HTTP/HTTPS", and populate the "Public Key"
with the output of the previous command (beginning `ssh-rsa AAAA...`).

### Upgrading Geo

See the [updating the Geo nodes document](updating_the_geo_nodes.md).

## Troubleshooting

See the [troubleshooting document](troubleshooting.md).
