---
type: reference, concepts
stage: Enablement
group: Distribution
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#assignments
---

# Implementation patterns **(FREE SELF)**

GitLab implementation relate to [GitLab Reference Architectures](../reference_architectures/index.md) in the following ways:

- They strive to maintain Reference Architecture compliance and to provide [GitLab Performance Tool](https://gitlab.com/gitlab-org/quality/performance) (gpt) reports.
- They are more vendor specific. For instance, advising specific compute instances / vms / nodes instead of vcpus or other generalized measures.
- They are oriented to implementing good architecture for the vendor in view.  For instance, where reference architectures do not have a specific recommendation on what technology is leveraged for GitLab outbound email services or what the sizing should be - a Reference Implementation may advise using a cloud providers Email as a Service (PaaS) and possibly even with specific settings.
- They may implement autoscaling of the GitLab instance.
- They may be qualified by and/or contributed to by the vendor.
- They enable builders to generate a list of vendor specific resources required to implement GitLab for a given Reference Architecture.
- They may include vendor specific cost calculators.
- They enable builders to use manual instructions or automation to build out the reference implementation.
- They may also provide specialized implementations beyond the scope of reference architectures, for example:
  - GitLab Runner implementation patterns.
  - Small, self-contained GitLab Instances for per-person admin training.

Available implementations patterns

The following implementation patterns are available:

- Amazon Web Service (AWS)
    - GitLab Omnibus on AWS Ec2
    - GitLab Cloud Native Hybrid on AWS EKS
- Google Cloud (GCP)
    - GitLab Omnibus on GCP Instances
- Microsoft Azure (Azure)
    - GitLab Omnibus on GCP Instances