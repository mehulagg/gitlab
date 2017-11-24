# GitLab Geo SSH access

By default, GitLab manages an `authorized_keys` file, which contains all the
public SSH keys for users allowed to access GitLab. However, to maintain a
single source of truth, Geo needs to be configured to perform SSH fingerprint
lookups via database lookup. This approach is also much faster than scanning a
file.

>**Note:**
GitLab 10.0 and higher require database lookups for SSH keys.

Note this feature is only available on operating systems that support OpenSSH
6.9 and above. For CentOS 6, see the [instructions on building custom
version of OpenSSH for your server]
(../administration/operations/speed_up_ssh.html#compiling-a-custom-version-of-openssh-for-centos-6).

For both primary AND secondary nodes, follow the instructions on
[looking up authorized SSH keys in the database](../administration/operations/speed_up_ssh.html).

Note that the 'Write to "authorized keys" file' checkbox only needs
to be unchecked on the primary node since it will be reflected automatically
in the secondary if database replication is working.
