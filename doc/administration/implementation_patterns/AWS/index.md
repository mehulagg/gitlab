---
type: reference, concepts
stage: Enablement
group: Alliances
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#assignments

---

# AWS Specific Implementation patterns **(FREE SELF)**


## Gitlab Cloud Native Hybrid on EKS


| Manifest                | Ref Arch                                                     | Cost Estimate  | Existing Code                   |
| ----------------------- | ------------------------------------------------------------ | -------------- | ------------------------------- |
|                         |                                                              |                |                                 |
| 10K Cloud Native on EKS | [10K Cloud Native](../../reference_architectures/10k_users.md#cloud-native-hybrid-reference-architecture-with-helm-charts-alternative) | AWS Calculator | AWS Quick Start<br />GitLab GET |
|                         |                                                              |                |                                 |

### 10K Cloud Native on EKS Build Manifest

| Service                                               | Target Allocatable CPUs and Memory (Full Scaled) | Example Idling Cost <br />(min suggested nodes)<br />(On Demand, US East) | Example Full Scaled Cost<br />(On Demand, US East) |
| ----------------------------------------------------- | ------------------------------------------------ | ------------------------------------------------------------ | -------------------------------------------------- |
| Webservice                                            | 127.5 vCPU, 118 GB memory                        |                                                              |                                                    |
| Sidekiq                                               | 15.5 vCPU, 50 GB memory                          |                                                              |                                                    |
| Supporting services such as NGINX, Prometheus, etc.   | 7.75 vCPU, 25 GB memory                          |                                                              |                                                    |
| **Ref Arch Total**                                    | **151 vCPU, 193 GB memory**                      |                                                              |                                                    |
|                                                       |                                                  |                                                              |                                                    |
| EKS Nodes Configuration 1:  c5.9xlarge (36 vcpu/72GB) | 180 vCPU, 360 GB memory                          | (? nodes)                                                    | (5 nodes) $7.65/hr                                 |
| EKS Nodes Configuration 2: c5.4xlarge (16vcpu/32GB)   | 160 vCPU, 320 GB memory                          | (? nodes)                                                    | (10 nodes)$6.80/hr                                 |

Note: AWS (and all cloud providers) support only specific ratios of VCPU and Memory.  GitLab's vCPU and memory requirements do not necessarily align cleanly with these ratios for any given provider.

Note: Picking more of a smaller size instance allows scaling costs to be more granular.

Note: AWS Scaling speed from Idling to Full Scale took x minutes under gpt 10k loading.

| Service                                                    | Advised <br />Nodes | Configuration                  | Total          | Example Cost<br />US East |
| ---------------------------------------------------------- | ------------------- | ------------------------------ | -------------- | ------------------------- |
|                                                            |                     |                                |                |                           |
| **AWS Aurora RDS PostgreSQL (GitLab Data)** which handles: |                     |                                |                |                           |
| - PostgreSQL(1)                                            | 3                   | 8 vCPU, 30 GB memory           | 24vCPU, 90 GB  |                           |
| - PgBouncer(1)                                             | 3                   | 2 vCPU, 1.8 GB memory          | 6vCPU, 5.4 GB  |                           |
| - Consul(1)                                                | 3                   | 2 vCPU, 1.8 GB memory          | 6vCPU, 5.4 GB  |                           |
| - Ref Arch Total                                           | 9                   |                                | 36vCPU, 100 GB |                           |
| Aurora RDS Nodes Configuration (GPT tested)                | 3                   | db.r5.2xlarge (8vCPU, 64 GB)   | 24vCPU, 192 GB | $1.16 x 3 = $3.48/hr      |
|                                                            |                     |                                |                |                           |
| **AWS Elasticache Redis** which handles:                   |                     |                                |                |                           |
| - Redis - Cache(2)                                         | 3                   | 4 vCPU, 15 GB memory           | 12vCPU, 45GB   |                           |
| - Redis - Queues / Shared State(2)                         | 3                   | 4 vCPU, 15 GB memory           | 12vCPU, 45GB   |                           |
| - Redis Sentinel - Cache(2)                                | 3                   | 1 vCPU, 3.75 GB memory         | 3vCPU, 12GB    |                           |
| - Redis Sentinel - Queues / Shared State(2)                | 3                   | 1 vCPU, 3.75 GB memory         | 3vCPU, 12GB    |                           |
| - Ref Arch Total                                           | 12                  |                                | 30vCPU, 114GB  |                           |
| Redis Elasticache Configuration (GPT Tested)               | 3                   | cache.m5.xlarge (4vCPU, 13 GB) | 12vCPU, 40GB   | $0.31 x 3 = $0.93/hr      |
|                                                            |                     |                                |                |                           |
| **Gitaly Cluster (Git file system) on Instance Compute**   |                     |                                |                |                           |
| Gitaly (Instance in an ASG)                                | 3                   | 16 vCPU, 60 GB memory          | m5.4xlarge     | $0.77 x 3 = $2.31/hr      |
| - EBS Volume size per Gitaly Node (Git file system)        |                     | See below.                     |                |                           |
| Praefect (Instances in ASG with load balancer)             | 3                   | 2 vCPU, 1.8 GB memory          | c5.large       | $0.09 x 3 = $0.21/hr      |
| Praefect PostgreSQL(1) [AWS RDS]                           | 3                   | 2 vCPU, 1.8 GB memory          | c5.large       | $0.09 x 3 = $0.21/hr      |
| Internal load balancing node(3) [ELB]                      | 1                   | 2 vCPU, 1.8 GB memory          | n/a (ELB)      |                           |
| - Ref Arch total                                           | 10                  |                                |                |                           |
| AWS total                                                  | 9                   |                                |                | $2.73/hr                  |
|                                                            |                     |                                |                |                           |
| All Non-Git Storage Subsystems (but does include LFS)      |                     |                                |                |                           |
| - AWS S3                                                   | n/a                 | n/a                            | n/a            |                           |

### Gitaly SRE Considerations

Complete performance metrics should be collected for Gitaly instances for identification of bottlenecks - as they could have to do with disk IO, network IO or memory.

### Gitaly EBS Volume Sizing Guidelines

The Gitaly cluster is built to overcome fundamental challenges with horizontal scaling of the open source Git binaries.  As such, the storage is expected to be local (not NFS of any type including EFS).

Gitaly servers also need space for building and caching Git pack files.

Background:

* When not using provisioned EBS IO, EBS volume size determines the IO level - so volumes that are much larger than needed can be the least expensive way to improve EBS IO.
* Only use nitro instance types due to higher IO and EBS Optimization
* Use Amazon Linux 2 to ensure the best disk and memory optimizations (e.g. ENA network adapters and drivers)
* If GitLab backup scripts are used, they need a temporary space location large enough to hold 2 times the current size of the Git File system. If that will be done on Gitaly servers, seperate volumes should be used. 