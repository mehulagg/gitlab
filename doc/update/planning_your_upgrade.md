---
stage: Enablement
group: Distribution
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#assignments
---

# Guide to creating a GitLab upgrade plan

This document is a customer's guide to creating a strong plan to upgrade a self-managed GitLab instance.

It will leverage the [GitLab documentation](https://docs.gitlab.com/) extensively because [documentation is the single source of truth](../development/documentation/styleguide/index.md#documentation-is-the-single-source-of-truth-ssot) for all information about the upgrade process. Please read any applicable sections of the documentation in their entirety.

## How to use this guide

To use this guide, first [create a rollback plan](#rollback-plan). It's possible that something may go wrong during an upgrade, so it's critical that a [rollback plan](#rollback-plan) be present for that scenario.

For the upgrade plan, start by [creating the frame of a plan that would best apply to your instance](#framework-required) and then update it for any [relevant features you're using](#features). Feel free to ignore sections about features that are inapplicable to your setup, such as [Geo](#geo), [external Gitaly](#external-gitaly), or [Elasticsearch](#elasticsearch).

Right before the upgrade, perform the [pre-upgrade and post-upgrade checks](#pre-upgrade-and-post-upgrade-checks) to ensure the major components of GitLab are working. If all goes well, then upgrade GitLab. Then immediately follow-up with the [checks](#pre-upgrade-and-post-upgrade-checks) again. [See this if something goes wrong](#if-something-goes-wrong).

## General notes

- If possible, we recommend you test out an upgrade in a test environment before upgrading your production instance. Ideally, your test environment should mimic your production environment as closely as possible.
- If [working with Support](https://about.gitlab.com/support/scheduling-live-upgrade-assistance.html) to create your plan, share details of your architecture including:
  - How is GitLab installed?
  - What is the operating system of the node? (check [OS Versions that are no longer supported](https://docs.gitlab.com/omnibus/package-information/deprecated_os.html) to confirm that later upgrades are available)
  - Is it a single-node or a multi-node setup? If multi-node, please share architectural details about each node with us.
  - Are you using GitLab Geo? If so, please share architectural details about each secondary node.
  - What else might be unique or interesting in your setup that might be important for us to understand?
  - Are you running into any known issues with your current version of GitLab?

## Pre-upgrade and post-upgrade checks

- Run `gitlab-rake gitlab:check` - [docs](../administration/raketasks/maintenance.md#check-gitlab-configuration)
- Run `gitlab-rake gitlab:doctor:secrets` to confirm that encrypted database values can be decrypted - [docs](../administration/raketasks/doctor.md#verify-database-values-can-be-decrypted-using-the-current-secrets)

- In UI:
  - Users can log in
  - Project list is visible
  - Project issues and MRs are accessible
  - Users can clone repositories from GitLab
  - Users can push commits to GitLab

- CI:
  - Runners pick up jobs
  - Images can be pushed/pulled from the registry

- If using Geo:
  - `gitlab-rake gitlab:geo:check` - on primary and each secondary
  
- If using Elasticsearch, searches are successful

## Rollback plan

In case of any trouble during the upgrade process, a proper rollback plan will create a clear path to bring the instance back to its last working state. It is comprised of a way to [backup the instance](#backup-gitlab) and a way to [restore it](#restore-gitlab).

### Backup GitLab

Create a backup of GitLab and all its data (database, repos, uploads, builds, artifacts, lfs objects, registry, pages). This is vital for making it possible to roll back GitLab to a working state if there's a problem with the upgrade.

- Create a GitLab backup - [Omnibus](../raketasks/backup_restore.md), [Helm](https://docs.gitlab.com/charts/backup-restore/index.html)
  - Back up the [secrets & configuration files](../raketasks/backup_restore.md#storing-configuration-files), too
- Alternatively, create a snapshot of your instance. If this is a multi-node installation, then be sure to snapshot every node. **This process is out of scope for GitLab Support.**

### Restore GitLab

Know how you will restore your [backup](#backup-gitlab).

- Restore GitLab using the documentation - [Omnibus](../raketasks/backup_restore.md), [Helm](https://docs.gitlab.com/charts/backup-restore/index.html)
  - If a restore is needed, GitLab will have to [be downgraded](https://docs.gitlab.com/omnibus/update/#downgrade) first, in order to match the version that created the backup
  - Confirm that the [secrets & configuration files](../raketasks/backup_restore.md#storing-configuration-files) are also restored
- If restoring from a snapshot, know the steps to do this. **This process is out of scope for GitLab Support.**

## Upgrade plan

### Framework (required)

- Generate a skeletal plan with the applicable documentation:
  - Upgrading [Omnibus](index.md#linux-packages-omnibus-gitlab), [Source](index.md#installation-from-source), [Docker](index.md#installation-using-docker), [Helm](index.md#installation-using-helm)
  - [Upgrading from GitLab CE to EE, or vice-versa](https://docs.gitlab.com/omnibus/update/#update-community-edition-to-enterprise-edition)
  - [Zero-downtime upgrades](https://docs.gitlab.com/omnibus/update/#zero-downtime-updates) ([if possible](index.md#upgrading-without-downtime) and desired)

- Versions
  - [Determine what upgrade path](index.md#upgrade-paths) to follow
  - Account for any [version-specific upgrade instructions](index.md#version-specific-upgrading-instructions)
  - Account for any [version-specific changes](https://docs.gitlab.com/omnibus/update/#version-specific-changes)
  - Check [OS compatibility with the target GitLab version](https://docs.gitlab.com/omnibus/package-information/deprecated_os.html)

- Due to [background migrations](https://docs.gitlab.com/omnibus/update/#background-migrations), plan to pause after upgrading to a new major version. [All migrations must finish running](index.md#checking-for-background-migrations-before-upgrading) before the next upgrade.

- If available in your starting version, consider [turning on **maintenance mode**](../administration/maintenance_mode/) during the upgrade

- PostgreSQL
  - In the **Admin Area**, look for the version of PostgreSQL you are using.
  - If [a PostgreSQL upgrade is needed](https://docs.gitlab.com/omnibus/package-information/postgresql_versions.html), account for the relevant [packaged](https://docs.gitlab.com/omnibus/settings/database.html#upgrade-packaged-postgresql-server) or [non-packaged](https://docs.gitlab.com/omnibus/settings/database.html#upgrade-a-non-packaged-postgresql-database) steps.

### Features

#### External Gitaly

If you're using an external Gitaly server, account for [these steps](https://docs.gitlab.com/omnibus/update/#upgrade-gitaly-servers)

#### Geo

- Review [Geo's upgrade docs](../administration/geo/replication/updating_the_geo_nodes.md)
- Account for [Geo version-specific upgrade instructions](../administration/geo/replication/version_specific_updates.md)
- Review Geo-specific steps when [upgrading the database](https://docs.gitlab.com/omnibus/settings/database.html#upgrading-a-geo-instance)
- Create an upgrade & rollback plan for _each_ Geo node (primary and each secondary)

#### Runners

After upgrading GitLab, upgrade your runners to match [your new GitLab version](https://docs.gitlab.com/runner/#gitlab-runner-versions)

#### Elasticsearch

After upgrading GitLab, you may have to upgrade [Elasticsearch if the new version breaks compatibility](../integration/elasticsearch.md#version-requirements). Please note that upgrading Elasticsearch is **out of scope for GitLab Support**.

## If something goes wrong

- If time is of the essence, we recommend copying any error(s) and gathering logs ([Omnibus](https://gitlab.com/gitlab-com/support/toolbox/gitlabsos), [Helm](https://gitlab.com/gitlab-com/support/toolbox/kubesos/)) to later analyze and then [rolling back to the last working version](#rollback-plan)

- For support, [contact GitLab Support](https://support.gitlab.com) and, if you have one, your Technical Account Manager.

- If [the situation qualifies](https://about.gitlab.com/support/#definitions-of-support-impact) and [your plan includes emergency support](https://about.gitlab.com/support/#priority-support), then create an emergency ticket.
