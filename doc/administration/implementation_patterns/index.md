---
type: reference, concepts
stage: Enablement
group: Alliances
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#assignments
---

# Implementation patterns **(FREE SELF)**

GitLab Reference Architectures are intended to give qualified and tested guidance on the recommended and tested ways GitLab can be configured to meet the performance requirements of various workload requirements - primarily guided by number of active users. Reference Architectures are purpose designed to be as non-implementation specific as possible so that they are applicable to the most different types of implementations possible.

Due to the extreme flexibility of configuring scaled and advanced GitLab configurations - including the flexibility to use platform specific services - it is helpful for more detailed information to be articulated for the most common implementation patterns.

These more detailed opinions may even include build manifests of platform specific resources for given reference architecture sizes. Implementation patterns can also include opinions on parts of GitLab implementation that are not commented on by Reference Architectures - for instance, the type of SMTP services used or GitLab Runner specific recommendations.

Implementation Patterns allow architects and implementers at GitLab, GitLab Customers and GitLab Partners to build out deployments with less experimentation and a higher degree of confidence that the results will perform as expected.

### Implementation patterns compared to reference architectures

GitLab implementation patterns relate to [GitLab Reference Architectures](../reference_architectures/index.md) in the following ways:

#### Reference Architecture and Cloud Well Architected Compliance
- Implementation patterns maintain Reference Architecture compliance and to provide [GitLab Performance Tool](https://gitlab.com/gitlab-org/quality/performance) (gpt) reports.
- Implementation patterns may be qualified by and/or contributed to by the technology vendor - for instance, an implementation pattern for AWS may be officially reviewed by AWS.
- Implementation patterns may specify and test Cloud Platform PaaS services for suitability for GitLab - this testing can be coordinated and help qualify these technologies for Reference Architectures.
#### Cost Engineering
- Implementation patterns may define GPT tested autoscaling for various aspects of GitLab infrastructure - including minimum idling configurations and scaling speeds.
- Implementation patterns may provide gpt testing for advised configurations that go beyond the scope of reference architectures - for instance gpt tested elastic scaling configurations for Cloud Native Hybrid that enable lower resourcing during periods of lower usage (e.g. on the weekend)
- Implementation patterns may engineer specifically for the savings models available on a platform provider - an AWS example would be maximizing the occurance of a specific instance type for taking advantage of reserved instances.
- Implementation patterns may leverage emphemeral compute where appropriate and with appropriate customer guidelines.  For instance a Kubernetes node group dedicated to runners on emphemeral compute - with appropriate GitLab runner tagging to indicate the compute type.
- Implementation patterns may include vendor specific cost calculators.
#### Actionability and Automatability Orientation
- Implementation patterns enable builders to generate a list of vendor specific resources required to implement GitLab for a given Reference Architecture.
- Implementation patterns enable builders to use manual instructions or to create automation to build out the reference implementation.
#### Platform Partner Specificity
- Implementation patterns are more vendor specific. For instance, advising specific compute instances / vms / nodes instead of vcpus or other generalized measures.
- Implementation patterns are oriented to implementing good architecture for the vendor in view.  For instance, where reference architectures do not have a specific recommendation on what technology is leveraged for GitLab outbound email services or what the sizing should be - a Reference Implementation may advise using a cloud providers Email as a Service (PaaS) and possibly even with specific settings.
- Implementation patterns are written to an audience who is familiar with building on the infrastructure that the implementation pattern targets.  For example, if the implementation pattern is for GCP, the specific terminology of GCP is used - including using the specific names for PaaS services.
- Implementation patterns can test and qualify if the versions of PaaS available are compatible with GitLab (e.g. PostgreSQL, Redis, etc)

#### Additional Implementation Patterns
- Implementation patterns may also provide specialized implementations beyond the scope of reference architecture compliance, for example:
  - GitLab Runner implementation patterns.
  - Small, self-contained GitLab Instances for per-person admin training.

### Example Pattern Types

- Amazon Web Service (AWS)
  - [GitLab Cloud Native Hybrid on AWS EKS](./AWS/index.md) - MVC of this type of documentation.
- Google Cloud (GCP) (Coming Soon)
  - GitLab Omnibus on GCP Instances (Coming Soon)
- Microsoft Azure (Azure) (Coming Soon)
  - GitLab Omnibus on GCP Instances (Coming Soon)
- IBM 
  - GitLab Omnibus CloudPaks  (Coming Soon)