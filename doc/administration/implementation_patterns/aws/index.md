---
type: reference, concepts
stage: Enablement
group: Alliances
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#assignments

---

# AWS Specific Implementation patterns **(FREE SELF)**

## GitLab Services and additional Services Handled by AWS PaaS

For both Omnibus GitLab or Cloud Native Hybrid implementations, the following GitLab Service roles can be performed by AWS Services (PaaS).

These services have been tested with GitLab.

Some services, such as log aggregation are not specified by GitLab - but where provided are noted.

| GitLab Services                                              | AWS PaaS (Tested)              | Provided by AWS Cloud <br />Native Hybrid Quick Start        |
| ------------------------------------------------------------ | ------------------------------ | ------------------------------------------------------------ |
| <u>Tested PaaS Mentioned in Reference Architectures</u>      |                                |                                                              |
| **PostgreSQL Database**                                      | Aurora RDS                     | Yes.                                                         |
| **Redis Caching**                                            | Redis Elasticache              | Yes.                                                         |
| **Gitaly Cluster (Git Repository Storage)**<br />(Including Praefect and PostgreSQL) | ASG and Instances              | Yes - ASG and Instances<br />**Note: Gitaly cannot be put into a Kubernetes Cluster.** |
| **All GitLab storages besides Git Repository Storage**<br />(Includes Git-LFS which is S3 Compatible) | AWS S3                         | Yes                                                          |
|                                                              |                                |                                                              |
| <u>Tested PaaS Not Referenced in Ref Archs</u>               |                                |                                                              |
| **Front End Load Balancing**                                 | AWS ELB                        | Yes                                                          |
| **Internal Load Balancing**                                  | AWS ELB                        | Yes                                                          |
| **Outbound Email Services**                                  | AWS Simple Email Service (SES) | Yes                                                          |
| **Certificate Authority and Management**                     | AWS Certificate Manager (ACM)  | Yes                                                          |
| **DNS**                                                      | AWS Route53 (tested)           | Yes                                                          |
| **GItLab and Infrastructure Log Aggregation**                | AWS CloudWatch Logs            | Yes (ContainerInsights Agent for EKS)                        |
| **Infrastructure Performance Metrics**                       | AWS CloudWatch Metrics         | Yes                                                          |
|                                                              |                                |                                                              |
| <u>Additional Tested Services and Configurations</u>         |                                |                                                              |
| **Prometheus for GitLab**                                    | AWS EKS (Cloud Native Only)    | Yes                                                          |
| **Grafana for GitLab**                                       | AWS EKS (Cloud Native Only)    | Yes                                                          |
| **Administrative Access to GitLab Backend**                  | Bastion Host in VPC            | Yes - HA - Preconfigured for Cluster Management.             |
| **Encryption (In Transit / At Rest)**                        | AWS KMS                        | Yes                                                          |
| **Secrets Storage for Provisioning**                         | AWS Secrets Manager            | Yes                                                          |
| **Configuration Data for Provisioning**                      | AWS Parameter Store            | Yes                                                          |
| **AutoScaling Kubernetes**                                   | EKS AutoScaling Agent          | Yes                                                          |
|                                                              |                                |                                                              |

## GitLab Cloud Native Hybrid on AWS EKS

| Size | GitLab Ref Arch                                              | GitLab Ref Arch Baseline Perf Test Results                   | AWS Build Manifest                                           | AWS Build Performance Testing Results                        | AWS Build Compute Cost Estimate                              | Existing Infrastructure as Code                              |
| ---- | ------------------------------------------------------------ | ------------------------------------------------------------ | ------------------------------------------------------------ | ------------------------------------------------------------ | ------------------------------------------------------------ | ------------------------------------------------------------ |
| 3K   | [3K Omnibus](../../reference_architectures/3k_users.md)      | [3k Baseline (Instances)](https://gitlab.com/gitlab-org/quality/performance/-/wikis/Benchmarks/Latest/3k) | [10K Cloud Native on EKS](#10k-cloud-native-on-eks-build-manifest) | [GPT Test Results](#10k-cloud-native-hybrid-on-eks-test-results) | [GitLab Cloud Native 10K - 1 YR Ec2 Compute Savings + 1 YR RDS & Elasticache RIs](https://calculator.aws/#/estimate?id=5ac2e07a22e01c36ee76b5477c5a046cd1bea792) | [AWS Quick Start](https://gitlab.com/gitlab-com/alliances/aws/sandbox-projects/eks-quickstart/eks-quickstart-docs-and-collab/-/wikis/GitLab-Team-Member-EKS-QuickStart-Testing-Instructions)<br /><br />[GitLab GET (No AWS PaaS Yet)](https://gitlab.com/gitlab-org/quality/gitlab-environment-toolkit) |
| 5K   | [5K Omnibus](../../reference_architectures/5k_users.md)      | [5k Baseline (Instances)](https://gitlab.com/gitlab-org/quality/performance/-/wikis/Benchmarks/Latest/5k) | [5K Cloud Native on EKS](#10k-cloud-native-on-eks-build-manifest) | [GPT Test Results](#10k-cloud-native-hybrid-on-eks-test-results) | [GitLab Cloud Native 10K - 1 YR Ec2 Compute Savings + 1 YR RDS & Elasticache RIs](https://calculator.aws/#/estimate?id=5ac2e07a22e01c36ee76b5477c5a046cd1bea792) | [AWS Quick Start](https://gitlab.com/gitlab-com/alliances/aws/sandbox-projects/eks-quickstart/eks-quickstart-docs-and-collab/-/wikis/GitLab-Team-Member-EKS-QuickStart-Testing-Instructions)<br /><br />[GitLab GET (No AWS PaaS Yet)](https://gitlab.com/gitlab-org/quality/gitlab-environment-toolkit) |
| 10K  | [10K Cloud Native](../../reference_architectures/10k_users.md#cloud-native-hybrid-reference-architecture-with-helm-charts-alternative) | [10k Baseline (Instances)](https://gitlab.com/gitlab-org/quality/performance/-/wikis/Benchmarks/Latest/10k) | [10K Cloud Native on EKS](#10k-cloud-native-on-eks-build-manifest) | [GPT Test Results](#10k-cloud-native-hybrid-on-eks-test-results) | [GitLab Cloud Native 10K - 1 YR Ec2 Compute Savings + 1 YR RDS & Elasticache RIs](https://calculator.aws/#/estimate?id=5ac2e07a22e01c36ee76b5477c5a046cd1bea792) | [AWS Quick Start](https://gitlab.com/gitlab-com/alliances/aws/sandbox-projects/eks-quickstart/eks-quickstart-docs-and-collab/-/wikis/GitLab-Team-Member-EKS-QuickStart-Testing-Instructions)<br /><br />[GitLab GET (No AWS PaaS Yet)](https://gitlab.com/gitlab-org/quality/gitlab-environment-toolkit) |
| 25K  |                                                              |                                                              |                                                              |                                                              |                                                              |                                                              |
| 50K  |                                                              |                                                              |                                                              |                                                              |                                                              |                                                              |

### 10K Cloud Native on EKS Build Manifest

NOTE:
On Demand pricing is used in this table for comparisons, but should not be used for budgeting nor purchasing AWS resources for a GitLab production instance. It's equivalent to paying Manufacturer's Recommended Retail Price on personal purchases. Do not use these tables to calculate actual monthly or yearly price estimates, instead use the AWS Calculator links in the "GitLab on AWS Compute" table above and customize it with your desired savings plan.

**BOM Total:** = Bill of Materials Total - this is what you use when building this configuration

**Ref Arch Raw Total:** = The totals if the configuration was built on regular VMs with no PaaS services. Configuring on pure VMs generally requires additional VMs for cluster management activities.

| Service                                                   | Target Allocatable CPUs and Memory (Full Scaled) | Example Idling Cost <br />(min suggested nodes)<br />(On Demand, US East) | Example Full Scaled Cost<br />(On Demand, US East) |
| --------------------------------------------------------- | ------------------------------------------------ | ------------------------------------------------------------ | -------------------------------------------------- |
| Webservice                                                | 127.5 vCPU, 118 GB memory                        |                                                              |                                                    |
| Sidekiq                                                   | 15.5 vCPU, 50 GB memory                          |                                                              |                                                    |
| Supporting services such as NGINX, Prometheus, etc        | 7.75 vCPU, 25 GB memory                          |                                                              |                                                    |
| **Ref Arch Total**                                        | **151 vCPU, 193 GB memory**                      |                                                              |                                                    |
|                                                           |                                                  |                                                              |                                                    |
| EKS Cluster (Control Plane)                               | n/a                                              | $0.10/hr                                                     | $0.10/hr                                                   |
| **BOM Total:** EKS Nodes c5.4xlarge (16vcpu/32GB)  | 160 vCPU, 320 GB memory                          | (5 nodes) $3.40/hr                                           | (10 nodes) $6.80/hr<br />                                                    |

NOTE:
Picking more of a smaller size instance allows scaling costs to be more granular.

**BOM Total:** = Bill of Materials Total - this is what you use when building this configuration

**Ref Arch Raw Total:** = The totals if the configuration was built on regular VMs with no PaaS services. Configuring on pure VMs generally requires additional VMs for cluster management activities.

| PostgreSQL Service                                           | Advised <br />Nodes | Configuration                  | Total                        | Example Cost<br />US East       |
| ------------------------------------------------------------ | ------------------- | ------------------------------ | ---------------------------- | ------------------------------- |
|                                                              |                     |                                |                              |                                 |
| **PostgreSQL (GitLab Data)**                                 |                     |                                |                              |                                 |
| **BOM Total:** AWS Aurora RDS Nodes Configuration (GPT tested)   | 3                   | db.r6g.2xlarge (8vCPU, 64 GB, ARM)   | 24vCPU, 192 GB               | $1.04 x 3 = $3.12/hr            |
| **Ref Arch Raw Total:** VM Specification on AWS: | 9                   |                                | 36vCPU, 100 GB               | $1.73/hr (non-managed)          |

<details>
<summary>Click to Expand and See Which GitLab Services are Handled by AWS Aurora PostgreSQL PaaS</summary>

| GitLab Services Handled by PostgreSQL PaaS                   | Advised <br />Nodes | Configuration                  | Total                        | Example Cost<br />US East       |
| ------------------------------------------------------------ | ------------------- | ------------------------------ | ---------------------------- | ------------------------------- |
|                                                              |                     |                                |                              |                                 |
| - PostgreSQL(1)                                              | 3                   | 8 vCPU, 30 GB memory           | 24vCPU, 90 GB                | m5.2xlarge $0.38 x 3 = $1.14/hr |
| - PgBouncer(1)                                               | 3                   | 2 vCPU, 1.8 GB memory          | 6vCPU, 5.4 GB                | M5.xlarge: $0.19 x 3 = $0.57/hr |
| - Consul(1)                                                  | 3                   | 2 vCPU, 1.8 GB memory          | 6vCPU, 5.4 GB                | Combined with PgBouncer         |
|                                                              |                     |                                |                              |                                 |

</details>

| Redis Service                                                | Advised <br />Nodes | Configuration                  | Total                        | Example Cost<br />US East       |
| ------------------------------------------------------------ | ------------------- | ------------------------------ | ---------------------------- | ------------------------------- |
|                                                              |                     |                                |                              |                                 |
| **Redis**                                                    |                     |                                |                              |                                 |
| **BOM Total:** AWS Redis Elasticache Configuration (GPT Tested)  | 3                   | cache.m5.2xlarge (8vCPU, 26 GB) | 24vCPU, 78GB                 | $0.62 x 3 = $1.86/hr            |
| **Ref Arch Raw Total:** Reference Architecture VM Specification on AWS, consisting of (add up below rows): | 12                  |                                | 30vCPU, 114GB                | $1.71/hr (non-managed)          |
|                                                              |                     |                                |                              |                                 |

<details>
<summary>Click to Expand and See Which GitLab Services are Handled by AWS Redis Elasticache PaaS</summary>

| GitLab Services Handled by Redis PaaS                        | Advised <br />Nodes | Configuration                  | Total                        | Example Cost<br />US East       |
| ------------------------------------------------------------ | ------------------- | ------------------------------ | ---------------------------- | ------------------------------- |
|                                                              |                     |                                |                              |                                 |
| - Redis - Cache(2)                                           | 3                   | 4 vCPU, 15 GB memory           | 12vCPU, 45GB                 | M5.xlarge: $0.19 x 3 = $0.57/hr |
| - Redis - Queues / Shared State(2)                           | 3                   | 4 vCPU, 15 GB memory           | 12vCPU, 45GB                 | M5.xlarge: $0.19 x 3 = $0.57/hr |
| - Redis Sentinel - Cache(2)                                  | 3                   | 1 vCPU, 3.75 GB memory         | 3vCPU, 12GB                  | M5.xlarge: $0.19 x 3 = $0.57/hr |
| - Redis Sentinel - Queues / Shared State(2)                  | 3                   | 1 vCPU, 3.75 GB memory         | 3vCPU, 12GB                  | Combined with Sentinel - Cache  |
|                                                              |                     |                                |                              |                                 |

</details>

| Gitaly Service (No PaaS Equivalent)                      | Advised <br />Nodes | Configuration         | Total                        | Example Cost<br />US East |
| -------------------------------------------------------- | ------------------- | --------------------- | ---------------------------- | ------------------------- |
|                                                          |                     |                       |                              |                           |
| **Gitaly Cluster (Git file system) on Instance Compute** |                     |                       |                              |                           |
| **BOM total**                                            | 9                   |                       |                              | $2.73/hr + $15/mon        |
| **Ref Arch raw total**, consisting of:                   | 10                  |                       |                              | $2.94/hr                  |
| Gitaly (Instance in an ASG)                              | 3                   | 16 vCPU, 60 GB memory | m5.4xlarge                   | $0.77 x 3 = $2.31/hr      |
| Praefect (Instances in ASG with load balancer)           | 3                   | 2 vCPU, 1.8 GB memory | c5.large                     | $0.09 x 3 = $0.21/hr      |
| Praefect PostgreSQL(1) [AWS RDS]                         | 3                   | 2 vCPU, 1.8 GB memory | c5.large                     | $0.09 x 3 = $0.21/hr      |
| Internal load balancing node(3) [ELB]                    | 1                   | 2 vCPU, 1.8 GB memory | c5.large <br />(ELB for AWS) | $0.09 x 3 = $0.21/hr      |

### 10K Cloud Native Hybrid on EKS Test Results 

<details>
<summary>Click to Expand and See 10K Cloud Native Hybrid on EKS Test Results </summary>

Attribute                  | Value                                                   
---------------------------|---------------------------------------------------------
Environment:               | Gl-cloudnative-10k-rds-graviton                         
Environment Version:       | 13.12.3-ee `9d9769ba2ad`                                
Option:                    | 60s_200rps                                              
Date:                      | 2021-07-08                                              
Run Time:                  | 1h 6m 21.52s (Start: 19:46:47 UTC, End: 20:53:09 UTC)   
GPT Version:               | v2.8.0                                                  

❯ Overall Results Score: 97.8%

NAME                                                     | RPS   | RPS RESULT           | TTFB AVG  | TTFB P90             | REQ STATUS     | RESULT         
---------------------------------------------------------|-------|----------------------|-----------|----------------------|----------------|----------------
api_v4_groups                                            | 200/s | 198.4/s (>160.00/s)  | 63.16ms   | 71.27ms (<505ms)     | 100.00% (>99%) | Passed
api_v4_groups_group                                      | 200/s | 191.12/s (>16.00/s)  | 402.56ms  | 631.65ms (<7505ms)   | 100.00% (>99%) | Passed
api_v4_groups_group_subgroups                            | 200/s | 198.73/s (>160.00/s) | 68.55ms   | 78.02ms (<505ms)     | 100.00% (>99%) | Passed
api_v4_groups_issues                                     | 200/s | 168.35/s (>48.00/s)  | 1043.17ms | 1426.39ms (<3505ms)  | 100.00% (>99%) | Passed
api_v4_groups_merge_requests                             | 200/s | 184.16/s (>48.00/s)  | 924.09ms  | 1274.29ms (<3505ms)  | 100.00% (>99%) | Passed
api_v4_groups_projects                                   | 200/s | 194.69/s (>80.00/s)  | 354.43ms  | 653.75ms (<3505ms)   | 100.00% (>99%) | Passed
api_v4_projects                                          | 200/s | 130.02/s (>24.00/s)  | 1382.47ms | 2351.01ms (<7005ms)  | 100.00% (>99%) | Passed
api_v4_projects_deploy_keys                              | 200/s | 199.16/s (>160.00/s) | 33.86ms   | 41.02ms (<505ms)     | 100.00% (>99%) | Passed
api_v4_projects_issues                                   | 200/s | 197.52/s (>160.00/s) | 137.49ms  | 170.00ms (<505ms)    | 100.00% (>99%) | Passed
api_v4_projects_issues_issue                             | 200/s | 195.77/s (>160.00/s) | 149.08ms  | 185.99ms (<1505ms)   | 100.00% (>99%) | Passed
api_v4_projects_issues_search                            | 200/s | 95.32/s (>24.00/s)   | 1940.84ms | 4214.80ms (<12005ms) | 100.00% (>99%) | Passed
api_v4_projects_languages                                | 200/s | 199.39/s (>160.00/s) | 27.76ms   | 32.57ms (<505ms)     | 100.00% (>99%) | Passed
api_v4_projects_merge_requests                           | 200/s | 197.69/s (>96.00/s)  | 139.11ms  | 186.07ms (<1005ms)   | 100.00% (>99%) | Passed
api_v4_projects_merge_requests_merge_request             | 200/s | 195.48/s (>80.00/s)  | 175.35ms  | 219.69ms (<2755ms)   | 100.00% (>99%) | Passed
api_v4_projects_merge_requests_merge_request_changes     | 200/s | 194.01/s (>80.00/s)  | 434.69ms  | 863.59ms (<3505ms)   | 99.94% (>99%)  | Passed
api_v4_projects_merge_requests_merge_request_commits     | 200/s | 198.19/s (>160.00/s) | 46.40ms   | 53.35ms (<505ms)     | 100.00% (>99%) | Passed
api_v4_projects_merge_requests_merge_request_discussions | 200/s | 197.45/s (>160.00/s) | 114.58ms  | 142.03ms (<505ms)    | 100.00% (>99%) | Passed
api_v4_projects_project                                  | 200/s | 198.44/s (>160.00/s) | 82.62ms   | 100.32ms (<505ms)    | 100.00% (>99%) | Passed
api_v4_projects_project_pipelines                        | 200/s | 199.29/s (>160.00/s) | 36.06ms   | 43.54ms (<505ms)     | 100.00% (>99%) | Passed
api_v4_projects_project_pipelines_pipeline               | 200/s | 198.56/s (>160.00/s) | 45.89ms   | 52.70ms (<505ms)     | 100.00% (>99%) | Passed
api_v4_projects_project_services                         | 200/s | 199.44/s (>160.00/s) | 31.64ms   | 37.81ms (<505ms)     | 100.00% (>99%) | Passed
api_v4_projects_releases                                 | 200/s | 198.75/s (>160.00/s) | 49.97ms   | 59.27ms (<505ms)     | 100.00% (>99%) | Passed
api_v4_projects_repository_branches                      | 200/s | 198.7/s (>160.00/s)  | 28.97ms   | 32.96ms (<505ms)     | 100.00% (>99%) | Passed
api_v4_projects_repository_branches_branch               | 200/s | 199.15/s (>160.00/s) | 56.23ms   | 66.18ms (<505ms)     | 100.00% (>99%) | Passed
api_v4_projects_repository_branches_search               | 200/s | 198.99/s (>48.00/s)  | 28.37ms   | 33.01ms (<6005ms)    | 100.00% (>99%) | Passed
api_v4_projects_repository_commits                       | 200/s | 199.19/s (>160.00/s) | 44.84ms   | 52.58ms (<505ms)     | 100.00% (>99%) | Passed
api_v4_projects_repository_commits_commit                | 200/s | 198.55/s (>160.00/s) | 81.71ms   | 91.28ms (<505ms)     | 100.00% (>99%) | Passed
api_v4_projects_repository_commits_commit_diff           | 200/s | 196.91/s (>160.00/s) | 84.72ms   | 94.13ms (<505ms)     | 100.00% (>99%) | Passed
api_v4_projects_repository_compare                       | 200/s | 92.62/s (>16.00/s)   | 1989.65ms | 2591.02ms (<8005ms)  | 100.00% (>99%) | Passed
api_v4_projects_repository_files_file                    | 200/s | 197.41/s (>160.00/s) | 65.43ms   | 69.73ms (<505ms)     | 100.00% (>99%) | Passed
api_v4_projects_repository_files_file_blame              | 200/s | 30.91/s (>1.60/s)    | 5892.32ms | 8421.20ms (<35005ms) | 100.00% (>99%) | Passed
api_v4_projects_repository_files_file_raw                | 200/s | 199.0/s (>160.00/s)  | 58.01ms   | 64.59ms (<505ms)     | 100.00% (>99%) | Passed
api_v4_projects_repository_tags                          | 200/s | 194.49/s (>32.00/s)  | 426.43ms  | 528.18ms (<10005ms)  | 100.00% (>99%) | Passed
api_v4_projects_repository_tree                          | 200/s | 199.08/s (>160.00/s) | 55.68ms   | 61.37ms (<505ms)     | 100.00% (>99%) | Passed
api_v4_user                                              | 200/s | 199.42/s (>160.00/s) | 27.95ms   | 34.17ms (<505ms)     | 100.00% (>99%) | Passed
api_v4_users                                             | 200/s | 199.3/s (>160.00/s)  | 33.75ms   | 41.10ms (<505ms)     | 100.00% (>99%) | Passed
git_ls_remote                                            | 20/s  | 19.98/s (>16.00/s)   | 35.92ms   | 37.11ms (<505ms)     | 100.00% (>99%) | Passed
git_pull                                                 | 20/s  | 19.92/s (>16.00/s)   | 44.92ms   | 55.62ms (<505ms)     | 100.00% (>99%) | Passed
git_push                                                 | 4/s   | 2.6/s (>3.20/s)      | 276.71ms  | 402.76ms (<1005ms)   | 100.00% (>99%) | Passed
web_group                                                | 20/s  | 19.89/s (>16.00/s)   | 117.21ms  | 136.17ms (<505ms)    | 100.00% (>99%) | Passed
web_group_issues                                         | 20/s  | 19.45/s (>16.00/s)   | 209.49ms  | 247.72ms (<505ms)    | 100.00% (>99%) | Passed
web_group_merge_requests                                 | 20/s  | 19.65/s (>16.00/s)   | 197.18ms  | 237.94ms (<505ms)    | 100.00% (>99%) | Passed
web_project                                              | 20/s  | 19.62/s (>16.00/s)   | 206.90ms  | 249.75ms (<505ms)    | 100.00% (>99%) | Passed
web_project_branches                                     | 20/s  | 19.12/s (>16.00/s)   | 455.03ms  | 516.96ms (<1005ms)   | 100.00% (>99%) | Passed
web_project_branches_search                              | 20/s  | 18.98/s (>16.00/s)   | 516.49ms  | 568.41ms (<1305ms)   | 100.00% (>99%) | Passed
web_project_commit                                       | 20/s  | 18.72/s (>3.20/s)    | 567.05ms  | 1612.51ms (<10005ms) | 100.00% (>99%) | Passed
web_project_commits                                      | 20/s  | 19.08/s (>16.00/s)   | 367.06ms  | 414.31ms (<755ms)    | 100.00% (>99%) | Passed
web_project_file_blame                                   | 20/s  | 6.88/s (>0.16/s)     | 2512.66ms | 2646.86ms (<7005ms)  | 100.00% (>99%) | Passed
web_project_file_rendered                                | 20/s  | 16.8/s (>9.60/s)     | 623.45ms  | 664.76ms (<3005ms)   | 100.00% (>99%) | Passed
web_project_file_source                                  | 20/s  | 19.37/s (>1.60/s)    | 550.26ms  | 784.89ms (<1705ms)   | 100.00% (>99%) | Passed
web_project_files                                        | 20/s  | 19.46/s (>16.00/s)   | 130.16ms  | 161.80ms (<805ms)    | 100.00% (>99%) | Passed
web_project_issue                                        | 20/s  | 19.73/s (>16.00/s)   | 225.70ms  | 627.74ms (<2005ms)   | 100.00% (>99%) | Passed
web_project_issues                                       | 20/s  | 19.6/s (>16.00/s)    | 221.94ms  | 253.55ms (<505ms)    | 100.00% (>99%) | Passed
web_project_issues_search                                | 20/s  | 19.59/s (>16.00/s)   | 209.41ms  | 238.14ms (<505ms)    | 100.00% (>99%) | Passed
web_project_merge_request                                | 20/s  | 18.56/s (>6.40/s)    | 829.90ms  | 3430.20ms (<7505ms)  | 100.00% (>99%) | Passed
web_project_merge_request_changes                        | 20/s  | 19.44/s (>16.00/s)   | 314.20ms  | 543.95ms (<1505ms)   | 100.00% (>99%) | Passed
web_project_merge_request_commits                        | 20/s  | 18.76/s (>9.60/s)    | 574.86ms  | 793.63ms (<1755ms)   | 100.00% (>99%) | Passed
web_project_merge_requests                               | 20/s  | 19.62/s (>16.00/s)   | 218.49ms  | 260.09ms (<505ms)    | 100.00% (>99%) | Passed
web_project_pipelines                                    | 20/s  | 19.63/s (>9.60/s)    | 247.61ms  | 381.93ms (<1005ms)   | 100.00% (>99%) | Passed
web_project_pipelines_pipeline                           | 20/s  | 19.69/s (>16.00/s)   | 418.44ms  | 936.26ms (<2505ms)   | 100.00% (>99%) | Passed
web_project_repository_compare                           | 20/s  | 4.73/s (>0.80/s)     | 3808.79ms | 4296.01ms (<7505ms)  | 100.00% (>99%) | Passed
web_project_tags                                         | 20/s  | 19.02/s (>12.80/s)   | 514.64ms  | 576.85ms (<1505ms)   | 100.00% (>99%) | Passed
web_user                                                 | 20/s  | 19.85/s (>9.60/s)    | 148.58ms  | 230.68ms (<4005ms)   | 100.00% (>99%) | Passed

</details>

<details>
<summary>Click to Expand and See **AutoScaling** 10K Cloud Native Hybrid on EKS Test Results </summary>

This test:
- Started with 5 webservice pods (out of 20 for 10k test) and 5 hosts instead of 10. 
- It has scaled both pods (to 20) and hosts (to 7) smoothly over 11 minutes.

Attribute                  | Value                                                   
---------------------------|---------------------------------------------------------
Environment:               | Gl-cloudnative-10k-autoscaling-test
Environment Version:       | 13.12.3-ee `9d9769ba2ad`
Option:                    | 60s_200rps
Date:                      | 2021-07-09
Run Time:                  | 1h 17m 19.04s (Start: 11:51:39 UTC, End: 13:08:58 UTC)
GPT Version:               | v2.8.0

❯ Overall Results Score: 97.46%

NAME                                                     | RPS   | RPS RESULT           | TTFB AVG  | TTFB P90              | REQ STATUS     | RESULT          
---------------------------------------------------------|-------|----------------------|-----------|-----------------------|----------------|-----------------
api_v4_groups                                            | 200/s | 198.34/s (>160.00/s) | 219.00ms  | 355.48ms (<505ms)     | 100.00% (>99%) | Passed 
api_v4_groups_group                                      | 200/s | 53.69/s (>16.00/s)   | 3454.06ms | 3975.61ms (<7505ms)   | 100.00% (>99%) | Passed 
api_v4_groups_group_subgroups                            | 200/s | 198.65/s (>160.00/s) | 144.96ms  | 233.89ms (<505ms)     | 100.00% (>99%) | Passed 
api_v4_groups_issues                                     | 200/s | 166.27/s (>48.00/s)  | 1092.33ms | 1903.97ms (<3505ms)   | 100.00% (>99%) | Passed 
api_v4_groups_merge_requests                             | 200/s | 182.09/s (>48.00/s)  | 978.71ms  | 1703.32ms (<3505ms)   | 100.00% (>99%) | Passed 
api_v4_groups_projects                                   | 200/s | 133.43/s (>80.00/s)  | 1372.88ms | 2997.23ms (<3505ms)   | 100.00% (>99%) | Passed 
api_v4_projects                                          | 200/s | 71.58/s (>24.00/s)   | 2394.80ms | 7672.34ms (<7005ms)   | 100.00% (>99%) | FAILED²
api_v4_projects_deploy_keys                              | 200/s | 199.47/s (>160.00/s) | 31.81ms   | 38.30ms (<505ms)      | 100.00% (>99%) | Passed 
api_v4_projects_issues                                   | 200/s | 197.52/s (>160.00/s) | 224.58ms  | 492.47ms (<505ms)     | 100.00% (>99%) | Passed 
api_v4_projects_issues_issue                             | 200/s | 196.27/s (>160.00/s) | 270.01ms  | 618.02ms (<1505ms)    | 100.00% (>99%) | Passed 
api_v4_projects_issues_search                            | 200/s | 94.78/s (>24.00/s)   | 1948.34ms | 3966.45ms (<12005ms)  | 100.00% (>99%) | Passed 
api_v4_projects_languages                                | 200/s | 199.56/s (>160.00/s) | 26.07ms   | 29.19ms (<505ms)      | 100.00% (>99%) | Passed 
api_v4_projects_merge_requests                           | 200/s | 197.71/s (>96.00/s)  | 137.66ms  | 171.92ms (<1005ms)    | 100.00% (>99%) | Passed 
api_v4_projects_merge_requests_merge_request             | 200/s | 195.39/s (>80.00/s)  | 172.09ms  | 220.76ms (<2755ms)    | 100.00% (>99%) | Passed 
api_v4_projects_merge_requests_merge_request_changes     | 200/s | 177.24/s (>80.00/s)  | 981.60ms  | 1629.01ms (<3505ms)   | 100.00% (>99%) | Passed 
api_v4_projects_merge_requests_merge_request_commits     | 200/s | 199.22/s (>160.00/s) | 45.03ms   | 51.35ms (<505ms)      | 100.00% (>99%) | Passed 
api_v4_projects_merge_requests_merge_request_discussions | 200/s | 197.65/s (>160.00/s) | 110.99ms  | 134.51ms (<505ms)     | 100.00% (>99%) | Passed 
api_v4_projects_project                                  | 200/s | 198.6/s (>160.00/s)  | 80.94ms   | 90.14ms (<505ms)      | 100.00% (>99%) | Passed 
api_v4_projects_project_pipelines                        | 200/s | 199.43/s (>160.00/s) | 35.87ms   | 38.95ms (<505ms)      | 100.00% (>99%) | Passed 
api_v4_projects_project_pipelines_pipeline               | 200/s | 198.8/s (>160.00/s)  | 46.15ms   | 50.54ms (<505ms)      | 100.00% (>99%) | Passed 
api_v4_projects_project_services                         | 200/s | 199.53/s (>160.00/s) | 31.10ms   | 34.29ms (<505ms)      | 100.00% (>99%) | Passed 
api_v4_projects_releases                                 | 200/s | 199.13/s (>160.00/s) | 41.55ms   | 54.06ms (<505ms)      | 82.89% (>99%)  | FAILED²
api_v4_projects_repository_branches                      | 200/s | 198.89/s (>160.00/s) | 27.38ms   | 29.95ms (<505ms)      | 100.00% (>99%) | Passed 
api_v4_projects_repository_branches_branch               | 200/s | 199.11/s (>160.00/s) | 59.48ms   | 71.94ms (<505ms)      | 100.00% (>99%) | Passed 
api_v4_projects_repository_branches_search               | 200/s | 198.99/s (>48.00/s)  | 28.14ms   | 30.49ms (<6005ms)     | 100.00% (>99%) | Passed 
api_v4_projects_repository_commits                       | 200/s | 199.21/s (>160.00/s) | 44.81ms   | 50.59ms (<505ms)      | 100.00% (>99%) | Passed 
api_v4_projects_repository_commits_commit                | 200/s | 198.57/s (>160.00/s) | 84.41ms   | 93.32ms (<505ms)      | 100.00% (>99%) | Passed 
api_v4_projects_repository_commits_commit_diff           | 200/s | 198.46/s (>160.00/s) | 92.07ms   | 105.29ms (<505ms)     | 100.00% (>99%) | Passed 
api_v4_projects_repository_compare                       | 200/s | 52.55/s (>16.00/s)   | 3490.42ms | 4488.71ms (<8005ms)   | 100.00% (>99%) | Passed 
api_v4_projects_repository_files_file                    | 200/s | 198.45/s (>160.00/s) | 75.19ms   | 97.69ms (<505ms)      | 100.00% (>99%) | Passed 
api_v4_projects_repository_files_file_blame              | 200/s | 29.76/s (>1.60/s)    | 5887.63ms | 10235.62ms (<35005ms) | 100.00% (>99%) | Passed 
api_v4_projects_repository_files_file_raw                | 200/s | 198.96/s (>160.00/s) | 59.80ms   | 70.18ms (<505ms)      | 100.00% (>99%) | Passed 
api_v4_projects_repository_tags                          | 200/s | 191.05/s (>32.00/s)  | 845.37ms  | 1588.45ms (<10005ms)  | 100.00% (>99%) | Passed 
api_v4_projects_repository_tree                          | 200/s | 199.0/s (>160.00/s)  | 56.36ms   | 60.48ms (<505ms)      | 100.00% (>99%) | Passed 
api_v4_user                                              | 200/s | 199.43/s (>160.00/s) | 26.88ms   | 29.52ms (<505ms)      | 100.00% (>99%) | Passed 
api_v4_users                                             | 200/s | 199.36/s (>160.00/s) | 32.53ms   | 36.05ms (<505ms)      | 100.00% (>99%) | Passed 
git_ls_remote                                            | 20/s  | 19.98/s (>16.00/s)   | 36.34ms   | 37.60ms (<505ms)      | 100.00% (>99%) | Passed 
git_pull                                                 | 20/s  | 19.97/s (>16.00/s)   | 45.74ms   | 56.20ms (<505ms)      | 100.00% (>99%) | Passed 
git_push                                                 | 4/s   | 2.58/s (>3.20/s)     | 261.93ms  | 377.25ms (<1005ms)    | 100.00% (>99%) | Passed 
web_group                                                | 20/s  | 19.97/s (>16.00/s)   | 88.23ms   | 103.52ms (<505ms)     | 98.33% (>99%)  | FAILED²
web_group_issues                                         | 20/s  | 19.56/s (>16.00/s)   | 191.26ms  | 217.23ms (<505ms)     | 100.00% (>99%) | Passed 
web_group_merge_requests                                 | 20/s  | 19.64/s (>16.00/s)   | 184.52ms  | 211.03ms (<505ms)     | 100.00% (>99%) | Passed 
web_project                                              | 20/s  | 19.55/s (>16.00/s)   | 194.21ms  | 217.46ms (<505ms)     | 100.00% (>99%) | Passed 
web_project_branches                                     | 20/s  | 19.0/s (>16.00/s)    | 529.43ms  | 714.81ms (<1005ms)    | 100.00% (>99%) | Passed 
web_project_branches_search                              | 20/s  | 18.97/s (>16.00/s)   | 637.35ms  | 863.35ms (<1305ms)    | 100.00% (>99%) | Passed 
web_project_commit                                       | 20/s  | 18.62/s (>3.20/s)    | 669.82ms  | 1702.96ms (<10005ms)  | 100.00% (>99%) | Passed 
web_project_commits                                      | 20/s  | 19.34/s (>16.00/s)   | 368.04ms  | 441.63ms (<755ms)     | 100.00% (>99%) | Passed 
web_project_file_blame                                   | 20/s  | 6.02/s (>0.16/s)     | 2896.09ms | 3953.70ms (<7005ms)   | 100.00% (>99%) | Passed 
web_project_file_rendered                                | 20/s  | 19.25/s (>9.60/s)    | 480.46ms  | 830.36ms (<3005ms)    | 100.00% (>99%) | Passed 
web_project_file_source                                  | 20/s  | 19.2/s (>1.60/s)     | 621.57ms  | 1313.22ms (<1705ms)   | 100.00% (>99%) | Passed 
web_project_files                                        | 20/s  | 19.63/s (>16.00/s)   | 123.81ms  | 159.50ms (<805ms)     | 100.00% (>99%) | Passed 
web_project_issue                                        | 20/s  | 19.72/s (>16.00/s)   | 226.47ms  | 648.29ms (<2005ms)    | 100.00% (>99%) | Passed 
web_project_issues                                       | 20/s  | 19.57/s (>16.00/s)   | 210.38ms  | 232.68ms (<505ms)     | 100.00% (>99%) | Passed 
web_project_issues_search                                | 20/s  | 19.64/s (>16.00/s)   | 212.77ms  | 232.40ms (<505ms)     | 100.00% (>99%) | Passed 
web_project_merge_request                                | 20/s  | 16.75/s (>6.40/s)    | 1313.41ms | 3740.97ms (<7505ms)   | 100.00% (>99%) | Passed 
web_project_merge_request_changes                        | 20/s  | 19.66/s (>16.00/s)   | 302.16ms  | 542.68ms (<1505ms)    | 100.00% (>99%) | Passed 
web_project_merge_request_commits                        | 20/s  | 18.77/s (>9.60/s)    | 569.23ms  | 659.34ms (<1755ms)    | 100.00% (>99%) | Passed 
web_project_merge_requests                               | 20/s  | 19.46/s (>16.00/s)   | 230.65ms  | 262.27ms (<505ms)     | 100.00% (>99%) | Passed 
web_project_pipelines                                    | 20/s  | 19.54/s (>9.60/s)    | 264.07ms  | 384.69ms (<1005ms)    | 100.00% (>99%) | Passed 
web_project_pipelines_pipeline                           | 20/s  | 19.66/s (>16.00/s)   | 413.13ms  | 911.55ms (<2505ms)    | 100.00% (>99%) | Passed 
web_project_repository_compare                           | 20/s  | 3.56/s (>0.80/s)     | 4740.90ms | 7232.50ms (<7505ms)   | 100.00% (>99%) | Passed 
web_project_tags                                         | 20/s  | 19.03/s (>12.80/s)   | 511.64ms  | 563.67ms (<1505ms)    | 100.00% (>99%) | Passed 
web_user                                                 | 20/s  | 19.82/s (>9.60/s)    | 145.82ms  | 224.83ms (<4005ms)    | 100.00% (>99%) | Passed 

² Failure may not be clear from summary alone. Refer to the individual test's full output for further debugging.

</details>

### Gitaly SRE Considerations

Complete performance metrics should be collected for Gitaly instances for identification of bottlenecks - as they could have to do with disk IO, network IO or memory.

Gitaly must be implemented on instance compute.

#### Gitaly EBS Volume Sizing Guidelines

The Gitaly cluster is built to overcome fundamental challenges with horizontal scaling of the open source Git binaries. As such, the storage is expected to be local (not NFS of any type including EFS).

Gitaly servers also need space for building and caching Git pack files.

Background:

- When not using provisioned EBS IO, EBS volume size determines the IO level - so provisioning volumes that are much larger than needed can be the least expensive way to improve EBS IO.
- Only use nitro instance types due to higher IO and EBS Optimization
- Use Amazon Linux 2 to ensure the best disk and memory optimizations (e.g. ENA network adapters and drivers)
- If GitLab backup scripts are used, they need a temporary space location large enough to hold 2 times the current size of the Git File system. If that will be done on Gitaly servers, separate volumes should be used. 

#### Gitaly HA in EKS Quick Start

The AWS EKS Quick Start for GitLab Cloud Native implements Gitaly as a multi-zone, self-healing infrastructure. It has specific code for reestablishing a Gitaly node when one fails - including AZ failure.
