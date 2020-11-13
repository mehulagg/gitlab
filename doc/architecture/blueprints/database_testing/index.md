---
comments: false
description: 'Database Testing'
---

# Database Testing

We have identified [common themes of reverted migrations](https://gitlab.com/gitlab-org/gitlab/-/issues/233391) and discovered failed migrations breaking in both production and staging even when successfully tested in a developer environment. We have also experienced production incidents even with successful testing in staging. These failures are quite expensive: they can have a significant effect on availability, block deployments, and generate incident escalations. These escalations must be triaged and either reverted or fixed forward. Often, this can take place without the original author's involvement due to time zones and/or the criticality of the escalation. With our increased deployment speeds and stricter uptime requirements, the need for improving database testing is critical, particularly earlier in the development process (shift left).

Our primary goal is to **provide developers with access to production-like database testing environments so that data migrations can be tested earlier in the development cycle**, and to do so with high levels of efficiency (particularly in terms of infrastructure costs). We must also ensure **we manage and detect drift in database schemas**, where we expect these testing environments to provide a key role by relieving pressure on the staging environment.



## Current day

Developers are expected to test database migrations prior to deploying to any environment, but we lack the ability to perform testing against large environments such a GitLab.com. The [developer database migration style guide](/ee/development/migration_style_guide.md) provides guidelines on migrations, and we focus on validating migrations during testing.

*TODO* - provide details of database changes workflow as it exists today



## Next

About two years ago, in trying to address database instability, we started looking at [using ZFS on database systems](https://gitlab.com/gitlab-com/gl-infra/readiness/-/tree/master/library/zfs-filesystem#anatomy-of-a-zfs-db-storage-node) to leverage its snapshot and cloning capabilities to create thin database clones for testing purposes with production-like data. This work was postponed as we focused on more pressing availability tasks. The proposed testing pipeline would replicate production data to a server dedicated to the testing solution, i.e., it would not serve any production traffic. From this baseline, a coned could be created that would then be scrubbed of sensitive data. The scrubbed clone could then be snapshoted, and from there, on-demand clones could be created for testing. These clones are *thin*, i.e., the clones only contain deltas of data changes in the file system, and can be discarded once testing is completed.

### Short-term

The short-term focus is geared towards vendor solutions that can quickly provide the required capabilities (scrubbing, subsetting, and thin-cloning). If we find a vendor that suits our needs, we would to set up their solution in our environment.

- Infrastructure would provide the underlying compute, storage and network resources and configuration to deploy the solution
- The Development Database team would manage this application, including access requests
- Access would be granted to our current set of [database maintainers](https://about.gitlab.com/handbook/engineering/projects/#gitlab_maintainers_database)
- The Database maitainer procedures would be expanded to require running the migration against a clone

This solution will require a fair amount of manual intervention and will be limited in scope, but it is expected to have an immediate effect on the success rate of database migrations.

### Mid-term

To determine our long-term strategy, we will need to evaluate the vendor solution through the typical build vs. buy lens, with three possible outcomes:

* Adopt the vendor solution as a long-term strategy, ensuring integration with our QA framework
* Build our own in-house, ZFS-based solution to replace the vendor solution

In both cases, we must strive to integrate it with GitLab's QA framework, ensure full automation for testing and reporting (likely through a private set of CI runners), manage access controls, and expand the offering to all engineers (both across Development and Infrastructure).

### Long-term

Clearly, long-term plans will be determined by the buy-vs-build evaluation, at which time we can be more specific with said plans. In any case, we almost expect to build our solution to ensure we can fully integrated with our QA framework, observability stack, and access controls.

#### Building in-house

In this scenario, different teams would work through a [working group](https://about.gitlab.com/company/team/structure/working-groups/) to build this solution, roughly along the following lines:

*  The **Development Database team** would be responsible for developing a scrubbing solution that meets security and compliance requirements as determined by Security. Additionally, they would provide requirements for access requirements by developers to the cloned instances (logs, metrics, etc)
* **Infrastructure** would be tasked with the management and configuration of the underlying infrastructure, configuring the necessary database replication to the base testing host, automation of snapshot and cloning capabilities, and integration of a data anonymization implementation in the replication process.
* **QA** would work to specify integrations requirements to enable the use of this capability within the QA framework.

##### Data anonymization

One important aspect to resolve is data anonymization (scrubbing). The Development Database team has an issue opened on this topic: [#95](https://gitlab.com/gitlab-org/database-team/team-tasks/-/issues/95). 

## Proposal

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