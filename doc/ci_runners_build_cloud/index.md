---
comments: false
stage: Verify
group: Runner
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#assignments
---

# GitLab Build Cloud

GitLab Build Cloud is the CI/CD build environment integrated with GiLab SaaS that lets you run your CI/CD jobs without having to maintain your own build systems.
We offer Linux (GA), Windows (Beta), and macOS (Beta) build environments, (Runners). 

GitLab.com Runners run in autoscale mode, which means that we have configured multiple installations of GitLab Runner as Runner Managers. Each manager uses our autoscaler to create a new virtual machine (VM) to run a CI job. Each VM is deleted after the assigned CI job is complete therefore ensuring security and isolation of your CI workloads on GitLab.com

You can self-host GitLab Runners if your CI/CD jobs require a build environment not available on the GitLab.com Build Cloud or for scenarios that require access to resources on your internal network. Check out our extensive documentation on installing and self-hosting GitLab Runner. 

## Service Level Objectives

- placeholder for SLO definitions.
