---
comments: false
description: 'Shift Left in testing database migrations'
---

# Shift Left in testing database migrations

We have undertaken an effort to identify [common themes of reverted migrations](https://gitlab.com/gitlab-org/gitlab/-/issues/233391) and discovered a theme of migrations breaking when they are tested against staging and production evironments even though they have passed in the developer environment. The goal of this blueprint is to outline the steps we will be taking to provide developers the access to be able to test their data migrations against production-like data earlier in the software development lifecycle. Failures in staging and production are quite expensive as they raise incident escalations. These escalations must be triaged and either reverted or fix it forward. Often this can take place without the original author's involvement due to timezones and/or criticality of the escalation. By providing the ability to test against production-like data in the developers environment, we can catch defects (e.g. failed migrations) much earlier in the process (shift left).

## Current Situation

It is expected that developers test their migrations prior to deploying to any environment. However, there is no requirement to test against a minimum data set. These migration tests can pass structurally, but fail when a database is fully populated
TODO - better explanation of current state

## Moving Forward

We are investigating fast and efficient ways to provide lightweight, secure and scrubbed clones of our production database for testing migrations.

### Near Term

Investigate of the shelf solutions that can quickly provide cloning, scrubbing and subsetting database features. If we find a vendor that suits our needs we would then

- Grant access to our current set of [database maintainers](https://about.gitlab.com/handbook/engineering/projects/#gitlab_maintainers_database)
- Add a step to our maintainer process to require running the migration against a clone

Ideally this would reduce our migration incidents to zero.

### Long Term

Manual processes don't scale so we will need to automate this process. Additionally, we will need to evaluate the vendor solution through the typical build vs. buy lens. Our long term plans would include

- Evaluate efficiency gains from vendor solution
- Determine roadmap for in-house solution. Some ideas and supporting technologies around an in-house solution are already taking place in this [ZFS Filesystem](https://gitlab.com/gitlab-com/gl-infra/readiness/-/tree/master/library/zfs-filesystem) page.

In parallel we would work on an automated solution to replace the manual review process

- Automate the creation of snapshots, whether they are trigger or time based
- Create a private CI Runner to test migrations automatically and safely without triggering any unintended consequences
- Automate scrubbing/obfuscation of data

#### Infrastructure/SRE involvement

There will be a considerable amount of involvement required from Infrastructure and SRE as well. 

- Provisioning infrastructure at each step
- Deploying supporting infrastructure, such as ZFS (see [Anatomy of ZFS DB Storage Node](https://gitlab.com/gitlab-com/gl-infra/readiness/-/tree/master/library/zfs-filesystem#anatomy-of-a-zfs-db-storage-node))
- Snapshot Automation

Proposal:

| Role                         | Who
|------------------------------|-------------------------|
| Author                       |    Craig Gomes          |
| Architecture Evolution Coach | Gerardo Lopez-Fernandez |
| Engineering Leader           |    Craig Gomes          |
| Domain Expert                |    Andreas Brandl       |
| Domain Expert                |    Jose Finotto         |
| Domain Expert                |    Yannis Roussos       |
| Domain Expert                |    Pat Bair             |

DRIs:

| Role                         | Who
|------------------------------|------------------------|
| Product                      |    Josh Lambert        |
| Leadership                   |    Craig Gomes         |
| Engineering                  |    Andreas Brandl      |
