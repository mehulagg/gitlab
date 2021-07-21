---
stage: Enablement
group: Distribution
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#assignments
comments: false
description: Read through the GitLab installation methods.
type: index
---

# AWS implementation patterns **(FREE SELF)**

GitLab  [GitLab Reference Architectures](../../../administration/reference_architectures/index.md) give qualified and tested guidance on the recommended ways GitLab can be configured to meet the performance requirements of various workloads. Reference Architectures are purpose-designed to be as non-implementation specific as possible to apply to the most different types of implementations possible. This generally means they have a highly granular "machine" to "server role" specification and focus on system elements that impact performance. Reference Architectures can be adapted to the broadest number of supported implementations.

Implementation patterns are built on the foundational information and testing done for Reference Architectures and allow architects and implementers at GitLab, GitLab Customers, and GitLab Partners to build out deployments with less experimentation and a higher degree of confidence that the results will perform as expected.

GitLab implementation patterns build upon [GitLab Reference Architectures](../reference_architectures/index.md) in the following ways:

## GitLab reference architecture and cloud platform well architected compliance

Testing-backed architectural qualification is a fundamental concept behind implementation patterns.

- Implementation patterns maintain Reference Architecture compliance and provide [GitLab Performance Tool](https://gitlab.com/gitlab-org/quality/performance) (gpt) reports to demonstrate adherance to them.
- Implementation patterns may be qualified by and/or contributed to by the technology vendor - for instance, an implementation pattern for AWS may be officially reviewed by AWS.
- Implementation patterns may specify and test Cloud Platform PaaS services for suitability for GitLab - this testing can be coordinated and help qualify these technologies for Reference Architectures. For instance qualifying compatibility with and availability of runtime versions of top level PaaS such as those for PostgreSQL and Redis.
- Implementation patterns can provided qualified testing for platform limitations, for example, ensuring Gitaly Cluster can work correctly on specific Cloud Platform availability zone latency and throughput characteristics or qualifying what levels of available platform partner local disk performance is workable for Gitaly server to operate with integrity.

## Platform Partner Specificity

Implementation patterns enable platform specific terminology, best practice architecture and platform specific build manifests.

- Implementation patterns are more vendor specific. For instance, advising specific compute instances / vms / nodes instead of vcpus or other generalized measures.
- Implementation patterns are oriented to implementing good architecture for the vendor in view. 
- Implementation patterns are written to an audience who is familiar with building on the infrastructure that the implementation pattern targets. For example, if the implementation pattern is for GCP, the specific terminology of GCP is used - including using the specific names for PaaS services.
- Implementation patterns can test and qualify if the versions of PaaS available are compatible with GitLab (e.g. PostgreSQL, Redis, etc)

## Platform as a Service

Platform as a Service options are a huge portion of the value provided by Cloud Platforms as they simplify operational complexity and reduce the SRE and security skilling required to operate advanced, highly available technology services. Implementation patterns can be prequalified against the partner PaaS options.

- Implementation patterns help implementers understand what PaaS options are known to work and how to choose between PaaS solutions when a single platform has more than one PaaS option for the same GitLab role (e.g. AWS RDS versus AWS Aurora RDS)
- For instance, where reference architectures do not have a specific recommendation on what technology is leveraged for GitLab outbound email services or what the sizing should be - a Reference Implementation may advise using a cloud providers Email as a Service (PaaS) and possibly even with specific settings.

## Cost optimizing engineering

Cost engineering is a fundamental aspect of Cloud Architecture and frequently the savings capabilities available on a platform exert strong influence on how to build out scaled computing.

- Implementation patterns may define GPT tested autoscaling for various aspects of GitLab infrastructure - including minimum idling configurations and scaling speeds.
- Implementation patterns may provide gpt testing for advised configurations that go beyond the scope of reference architectures - for instance gpt tested elastic scaling configurations for Cloud Native Hybrid that enable lower resourcing during periods of lower usage (e.g. on the weekend)
- Implementation patterns may engineer specifically for the savings models available on a platform provider - an AWS example would be maximizing the occurance of a specific instance type for taking advantage of reserved instances.
- Implementation patterns may leverage emphemeral compute where appropriate and with appropriate customer guidelines. For instance a Kubernetes node group dedicated to runners on emphemeral compute - with appropriate GitLab Runner tagging to indicate the compute type.
- Implementation patterns may include vendor specific cost calculators.

## Actionability and automatability orientation

Implementation patterns are one step closer to specifics that can be used as a source for build instructions and automation code.

- Implementation patterns enable builders to generate a list of vendor specific resources required to implement GitLab for a given Reference Architecture.
- Implementation patterns enable builders to use manual instructions or to create automation to build out the reference implementation.

## Supplementary implementation patterns

Implementation patterns may also provide specialized implementations beyond the scope of reference architecture compliance, especially where the cost of enablement can be more appropriately managed.

For example:

- Small, self-contained GitLab Instances for per-person admin training - perhaps on Kubernetes so a deployment cluster is self-contained as well.
- GitLab Runner implementation patterns - including using platform specific PaaS.

## Intended audiences and contributors

The primary audience for this information is GitLab **Implementation Eco System** which consists of at least:

Community:

- Customers
- GitLab Channel Partners (Integrators)
- Platform Partners

GitLab Internal:

- Quality / Distribution / Self-Managed
- Alliances
- Support
- Professional Services
- Public Sector

| GitLab Installaton                          | Description |
|---------------------------------------------------------------|-------------|
| [GitLab Cloud Native Hybrid on AWS EKS (HA)](gitlab_hybrid_on_aws.md)                                      | Install GitLab Cloud Native Hybrid on AWS EKS. Includes Bill of Materials listings and links to Infrastructure as Code |
| [Omnibus GitLab on AWS EC2 (HA)](manual_install_aws.md) | Install GitLab on EC2 instances. Manual instructions from which you may build out a GitLab instance or create your own Infrastructure as Code (IaC). |
