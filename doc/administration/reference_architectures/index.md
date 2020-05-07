---
type: reference, concepts
---
# Reference architectures

<!-- TBD to be reviewed by Eric -->

You can set up GitLab on a single server or scale it up to serve many users.
This page details the recommended Reference Architectures that were built and verified by GitLab's Quality and Support teams.

Below is a chart representing each architecture tier and the number of users they can handle. As your number of users grow with time, it’s recommended that you scale GitLab accordingly.

![Reference Architectures](img/reference-architectures.png)
<!-- Internal link: https://docs.google.com/spreadsheets/d/1obYP4fLKkVVDOljaI3-ozhmCiPtEeMblbBKkf2OADKs/edit#gid=1403207183 -->

Testing on these reference architectures were performed with [GitLab's Performance Tool](https://gitlab.com/gitlab-org/quality/performance)
at specific coded workloads, and the throughputs used for testing were calculated based on sample customer data.
After selecting the reference architecture that matches your scale, refer to
[Configure GitLab to Scale](#configure-gitlab-to-scale) to see the components
involved, and how to configure them.

Each endpoint type is tested with the following number of requests per second (RPS) per 1000 users:

- API: 20 RPS
- Web: 2 RPS
- Git: 2 RPS

For GitLab instances with less than 2,000 users, it's recommended that you use the [default setup](#automated-backups-core-only)
by [installing GitLab](../../install/README.md) on a single machine to minimize maintenance and resource costs.

If your organization has more than 2,000 users, the recommendation is to scale GitLab's components to multiple
machine nodes. The machine nodes are grouped by component(s). The addition of these
nodes increases the performance and scalability of to your GitLab instance.
As long as there is at least one of each component online and capable of handling
the instance's usage load, your team's productivity will not be interrupted.
Scaling GitLab in this manner also enables you to perform [zero-downtime updates](https://docs.gitlab.com/omnibus/update/#zero-downtime-updates).

When scaling GitLab, there are several factors to consider:

- Multiple application nodes to handle frontend traffic.
- A load balancer is added in front to distribute traffic across the application nodes.
- The application nodes connects to a shared file server and PostgreSQL and Redis services on the backend.

NOTE: **Note:** Depending on your workflow, the following recommended
reference architectures may need to be adapted accordingly. Your workload
is influenced by factors including how active your users are,
how much automation you use, mirroring, and repository/change size. Additionally the
displayed memory values are provided by [GCP machine types](https://cloud.google.com/compute/docs/machine-types).
For different cloud vendors, attempt to select options that best match the provided architecture.

## Up to 1,000 users

From 1 to 1,000 users, a [single-node setup with frequent backups](#automated-backups-core-only) is adequate.

| Users | Configuration([8](#footnotes)) | GCP type      | AWS type([9](#footnotes)) |
|-------|--------------------------------|---------------|---------------------------|
| 100   | 2 vCPU, 7.2GB Memory           | n1-standard-2 | c5.2xlarge                |
| 500   | 4 vCPU, 15GB Memory            | n1-standard-4 | m5.xlarge                 |
| 1000  | 8 vCPU, 30GB Memory            | n1-standard-8 | m5.2xlarge                |

This solution is appropriate for many teams that have a single server at their disposal. With automatic backup of the GitLab repositories, configuration, and the database, this can be an optimal solution if you don't have strict availability requirements.

You can also optionally configure GitLab to use an [external PostgreSQL service](../external_database.md) or an [external object storage service](../high_availability/object_storage.md) for added performance and reliability at a relatively low complexity cost.

## Up to 2,000 users

> - **Supported users (approximate):** 2,000
> - **High Availability:** False
> - **Test RPS rates:** API: 40 RPS, Web: 4 RPS, Git: 4 RPS

| Service                                                      | Nodes | Configuration ([8](#footnotes)) | GCP type      | AWS type ([9](#footnotes)) |
|--------------------------------------------------------------|-------|---------------------------------|---------------|----------------------------|
| GitLab Rails, Sidekiq, Consul ([1](#footnotes))              | 2     | 8 vCPU, 7.2GB Memory            | n1-highcpu-8  | c5.2xlarge                 |
| PostgreSQL                                                   | 1     | 2 vCPU, 7.5GB Memory            | n1-standard-2 | m5.large                   |
| Gitaly ([2](#footnotes)) ([5](#footnotes)) ([7](#footnotes)) | X     | 4 vCPU, 15GB Memory             | n1-standard-4 | m5.xlarge                  |
| Cloud Object Storage ([4](#footnotes))                       | -     | -                               | -             | -                          |
| NFS Server ([5](#footnotes)) ([7](#footnotes))               | 1     | 4 vCPU, 3.6GB Memory            | n1-highcpu-4  | c5.xlarge                  |
| External load balancing node ([6](#footnotes))               | 1     | 2 vCPU, 1.8GB Memory            | n1-highcpu-2  | c5.large                   |

## Up to 3,000 users

NOTE: **Note:** The 3,000-user reference architecture documented below is
designed to help your organization achieve a highly-available GitLab deployment.
If you do not have the expertise or need to maintain a highly-available
environment, you can have a simpler and less costly-to-operate environment by
deploying two or more GitLab Rails servers, external load balancing, an NFS
server, a PostgreSQL server and a Redis server. A reference architecture with
this alternative in mind is [being worked on](https://gitlab.com/gitlab-org/quality/performance/-/issues/223).

> - **Supported users (approximate):** 3,000
> - **High Availability:** True
> - **Test RPS rates:** API: 60 RPS, Web: 6 RPS, Git: 6 RPS

| Service                                                      | Nodes | Configuration ([8](#footnotes)) | GCP type      | AWS type ([9](#footnotes)) |
|--------------------------------------------------------------|-------|---------------------------------|---------------|----------------------------|
| GitLab Rails ([1](#footnotes))                               | 3     | 8 vCPU, 7.2GB Memory            | n1-highcpu-8  | c5.2xlarge                 |
| PostgreSQL                                                   | 3     | 2 vCPU, 7.5GB Memory            | n1-standard-2 | m5.large                   |
| PgBouncer                                                    | 3     | 2 vCPU, 1.8GB Memory            | n1-highcpu-2  | c5.large                   |
| Gitaly ([2](#footnotes)) ([5](#footnotes)) ([7](#footnotes)) | X     | 4 vCPU, 15GB Memory             | n1-standard-4 | m5.xlarge                  |
| Redis ([3](#footnotes))                                      | 3     | 2 vCPU, 7.5GB Memory            | n1-standard-2 | m5.large                   |
| Consul + Sentinel ([3](#footnotes))                          | 3     | 2 vCPU, 1.8GB Memory            | n1-highcpu-2  | c5.large                   |
| Sidekiq                                                      | 4     | 2 vCPU, 7.5GB Memory            | n1-standard-2 | m5.large                   |
| Cloud Object Storage ([4](#footnotes))                       | -     | -                               | -             | -                          |
| NFS Server ([5](#footnotes)) ([7](#footnotes))               | 1     | 4 vCPU, 3.6GB Memory            | n1-highcpu-4  | c5.xlarge                  |
| Monitoring node                                              | 1     | 2 vCPU, 1.8GB Memory            | n1-highcpu-2  | c5.large                   |
| External load balancing node ([6](#footnotes))               | 1     | 2 vCPU, 1.8GB Memory            | n1-highcpu-2  | c5.large                   |
| Internal load balancing node ([6](#footnotes))               | 1     | 2 vCPU, 1.8GB Memory            | n1-highcpu-2  | c5.large                   |

## Up to 5,000 users

> - **Supported users (approximate):** 5,000
> - **High Availability:** True
> - **Test RPS rates:** API: 100 RPS, Web: 10 RPS, Git: 10 RPS

| Service                                                      | Nodes | Configuration ([8](#footnotes)) | GCP type      | AWS type ([9](#footnotes)) |
|--------------------------------------------------------------|-------|---------------------------------|---------------|----------------------------|
| GitLab Rails ([1](#footnotes))                               | 3     | 16 vCPU, 14.4GB Memory          | n1-highcpu-16 | c5.4xlarge                 |
| PostgreSQL                                                   | 3     | 2 vCPU, 7.5GB Memory            | n1-standard-2 | m5.large                   |
| PgBouncer                                                    | 3     | 2 vCPU, 1.8GB Memory            | n1-highcpu-2  | c5.large                   |
| Gitaly ([2](#footnotes)) ([5](#footnotes)) ([7](#footnotes)) | X     | 8 vCPU, 30GB Memory             | n1-standard-8 | m5.2xlarge                 |
| Redis ([3](#footnotes))                                      | 3     | 2 vCPU, 7.5GB Memory            | n1-standard-2 | m5.large                   |
| Consul + Sentinel ([3](#footnotes))                          | 3     | 2 vCPU, 1.8GB Memory            | n1-highcpu-2  | c5.large                   |
| Sidekiq                                                      | 4     | 2 vCPU, 7.5GB Memory            | n1-standard-2 | m5.large                   |
| Cloud Object Storage ([4](#footnotes))                       | -     | -                               | -             | -                          |
| NFS Server ([5](#footnotes)) ([7](#footnotes))               | 1     | 4 vCPU, 3.6GB Memory            | n1-highcpu-4  | c5.xlarge                  |
| Monitoring node                                              | 1     | 2 vCPU, 1.8GB Memory            | n1-highcpu-2  | c5.large                   |
| External load balancing node ([6](#footnotes))               | 1     | 2 vCPU, 1.8GB Memory            | n1-highcpu-2  | c5.large                   |
| Internal load balancing node ([6](#footnotes))               | 1     | 2 vCPU, 1.8GB Memory            | n1-highcpu-2  | c5.large                   |

## Up to 10,000 users

> - **Supported users (approximate):** 10,000
> - **High Availability:** True
> - **Test RPS rates:** API: 200 RPS, Web: 20 RPS, Git: 20 RPS

| Service                                                      | Nodes | GCP Configuration ([8](#footnotes)) | GCP type       | AWS type ([9](#footnotes)) |
|--------------------------------------------------------------|-------|-------------------------------------|----------------|----------------------------|
| GitLab Rails ([1](#footnotes))                               | 3     | 32 vCPU, 28.8GB Memory              | n1-highcpu-32  | c5.9xlarge                 |
| PostgreSQL                                                   | 3     | 4 vCPU, 15GB Memory                 | n1-standard-4  | m5.xlarge                  |
| PgBouncer                                                    | 3     | 2 vCPU, 1.8GB Memory                | n1-highcpu-2   | c5.large                   |
| Gitaly ([2](#footnotes)) ([5](#footnotes)) ([7](#footnotes)) | X     | 16 vCPU, 60GB Memory                | n1-standard-16 | m5.4xlarge                 |
| Redis ([3](#footnotes)) - Cache                              | 3     | 4 vCPU, 15GB Memory                 | n1-standard-4  | m5.xlarge                  |
| Redis ([3](#footnotes)) - Queues / Shared State              | 3     | 4 vCPU, 15GB Memory                 | n1-standard-4  | m5.xlarge                  |
| Redis Sentinel ([3](#footnotes)) - Cache                     | 3     | 1 vCPU, 1.7GB Memory                | g1-small       | t2.small                   |
| Redis Sentinel ([3](#footnotes)) - Queues / Shared State     | 3     | 1 vCPU, 1.7GB Memory                | g1-small       | t2.small                   |
| Consul                                                       | 3     | 2 vCPU, 1.8GB Memory                | n1-highcpu-2   | c5.large                   |
| Sidekiq                                                      | 4     | 4 vCPU, 15GB Memory                 | n1-standard-4  | m5.xlarge                  |
| Cloud Object Storage ([4](#footnotes))                       | -     | -                                   | -              | -                          |
| NFS Server ([5](#footnotes)) ([7](#footnotes))               | 1     | 4 vCPU, 3.6GB Memory                | n1-highcpu-4   | c5.xlarge                  |
| Monitoring node                                              | 1     | 4 vCPU, 3.6GB Memory                | n1-highcpu-4   | c5.xlarge                  |
| External load balancing node ([6](#footnotes))               | 1     | 2 vCPU, 1.8GB Memory                | n1-highcpu-2   | c5.large                   |
| Internal load balancing node ([6](#footnotes))               | 1     | 2 vCPU, 1.8GB Memory                | n1-highcpu-2   | c5.large                   |

## Up to 25,000 users

> - **Supported users (approximate):** 25,000
> - **High Availability:** True
> - **Test RPS rates:** API: 500 RPS, Web: 50 RPS, Git: 50 RPS

| Service                                                      | Nodes | Configuration ([8](#footnotes)) | GCP type       | AWS type ([9](#footnotes)) |
|--------------------------------------------------------------|-------|---------------------------------|----------------|----------------------------|
| GitLab Rails ([1](#footnotes))                               | 5     | 32 vCPU, 28.8GB Memory          | n1-highcpu-32  | c5.9xlarge                 |
| PostgreSQL                                                   | 3     | 8 vCPU, 30GB Memory             | n1-standard-8  | m5.2xlarge                 |
| PgBouncer                                                    | 3     | 2 vCPU, 1.8GB Memory            | n1-highcpu-2   | c5.large                   |
| Gitaly ([2](#footnotes)) ([5](#footnotes)) ([7](#footnotes)) | X     | 32 vCPU, 120GB Memory           | n1-standard-32 | m5.8xlarge                 |
| Redis ([3](#footnotes)) - Cache                              | 3     | 4 vCPU, 15GB Memory             | n1-standard-4  | m5.xlarge                  |
| Redis ([3](#footnotes)) - Queues / Shared State              | 3     | 4 vCPU, 15GB Memory             | n1-standard-4  | m5.xlarge                  |
| Redis Sentinel ([3](#footnotes)) - Cache                     | 3     | 1 vCPU, 1.7GB Memory            | g1-small       | t2.small                   |
| Redis Sentinel ([3](#footnotes)) - Queues / Shared State     | 3     | 1 vCPU, 1.7GB Memory            | g1-small       | t2.small                   |
| Consul                                                       | 3     | 2 vCPU, 1.8GB Memory            | n1-highcpu-2   | c5.large                   |
| Sidekiq                                                      | 4     | 4 vCPU, 15GB Memory             | n1-standard-4  | m5.xlarge                  |
| Cloud Object Storage ([4](#footnotes))                       | -     | -                               | -              | -                          |
| NFS Server ([5](#footnotes)) ([7](#footnotes))               | 1     | 4 vCPU, 3.6GB Memory            | n1-highcpu-4   | c5.xlarge                  |
| Monitoring node                                              | 1     | 4 vCPU, 3.6GB Memory            | n1-highcpu-4   | c5.xlarge                  |
| External load balancing node ([6](#footnotes))               | 1     | 2 vCPU, 1.8GB Memory            | n1-highcpu-2   | c5.large                   |
| Internal load balancing node ([6](#footnotes))               | 1     | 4 vCPU, 3.6GB Memory            | n1-highcpu-4   | c5.xlarge                  |

## Up to 50,000 users

> - **Supported users (approximate):** 50,000
> - **High Availability:** True
> - **Test RPS rates:** API: 1000 RPS, Web: 100 RPS, Git: 100 RPS

| Service                                                      | Nodes | Configuration ([8](#footnotes)) | GCP type       | AWS type ([9](#footnotes)) |
|--------------------------------------------------------------|-------|---------------------------------|----------------|----------------------------|
| GitLab Rails ([1](#footnotes))                               | 12    | 32 vCPU, 28.8GB Memory          | n1-highcpu-32  | c5.9xlarge                 |
| PostgreSQL                                                   | 3     | 16 vCPU, 60GB Memory            | n1-standard-16 | m5.4xlarge                 |
| PgBouncer                                                    | 3     | 2 vCPU, 1.8GB Memory            | n1-highcpu-2   | c5.large                   |
| Gitaly ([2](#footnotes)) ([5](#footnotes)) ([7](#footnotes)) | X     | 64 vCPU, 240GB Memory           | n1-standard-64 | m5.16xlarge                |
| Redis ([3](#footnotes)) - Cache                              | 3     | 4 vCPU, 15GB Memory             | n1-standard-4  | m5.xlarge                  |
| Redis ([3](#footnotes)) - Queues / Shared State              | 3     | 4 vCPU, 15GB Memory             | n1-standard-4  | m5.xlarge                  |
| Redis Sentinel ([3](#footnotes)) - Cache                     | 3     | 1 vCPU, 1.7GB Memory            | g1-small       | t2.small                   |
| Redis Sentinel ([3](#footnotes)) - Queues / Shared State     | 3     | 1 vCPU, 1.7GB Memory            | g1-small       | t2.small                   |
| Consul                                                       | 3     | 2 vCPU, 1.8GB Memory            | n1-highcpu-2   | c5.large                   |
| Sidekiq                                                      | 4     | 4 vCPU, 15GB Memory             | n1-standard-4  | m5.xlarge                  |
| NFS Server ([5](#footnotes)) ([7](#footnotes))               | 1     | 4 vCPU, 3.6GB Memory            | n1-highcpu-4   | c5.xlarge                  |
| Cloud Object Storage ([4](#footnotes))                       | -     | -                               | -              | -                          |
| Monitoring node                                              | 1     | 4 vCPU, 3.6GB Memory            | n1-highcpu-4   | c5.xlarge                  |
| External load balancing node ([6](#footnotes))               | 1     | 2 vCPU, 1.8GB Memory            | n1-highcpu-2   | c5.large                   |
| Internal load balancing node ([6](#footnotes))               | 1     | 8 vCPU, 7.2GB Memory            | n1-highcpu-8   | c5.2xlarge                 |

## Availability complexity

GitLab comes with the following availability complexity for your use, listed from
least to most complex:

1. [Automated backups](#automated-backups-core-only)
1. [Traffic Load Balancer](#Traffic-load-balancer-starter-only)
1. [Automated database failover](#automated-database-failover-premium-only)
1. [Instance level replication with GitLab Geo](#instance-level-replication-with-gitlab-geo-premium-only)

As you get started implementing HA, begin with a single server and then do
backups. Only after completing the first server should you proceed to the next.

Also, not implementing HA for GitLab doesn't necessarily mean that you'll have
more downtime. Depending on your needs and experience level, non-HA servers can
have more actual perceived uptime for your users.

### Automated backups **(CORE ONLY)**

> - Level of complexity: **Low**
> - Required domain knowledge: PostgreSQL, GitLab configurations, Git
> - Supported tiers: [GitLab Core, Starter, Premium, and Ultimate](https://about.gitlab.com/pricing/)

This solution is appropriate for many teams that have the default GitLab installation.
With automatic backups of the GitLab repositories, configuration, and the database,
this can be an optimal solution if you don't have strict availability requirements.
[Automated backups](../../raketasks/backup_restore.md#configuring-cron-to-make-daily-backups)
is the least complex to setup. This provides a point-in-time recovery of a predetermined schedule.

### Traffic load balancer **(STARTER ONLY)**

> - Level of complexity: **Medium**
> - Required domain knowledge: HAProxy, shared storage, distributed systems
> - Supported tiers: [GitLab Starter, Premium, and Ultimate](https://about.gitlab.com/pricing/)

This requires separating out GitLab into multiple application nodes with an added
[load balancer](../high_availability/load_balancer.md). The load balancer will distribute traffic
across GitLab application nodes. Meanwhile, each application node connects to a
shared file server and database systems on the back end. This way, if one of the
application servers fails, the workflow is not interrupted.
[HAProxy](https://www.haproxy.org/) is recommended as the load balancer.

With this added availability component you have a number of advantages compared
to the default installation:

- Increase the number of users.
- Enable zero-downtime upgrades.
- Increase availability.

### Automated database failover **(PREMIUM ONLY)**

> - Level of complexity: **High**
> - Required domain knowledge: PgBouncer, Repmgr, shared storage, distributed systems
> - Supported tiers: [GitLab Premium and Ultimate](https://about.gitlab.com/pricing/)

By adding automatic failover for database systems, you can enable higher uptime
with an additional database nodes. This extends the default database with a
cluster management and failover policies.
[PgBouncer](../../development/architecture.md#pgbouncer) in conjunction with
[Repmgr](../high_availability/database.md) is recommended.

### Instance level replication with GitLab Geo **(PREMIUM ONLY)**

> - Level of complexity: **Very High**
> - Required domain knowledge: Storage replication
> - Supported tiers: [GitLab Premium and Ultimate](https://about.gitlab.com/pricing/)

[GitLab Geo](../geo/replication/index.md) allows you to replicate your GitLab
instance to other geographical locations as a read-only fully operational instance
that can also be promoted in case of disaster.

## Configure GitLab to scale

The following components are the ones you need to configure in order to scale
GitLab. They are listed in the order you'll typically configure them if they are
required by your [reference architecture](#reference-architectures) of choice.

Most of them are bundled in the GitLab deb/rpm package (called Omnibus GitLab),
but depending on your system architecture, you may require some components which are
not included in it. If required, those should be configured before
setting up components provided by GitLab. Advice on how to select the right
solution for your organization is provided in the configuration instructions
column.

| Component | Description | Configuration instructions | Bundled with Omnibus GitLab |
|-----------|-------------|----------------------------|
| Load balancer(s) ([6](#footnotes)) | Handles load balancing, typically when you have multiple GitLab application services nodes | [Load balancer configuration](../high_availability/load_balancer.md) ([6](#footnotes))      | No |
| Object storage service ([4](#footnotes)) | Recommended store for shared data objects | [Cloud Object Storage configuration](../object_storage.md) | No |
| NFS ([5](#footnotes)) ([7](#footnotes)) | Shared disk storage service. Can be used as an alternative for Gitaly or Object Storage. Required for GitLab Pages | [NFS configuration](../high_availability/nfs.md) | No |
| [Consul](../../development/architecture.md#consul) ([3](#footnotes)) | Service discovery and health checks/failover | [Consul HA configuration](../high_availability/consul.md) **(PREMIUM ONLY)** | Yes |
| [PostgreSQL](../../development/architecture.md#postgresql) | Database | [PostgreSQL configuration](https://docs.gitlab.com/omnibus/settings/database.html) | Yes |
| [PgBouncer](../../development/architecture.md#pgbouncer) | Database connection pooler | [PgBouncer configuration](../high_availability/pgbouncer.md#running-pgbouncer-as-part-of-a-non-ha-gitlab-installation) **(PREMIUM ONLY)** | Yes |
| Repmgr | PostgreSQL cluster management and failover | [PostgreSQL and Repmgr configuration](../high_availability/database.md) | Yes |
| [Redis](../../development/architecture.md#redis) ([3](#footnotes))  | Key/value store for fast data lookup and caching | [Redis configuration](../high_availability/redis.md) | Yes |
| Redis Sentinel | High availability for Redis | [Redis Sentinel configuration](../high_availability/redis.md) | Yes |
| [Gitaly](../../development/architecture.md#gitaly) ([2](#footnotes)) ([5](#footnotes)) ([7](#footnotes))  | Provides access to Git repositories | [Gitaly configuration](../gitaly/index.md#running-gitaly-on-its-own-server) | Yes |
| [Sidekiq](../../development/architecture.md#sidekiq) | Asynchronous/background jobs | [Sidekiq configuration](../high_availability/sidekiq.md) | Yes |
| [GitLab application services](../../development/architecture.md#unicorn)([1](#footnotes)) | Unicorn/Puma, Workhorse, GitLab Shell - serves front-end requests (UI, API, Git over HTTP/SSH) | [GitLab app scaling configuration](../high_availability/gitlab.md) | Yes |
| [Prometheus](../../development/architecture.md#prometheus) and [Grafana](../../development/architecture.md#grafana) | GitLab environment monitoring | [Monitoring node for scaling](../high_availability/monitoring_node.md) | Yes |

## Footnotes

1. In our architectures we run each GitLab Rails node using the Puma webserver
   and have its number of workers set to 90% of available CPUs along with four threads. For
   nodes that are running Rails with other components the worker value should be reduced
   accordingly where we've found 50% achieves a good balance but this is dependent
   on workload.

1. Gitaly node requirements are dependent on customer data, specifically the number of
   projects and their sizes. We recommend two nodes as an absolute minimum for HA environments
   and at least four nodes should be used when supporting 50,000 or more users.
   We also recommend that each Gitaly node should store no more than 5TB of data
   and have the number of [`gitaly-ruby` workers](../gitaly/index.md#gitaly-ruby)
   set to 20% of available CPUs. Additional nodes should be considered in conjunction
   with a review of expected data size and spread based on the recommendations above.

1. Recommended Redis setup differs depending on the size of the architecture.
   For smaller architectures (less than 5,000 users), we suggest one Redis cluster for all
   classes and that Redis Sentinel is hosted alongside Consul.
   For larger architectures (10,000 users or more) we suggest running a separate
   [Redis Cluster](../high_availability/redis.md#running-multiple-redis-clusters) for the Cache class
   and another for the Queues and Shared State classes respectively. We also recommend
   that you run the Redis Sentinel clusters separately for each Redis Cluster.

1. For data objects such as LFS, Uploads, Artifacts, etc. We recommend a [Cloud Object Storage service](../object_storage.md)
   over NFS where possible, due to better performance and availability.

1. NFS can be used as an alternative for both repository data (replacing Gitaly) and
   object storage but this isn't typically recommended for performance reasons. Note however it is required for
   [GitLab Pages](https://gitlab.com/gitlab-org/gitlab-pages/issues/196).

1. Our architectures have been tested and validated with [HAProxy](https://www.haproxy.org/)
   as the load balancer. Although other load balancers with similar feature sets
   could also be used, those load balancers have not been validated.

1. We strongly recommend that any Gitaly or NFS nodes be set up with SSD disks over
   HDD with a throughput of at least 8,000 IOPS for read operations and 2,000 IOPS for write
   as these components have heavy I/O. These IOPS values are recommended only as a starter
   as with time they may be adjusted higher or lower depending on the scale of your
   environment's workload. If you're running the environment on a Cloud provider
   you may need to refer to their documentation on how configure IOPS correctly.

1. The architectures were built and tested with the [Intel Xeon E5 v3 (Haswell)](https://cloud.google.com/compute/docs/cpu-platforms)
   CPU platform on GCP. On different hardware you may find that adjustments, either lower
   or higher, are required for your CPU or Node counts accordingly. For more information, a
   [Sysbench](https://github.com/akopytov/sysbench) benchmark of the CPU can be found
   [here](https://gitlab.com/gitlab-org/quality/performance/-/wikis/Reference-Architectures/GCP-CPU-Benchmarks).

1. AWS-equivalent configurations are rough suggestions and may change in the
   future. They have not yet been tested and validated.
