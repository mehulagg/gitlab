---
stage: Verify
group: Runner
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#assignments
---

# Overview

GitLab is a single DevOps platform, so now, with on-demand macOS Runners integrated with GitLab Saas, you can take advantage of all of the capabilities of the GitLab DevOps platform and not have to manage or operate a build environment.

## Virtual machines

For the beta, jobs will run in a dedicated virtual machine (VM) per project. After the transition to the GitLab macOS autoscaler and the instance-wide macOS Runner Managers on GitLab SaaS activation is complete, each job will run in an ephemeral virtual machine.

### Virtual machine configurations

For the beta, there is only one available machine type, `gbc-macos-large`.

| Instance type | vCPUS | Memory (GB) | Notes |
| --------- | --- | ------- | ------- |
|  `gbc-macos-large` | 4 | 10 | default, beta |

## Software

The GiLab Build Cloud macOS Runners offers various virtual machine images to choose from to execute your build.

| VM Image| Included Software| 
| --------- | --- | 
|   macos-10.13-xcode-7| link |
|   macos-10.13-xcode-8| link |
|   macos-10.13-xcode-9| link |
|   macos-10.14-xcode-10| link |
|   macos-10.15-xcode-11| link |
|   macos-10.1-xcode-12| link |

### Image update policy

{placeholder}

Note - to request changes to the software packages installed on the macOS VM's, open an issue in this project repository. 
