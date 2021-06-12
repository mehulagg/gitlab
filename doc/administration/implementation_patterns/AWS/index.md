---
type: reference, concepts
stage: Enablement
group: Alliances
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#assignments

---

# AWS Specific Implementation patterns **(FREE SELF)**

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

## GitLab on AWS Compute


| GitLab Ref Arch                                              | GitLab Ref Arch Baseline Perf Test Results                   | AWS Build Manifest                                           | AWS Build Performance Testing Results                        | AWS Build Compute Cost Estimate                              | Existing Infrastructure as Code                              |
| ------------------------------------------------------------ | ------------------------------------------------------------ | ------------------------------------------------------------ | ------------------------------------------------------------ | ------------------------------------------------------------ | ------------------------------------------------------------ |
|                                                              |                                                              |                                                              |                                                              |                                                              |                                                              |
| [10K Cloud Native](../../reference_architectures/10k_users.md#cloud-native-hybrid-reference-architecture-with-helm-charts-alternative) | [10k Baseline (Instances)](https://gitlab.com/gitlab-org/quality/performance/-/wikis/Benchmarks/Latest/10k) | [10K Cloud Native on EKS](10k-cloud-native-on-eks-build-manifest) | [GPT Test Results](#10k-cloud-native-hybrid-on-eks-test-results) | [GitLab Cloud Native 10K - 1 YR Ec2 Compute Savings + 1 YR RDS & Elasticache RIs](https://calculator.aws/#/estimate?id=5ac2e07a22e01c36ee76b5477c5a046cd1bea792) | [AWS Quick Start](https://gitlab.com/gitlab-com/alliances/aws/sandbox-projects/eks-quickstart/eks-quickstart-docs-and-collab/-/wikis/GitLab-Team-Member-EKS-QuickStart-Testing-Instructions)<br /><br />[GitLab GET (No AWS PaaS Yet)](https://gitlab.com/gitlab-org/quality/gitlab-environment-toolkit) |
| [10K Omnibus on Instances](../../reference_architectures/10k_users.md) | [[10k Baseline (Instances)](https://gitlab.com/gitlab-org/quality/performance/-/wikis/Benchmarks/Latest/10k)](https://gitlab.com/gitlab-org/quality/performance/-/wikis/Benchmarks/Latest/10k) | 10K Omnibus on Ec2 with PaaS                                 | n/a                                                          | Coming soon                                                  | [GitLab GET (No AWS PaaS Yet)](https://gitlab.com/gitlab-org/quality/gitlab-environment-toolkit) |

### 10K Cloud Native on EKS Build Manifest

Note: On Demand pricing is used in this table for comparisons, but should not be used for budgeting nor purchasing AWS resources for a GitLab production instance.  It's equivalent to paying Manufacturer's Recommended Retail Price on personal purchases. Do not use these tables to calculate actual monthly or yearly price estimates, instead use the AWS Calculator links in the "GitLab on AWS Compute" table above.

| Service                                                   | Target Allocatable CPUs and Memory (Full Scaled) | Example Idling Cost <br />(min suggested nodes)<br />(On Demand, US East) | Example Full Scaled Cost<br />(On Demand, US East) |
| --------------------------------------------------------- | ------------------------------------------------ | ------------------------------------------------------------ | -------------------------------------------------- |
| Webservice                                                | 127.5 vCPU, 118 GB memory                        |                                                              |                                                    |
| Sidekiq                                                   | 15.5 vCPU, 50 GB memory                          |                                                              |                                                    |
| Supporting services such as NGINX, Prometheus, etc.       | 7.75 vCPU, 25 GB memory                          |                                                              |                                                    |
| **Ref Arch Total**                                        | **151 vCPU, 193 GB memory**                      |                                                              |                                                    |
|                                                           |                                                  |                                                              |                                                    |
| EKS Cluster (Control Plane)                               | n/a                                              | $0.10/hr                                                     | $0.10/hr                                           |
| AWS EKS Nodes Configuration 1:  c5.9xlarge (36 vcpu/72GB) | 180 vCPU, 360 GB memory                          | (? nodes)                                                    | (5 nodes) $7.65/hr<br />                           |
| EKS Nodes Configuration 2: c5.4xlarge (16vcpu/32GB)       | 160 vCPU, 320 GB memory                          | (? nodes)                                                    | (10 nodes)$6.80/hr<br />                           |


Note: AWS (and all cloud providers) support only specific ratios of VCPU and Memory.  GitLab's vCPU and memory requirements do not necessarily align cleanly with these ratios for any given provider.

Note: Picking more of a smaller size instance allows scaling costs to be more granular.

Note: AWS Scaling speed from Idling to Full Scale took x minutes under gpt 10k loading.

| Service                                                    | Advised <br />Nodes | Configuration                  | Total                        | Example Cost<br />US East       |
| ---------------------------------------------------------- | ------------------- | ------------------------------ | ---------------------------- | ------------------------------- |
|                                                            |                     |                                |                              |                                 |
| **AWS Aurora RDS PostgreSQL (GitLab Data)** which handles: |                     |                                |                              |                                 |
| - PostgreSQL(1)                                            | 3                   | 8 vCPU, 30 GB memory           | 24vCPU, 90 GB                | m5.2xlarge $0.38 x 3 = $1.14/hr |
| - PgBouncer(1)                                             | 3                   | 2 vCPU, 1.8 GB memory          | 6vCPU, 5.4 GB                | M5.xlarge: $0.19 x 3 = $0.57/hr |
| - Consul(1)                                                | 3                   | 2 vCPU, 1.8 GB memory          | 6vCPU, 5.4 GB                | Combined with PgBouncer         |
| - Ref Arch Total                                           | 9                   |                                | 36vCPU, 100 GB               | $1.73/hr (non-managed)          |
| Aurora RDS Nodes Configuration (GPT tested)                | 3                   | db.r5.2xlarge (8vCPU, 64 GB)   | 24vCPU, 192 GB               | $1.16 x 3 = $3.48/hr            |
|                                                            |                     |                                |                              |                                 |
| **AWS Elasticache Redis** which handles:                   |                     |                                |                              |                                 |
| - Redis - Cache(2)                                         | 3                   | 4 vCPU, 15 GB memory           | 12vCPU, 45GB                 | M5.xlarge: $0.19 x 3 = $0.57/hr |
| - Redis - Queues / Shared State(2)                         | 3                   | 4 vCPU, 15 GB memory           | 12vCPU, 45GB                 | M5.xlarge: $0.19 x 3 = $0.57/hr |
| - Redis Sentinel - Cache(2)                                | 3                   | 1 vCPU, 3.75 GB memory         | 3vCPU, 12GB                  | M5.xlarge: $0.19 x 3 = $0.57/hr |
| - Redis Sentinel - Queues / Shared State(2)                | 3                   | 1 vCPU, 3.75 GB memory         | 3vCPU, 12GB                  | Combined with Sentinel - Cache  |
| - Ref Arch Total                                           | 12                  |                                | 30vCPU, 114GB                | $1.71/hr (non-managed)          |
| Redis Elasticache Configuration (GPT Tested)               | 3                   | cache.m5.xlarge (4vCPU, 13 GB) | 12vCPU, 40GB                 | $0.31 x 3 = $0.93/hr            |
|                                                            |                     |                                |                              |                                 |
| **Gitaly Cluster (Git file system) on Instance Compute**   |                     |                                |                              |                                 |
| Gitaly (Instance in an ASG)                                | 3                   | 16 vCPU, 60 GB memory          | m5.4xlarge                   | $0.77 x 3 = $2.31/hr            |
| - EBS Volume size per Gitaly Node (Git file system)        |                     | See below.                     |                              |                                 |
| Praefect (Instances in ASG with load balancer)             | 3                   | 2 vCPU, 1.8 GB memory          | c5.large                     | $0.09 x 3 = $0.21/hr            |
| Praefect PostgreSQL(1) [AWS RDS]                           | 3                   | 2 vCPU, 1.8 GB memory          | c5.large                     | $0.09 x 3 = $0.21/hr            |
| Internal load balancing node(3) [ELB]                      | 1                   | 2 vCPU, 1.8 GB memory          | c5.large <br />(ELB for AWS) | $0.09 x 3 = $0.21/hr            |
| - Ref Arch total                                           | 10                  |                                |                              | $2.94/hr                        |
| AWS total                                                  | 9                   |                                |                              | $2.73/hr + $15/mon              |
|                                                            |                     |                                |                              |                                 |
| All Non-Git Storage Subsystems (but does include LFS)      |                     |                                |                              |                                 |
| - AWS S3                                                   | n/a                 | n/a                            | n/a                          |                                 |

### 10K Cloud Native Hybrid on EKS Test Results 

#### 10K Cloud Native Hybrid on 8 RDS vcpus

* Environment:                Eks-qsg-10k-8vcpu-postgresql
* Environment Version:        13.9.4-ee `fb7eeedfaf4`
* Option:                     60s_200rps
* Date:                       2021-04-15
* Run Time:                   1h 5m 50.82s (Start: 21:28:43 UTC, End: 22:34:34 UTC)
* GPT Version:                v2.7.0

❯ Overall Results Score: 98.73%

| NAME                                                     | RPS   | RPS RESULT           | TTFB AVG   | TTFB P90              | REQ STATUS     | RESULT  |
| -------------------------------------------------------- | ----- | -------------------- | ---------- | --------------------- | -------------- | ------- |
| api_v4_groups                                            | 200/s | 198.97/s (>160.00/s) | 60.84ms    | 63.88ms (<505ms)      | 100.00% (>99%) | Passed  |
| api_v4_groups_group                                      | 200/s | 86.71/s (>16.00/s)   | 2128.95ms  | 3146.19ms (<7505ms)   | 100.00% (>99%) | Passed  |
| api_v4_groups_group_subgroups                            | 200/s | 198.85/s (>160.00/s) | 65.87ms    | 69.18ms (<505ms)      | 100.00% (>99%) | Passed  |
| api_v4_groups_issues                                     | 200/s | 119.7/s (>48.00/s)   | 1519.32ms  | 1838.93ms (<3505ms)   | 100.00% (>99%) | Passed  |
| api_v4_groups_merge_requests                             | 200/s | 136.84/s (>48.00/s)  | 1315.44ms  | 1585.82ms (<3505ms)   | 100.00% (>99%) | Passed  |
| api_v4_groups_projects                                   | 200/s | 91.76/s (>80.00/s)   | 2008.29ms  | 2972.83ms (<3505ms)   | 100.00% (>99%) | Passed  |
| api_v4_projects                                          | 200/s | 47.65/s (>24.00/s)   | 3882.41ms  | 5200.23ms (<7005ms)   | 100.00% (>99%) | Passed  |
| api_v4_projects_deploy_keys                              | 200/s | 198.75/s (>160.00/s) | 33.61ms    | 37.32ms (<505ms)      | 100.00% (>99%) | Passed  |
| api_v4_projects_issues                                   | 200/s | 197.26/s (>96.00/s)  | 163.79ms   | 196.12ms (<2005ms)    | 100.00% (>99%) | Passed  |
| api_v4_projects_issues_issue                             | 200/s | 196.47/s (>160.00/s) | 138.94ms   | 172.41ms (<1505ms)    | 100.00% (>99%) | Passed  |
| api_v4_projects_issues_search                            | 200/s | 17.71/s (>24.00/s)   | 10400.61ms | 14778.65ms (<12005ms) | 100.00% (>99%) | FAILED² |
| api_v4_projects_languages                                | 200/s | 199.54/s (>160.00/s) | 27.82ms    | 31.30ms (<505ms)      | 100.00% (>99%) | Passed  |
| api_v4_projects_merge_requests                           | 200/s | 197.74/s (>96.00/s)  | 138.48ms   | 162.86ms (<705ms)     | 100.00% (>99%) | Passed  |
| api_v4_projects_merge_requests_merge_request             | 200/s | 198.69/s (>160.00/s) | 69.54ms    | 76.37ms (<505ms)      | 100.00% (>99%) | Passed  |
| api_v4_projects_merge_requests_merge_request_changes     | 200/s | 193.05/s (>32.00/s)  | 571.32ms   | 1000.66ms (<9005ms)   | 100.00% (>99%) | Passed  |
| api_v4_projects_merge_requests_merge_request_commits     | 200/s | 198.22/s (>160.00/s) | 45.59ms    | 51.25ms (<505ms)      | 100.00% (>99%) | Passed  |
| api_v4_projects_merge_requests_merge_request_discussions | 200/s | 196.54/s (>160.00/s) | 126.87ms   | 162.06ms (<505ms)     | 100.00% (>99%) | Passed  |
| api_v4_projects_project                                  | 200/s | 198.62/s (>160.00/s) | 83.84ms    | 90.55ms (<505ms)      | 100.00% (>99%) | Passed  |
| api_v4_projects_project_pipelines                        | 200/s | 199.41/s (>160.00/s) | 36.72ms    | 40.61ms (<505ms)      | 100.00% (>99%) | Passed  |
| api_v4_projects_project_pipelines_pipeline               | 200/s | 199.1/s (>160.00/s)  | 44.81ms    | 47.99ms (<505ms)      | 100.00% (>99%) | Passed  |
| api_v4_projects_project_services                         | 200/s | 199.43/s (>160.00/s) | 31.76ms    | 35.18ms (<505ms)      | 100.00% (>99%) | Passed  |
| api_v4_projects_releases                                 | 200/s | 90.32/s (>64.00/s)   | 2028.17ms  | 3002.23ms (<4005ms)   | 100.00% (>99%) | Passed  |
| api_v4_projects_repository_branches                      | 200/s | 198.67/s (>160.00/s) | 71.12ms    | 74.97ms (<505ms)      | 100.00% (>99%) | Passed  |
| api_v4_projects_repository_branches_branch               | 200/s | 199.09/s (>160.00/s) | 55.32ms    | 59.09ms (<505ms)      | 100.00% (>99%) | Passed  |
| api_v4_projects_repository_branches_search               | 200/s | 189.96/s (>48.00/s)  | 856.62ms   | 1190.59ms (<6005ms)   | 100.00% (>99%) | Passed  |
| api_v4_projects_repository_commits                       | 200/s | 199.26/s (>160.00/s) | 46.58ms    | 49.35ms (<505ms)      | 100.00% (>99%) | Passed  |
| api_v4_projects_repository_commits_commit                | 200/s | 198.36/s (>160.00/s) | 85.87ms    | 94.52ms (<505ms)      | 100.00% (>99%) | Passed  |
| api_v4_projects_repository_commits_commit_diff           | 200/s | 198.51/s (>160.00/s) | 86.84ms    | 94.86ms (<505ms)      | 100.00% (>99%) | Passed  |
| api_v4_projects_repository_compare_commits               | 200/s | 197.76/s (>112.00/s) | 130.83ms   | 147.42ms (<3005ms)    | 100.00% (>99%) | Passed  |
| api_v4_projects_repository_files_file                    | 200/s | 197.73/s (>160.00/s) | 65.31ms    | 66.89ms (<505ms)      | 100.00% (>99%) | Passed  |
| api_v4_projects_repository_files_file_blame              | 200/s | 31.0/s (>1.60/s)     | 5897.61ms  | 8374.17ms (<35005ms)  | 100.00% (>99%) | Passed  |
| api_v4_projects_repository_files_file_raw                | 200/s | 198.93/s (>160.00/s) | 60.02ms    | 63.93ms (<505ms)      | 100.00% (>99%) | Passed  |
| api_v4_projects_repository_tags                          | 200/s | 194.58/s (>32.00/s)  | 436.73ms   | 547.75ms (<10005ms)   | 100.00% (>99%) | Passed  |
| api_v4_projects_repository_tree                          | 200/s | 199.13/s (>160.00/s) | 57.71ms    | 60.59ms (<505ms)      | 100.00% (>99%) | Passed  |
| api_v4_user                                              | 200/s | 199.41/s (>160.00/s) | 29.80ms    | 32.67ms (<505ms)      | 100.00% (>99%) | Passed  |
| api_v4_users                                             | 200/s | 199.23/s (>160.00/s) | 44.34ms    | 48.00ms (<505ms)      | 100.00% (>99%) | Passed  |
| git_ls_remote                                            | 20/s  | 19.97/s (>16.00/s)   | 39.29ms    | 42.55ms (<505ms)      | 100.00% (>99%) | Passed  |
| git_pull                                                 | 20/s  | 19.94/s (>16.00/s)   | 49.69ms    | 63.48ms (<505ms)      | 100.00% (>99%) | Passed  |
| git_push                                                 | 4/s   | 3.68/s (>3.20/s)     | 316.56ms   | 460.18ms (<1005ms)    | 100.00% (>99%) | Passed  |
| web_group                                                | 20/s  | 19.91/s (>16.00/s)   | 90.76ms    | 108.97ms (<505ms)     | 100.00% (>99%) | Passed  |
| web_group_issues                                         | 20/s  | 19.7/s (>16.00/s)    | 208.88ms   | 222.69ms (<505ms)     | 100.00% (>99%) | Passed  |
| web_group_merge_requests                                 | 20/s  | 19.61/s (>16.00/s)   | 230.29ms   | 246.90ms (<505ms)     | 100.00% (>99%) | Passed  |
| web_project                                              | 20/s  | 19.7/s (>16.00/s)    | 187.71ms   | 205.37ms (<505ms)     | 100.00% (>99%) | Passed  |
| web_project_branches                                     | 20/s  | 19.4/s (>16.00/s)    | 350.29ms   | 398.42ms (<805ms)     | 100.00% (>99%) | Passed  |
| web_project_branches_search                              | 20/s  | 19.13/s (>16.00/s)   | 454.53ms   | 502.07ms (<1305ms)    | 100.00% (>99%) | Passed  |
| web_project_commit                                       | 20/s  | 7.1/s (>3.20/s)      | 2283.05ms  | 6695.42ms (<10005ms)  | 100.00% (>99%) | Passed  |
| web_project_commits                                      | 20/s  | 19.41/s (>16.00/s)   | 357.99ms   | 395.43ms (<755ms)     | 100.00% (>99%) | Passed  |
| web_project_file_blame                                   | 20/s  | 7.19/s (>0.16/s)     | 2429.86ms  | 2997.76ms (<7005ms)   | 100.00% (>99%) | Passed  |
| web_project_file_rendered                                | 20/s  | 18.58/s (>9.60/s)    | 790.77ms   | 1786.92ms (<3005ms)   | 100.00% (>99%) | Passed  |
| web_project_file_source                                  | 20/s  | 18.8/s (>1.60/s)     | 781.10ms   | 1694.33ms (<5005ms)   | 100.00% (>99%) | Passed  |
| web_project_files                                        | 20/s  | 19.79/s (>16.00/s)   | 143.34ms   | 162.31ms (<505ms)     | 100.00% (>99%) | Passed  |
| web_project_issue                                        | 20/s  | 19.73/s (>16.00/s)   | 238.25ms   | 734.09ms (<2005ms)    | 100.00% (>99%) | Passed  |
| web_project_issues                                       | 20/s  | 19.59/s (>16.00/s)   | 207.74ms   | 228.62ms (<505ms)     | 100.00% (>99%) | Passed  |
| web_project_issues_search                                | 20/s  | 19.64/s (>16.00/s)   | 204.41ms   | 230.81ms (<505ms)     | 100.00% (>99%) | Passed  |
| web_project_merge_request_changes                        | 20/s  | 19.75/s (>8.00/s)    | 274.71ms   | 344.93ms (<4005ms)    | 100.00% (>99%) | Passed  |
| web_project_merge_request_commits                        | 20/s  | 19.47/s (>9.60/s)    | 360.13ms   | 500.85ms (<1505ms)    | 100.00% (>99%) | Passed  |
| web_project_merge_request_discussions                    | 20/s  | 18.61/s (>11.20/s)   | 794.76ms   | 2080.27ms (<5005ms)   | 100.00% (>99%) | Passed  |
| web_project_merge_requests                               | 20/s  | 19.55/s (>16.00/s)   | 242.81ms   | 274.19ms (<505ms)     | 100.00% (>99%) | Passed  |
| web_project_pipelines                                    | 20/s  | 19.63/s (>9.60/s)    | 281.70ms   | 456.07ms (<1005ms)    | 100.00% (>99%) | Passed  |
| web_project_pipelines_pipeline                           | 20/s  | 19.75/s (>16.00/s)   | 350.94ms   | 715.84ms (<2505ms)    | 100.00% (>99%) | Passed  |
| web_project_tags                                         | 20/s  | 19.1/s (>12.80/s)    | 458.90ms   | 500.56ms (<1505ms)    | 100.00% (>99%) | Passed  |
| web_user                                                 | 20/s  | 19.97/s (>9.60/s)    | 53.08ms    | 71.89ms (<4005ms)     | 100.00% (>99%) | Passed  |

² Failure may not be clear from summary alone. Refer to the individual test's full output for further debugging.
