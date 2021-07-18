---
stage: Verify
group: Runner
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#assignments
---

# VM instances and image configuration - Build Cloud for macOS 

The section below describes the available virtual machine configurations.

## Virtual machines

For the beta, each GitLab project that has been granted access will have its own virtual machine (VM) instance. All jobs for that project will run on that instance.

After general availability, when runners are autoscaled, the behavior will be as follows:

- Each job will run in a newly provisioned VM dedicated to the specific job. 
- The VM is active only for the duration of the job and immediately deleted. 

### Virtual machine configurations

- The virtual machines are created with password-less sudo access.
- For the beta, there is only one available machine type, `gbc-macos-large`.

| Instance type | vCPUS | Memory (GB) | Notes |
| --------- | --- | ------- | ------- |
|  `gbc-macos-large` | 4 | 10 | default, beta |


## Software

The GiLab Build Cloud macOS Runners offers various virtual machine images to choose from to execute your build.

| VM Image                     | Included Software               |
|---------------------------|-----------------------|
| macos-10.13-xcode-7       | placeholder for link  |
| macos-10.13-xcode-8       | placeholder for link  |
| macos-10.13-xcode-9       | placeholder for link  |
| macos-10.14-xcode-10      | placeholder for link  |
| macos-10.15-xcode-11      | placeholder for link  |
| macos-11-xcode-12         | placeholder for link  |
| (none, awaiting macos 12) | placeholder for link  |
| macos-next                | placeholder for link  |

### Image update policy

- We intend to support a new macOS version as soon as possible after Apple releases it.
- Additional details on the support policy and image update release process are documented [here.](https://gitlab.com/gitlab-org/ci-cd/shared-runners/images/macstadium/orka/-/blob/55bf59c8fa88712960afff2bf6ecc5daa879a8f5/docs/overview.md#os-images) 
