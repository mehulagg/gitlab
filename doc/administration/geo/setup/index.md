---
stage: Enablement
group: Geo
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#designated-technical-writers
type: howto
---

# Setting up Geo

These instructions are for a Geo deployment with single-node primary and secondary sites. Additional instructions are provided in a separate section for [Geo deployments with multi-node primary and secondary sites](../replication/mulitple_servers.md). These instructions assume you have a working single-node GitLab site, and guide you through:

1. Making your existing site the **primary** site.
1. Adding **secondary** sites.

CAUTION: **Caution:**
The steps below should be followed in the order they appear. **Make sure the GitLab version is the same on all sites.**

## Using Omnibus GitLab

If you installed GitLab using the Omnibus packages (highly recommended):

1. [Install GitLab Enterprise Edition](https://about.gitlab.com/install/) on the site that will serve as the **secondary** site. Do not create an account or log in to the new **secondary** site.
1. [Upload the GitLab License](../../../user/admin_area/license.md) on the **primary** site to unlock Geo. The license must be for [GitLab Premium](https://about.gitlab.com/pricing/) or higher.
1. [Set up the database replication](database.md) (`primary (read-write) <-> secondary (read-only)` topology).
1. [Configure fast lookup of authorized SSH keys in the database](../../operations/fast_ssh_key_lookup.md). This step is required and needs to be done on **both** the **primary** and **secondary** sites.
1. [Configure GitLab](../replication/configuration.md) to set the **primary** and **secondary** sites.
1. Optional: [Configure a secondary LDAP server](../../auth/ldap/index.md) for the **secondary** site. See [notes on LDAP](../index.md#ldap).
1. [Follow the "Using a Geo Server" guide](../replication/using_a_geo_server.md).

## Post-installation documentation

After installing GitLab on the **secondary** sites and performing the initial configuration, see the [following documentation for post-installation information](../index.md#post-installation-documentation).
