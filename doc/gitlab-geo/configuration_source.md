# GitLab Geo configuration

>**Note:**
This is the documentation for installations from source. For installations
using the Omnibus GitLab packages, follow the
[**Omnibus GitLab Geo nodes configuration**](configuration.md) guide.

## Configuring a new secondary node

>**Note:**
This is the final step in setting up a secondary Geo node. Stages of the setup
process must be completed in the documented order. Before attempting the steps
in this stage, [complete all prior stages](README.md#using-gitlab-installed-from-source).

The basic steps of configuring a secondary node are to replicate required
configurations between the primary and the secondaries; to configure a tracking
database on each secondary; and to start GitLab on the secondary node.

You are encouraged to first read through all the steps before executing them
in your testing/production environment.


>**Notes:**
- **Do not** setup any custom authentication in the secondary nodes, this will be
  handled by the primary node.
- **Do not** add anything in the secondaries Geo nodes admin area
  (**Admin Area ➔ Geo Nodes**). This is handled solely by the primary node.

### Step 1. Manually replicate secret GitLab values

GitLab stores a number of secret values in the `/home/git/gitlab/config/secrets.yml`
file which *must* match between the primary and secondary nodes. Until there is
a means of automatically replicating these between nodes (see
[issue #3789](https://gitlab.com/gitlab-org/gitlab-ee/issues/3789)), they must
be manually replicated to the secondary.

1. SSH into the **primary** node, and execute the command below:

    ```bash
    sudo cat /home/git/gitlab/config/secrets.yml
    ```

    This will display the secrets that need to be replicated, in YAML format.

1. SSH into the **secondary** node and login as the `git` user:

    ```bash
    sudo -i -u git
    ```

1. Make a backup of any existing secrets:

    ```bash
    mv /home/git/gitlab/config/secrets.yml /home/git/gitlab/config/secrets.yml.`date +%F`
    ```

1. Copy `/home/git/gitlab/config/secrets.yml` from the primary to the secondary, or
   copy-and-paste the file contents between nodes:

    ```bash
    sudo editor /home/git/gitlab/config/secrets.yml

    # paste the output of the `cat` command you ran on the primary
    # save and exit
    ```

1. Ensure the file permissions are correct:

    ```bash
    chown git:git /home/git/gitlab/config/secrets.yml
    chmod 0600 /home/git/gitlab/config/secrets.yml
    ```

1. Restart GitLab for the changes to take effect:

    ```bash
    service gitlab restart
    ```

Once restarted, the secondary will automatically start replicating missing data
from the primary in a process known as backfill. Meanwhile, the primary node
will start to notify the secondary of any changes, so that the secondary can
act on those notifications immediately.

Make sure the secondary instance is running and accessible. You can login to
the secondary node with the same credentials as used in the primary.

### Step 2. Manually replicate primary SSH host keys

Read [Manually replicate primary SSH host keys](configuration.md#step-2-manually-replicate-primary-ssh-host-keys)

### Step 3. (Optional) Enabling hashed storage (from GitLab 10.0)

Read [Enabling Hashed Storage](configuration.md#step-3-optional-enabling-hashed-storage-from-gitlab-10-0)

### Step 4. (Optional) Configuring the secondary to trust the primary

You can safely skip this step if your primary uses a CA-issued HTTPS certificate.

If your primary is using a self-signed certificate for *HTTPS* support, you will
need to add that certificate to the secondary's trust store. Retrieve the
certificate from the primary and follow your distribution's instructions for
adding it to the secondary's trust store. In Debian/Ubuntu, for example, with a
certificate file of `primary.geo.example.com.crt`, you would follow these steps:

```
sudo -i
cp primary.geo.example.com.crt /usr/local/share/ca-certificates
update-ca-certificates
```

### Step 5. Enable Git access over HTTP/HTTPS

GitLab Geo synchronizes repositories over HTTP/HTTPS, and therefore requires this clone
method to be enabled. Navigate to **Admin Area ➔ Settings**
(`/admin/application_settings`) on the primary node, and set
`Enabled Git access protocols` to `Both SSH and HTTP(S)` or `Only HTTP(S)`.

### Step 6. Verify proper functioning of the secondary node

Read [Verify proper functioning of the secondary node](configuration.md#step-6-verify-proper-functioning-of-the-secondary-node).


## Selective replication

Read [Selective replication](configuration.md#selective-replication).

## Troubleshooting

Read the [troubleshooting document](troubleshooting.md).
