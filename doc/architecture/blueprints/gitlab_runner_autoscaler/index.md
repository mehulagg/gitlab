---
stage: none
group: unassigned
comments: false
description: 'Next iteration of GitLab CI/CD autoscaling'
---

# RFC: GitLab Runner Autoscaler

This document captures ideas about the next version of GitLab Runner
Autoscaling.

This is one of many ideas about how to improve autoscaling of GitLab CI/CD
builds and by replacing `docker+machine` executor.

Methods and mechanisms described here are a memorandum used to foster
collaboration and to collect feedback from GitLab team members following the
simplified process of [RFC](https://en.wikipedia.org/wiki/Request_for_Comments)
- please leave your thoughts and ideas in the merge request!

## Summary

Proposal described here is to create a new service, called GitLab Runner
Autoscaler. It would be responsible for creating contexts in which builds run,
dispatching runners, builds, running them and collecting outputs (build logs,
file artifacts, build statuses) that then get passed to GitLab instance.

## GitLab Runner Autoscaler

GitLab Runner Autoscaler is be a separate service, running in a separate
virtual machine that would mimic behavior of GitLab Runner in a way that it
would get registered on GitLab.com as a regular Runner. It would keep polling
`/api/v4/jobs/request` endpoint to find new builds to process, and once it
receives a build it provisions a virtual machine for it (or is using an
existing one) and inject a GitLab Runner sidecar into the machine. Provisioning
would happen through a custom provisioner.

All the provisioners created by GitLab team members and community should run
separately in a nightly pipeline to verify that the integration with a cloud
provider works.

### Custom provisioners

A custom provisioner is a script, Go plugin or an app that is responsible for
creating, enumerating and destroying contexts / machines in which builds can
run. Usually this context would be a separate virtual machine, but it can be a
container or something else.

A provisioner should be able to:

1. Create a machine returning the machine identifier
1. List existing machines with their identifiers
1. Get a status of a machine using an identifier
1. Destroy a machine using an identifier

GitLab Runner Autoscaler should be able to use many provisioners through a
simple interface.

Example: a collection of Ruby scripts to provision and manage virtual machines
in GCP.

### Runner sidecar

Once a machine is provisioned and available, GitLab Runner Autoscaler injects
GitLab Runner into the machine as a sidecar.

The runner gets registered against the GitLab Runner Autoscaler itself, and the
autoscaler is then responsible for its lifecycle. GitLab Runner Sidecar polls
the autoscaler's `/api/v4/jobs/register` API to pick builds, and submits build
logs, artifacts and eventually a build status to the GitLab Runner Autoscaler
too.

The autoscaler is then responsible for passing this output to a GitLab
instance, like GitLab.com.

GitLab Runner should not be aware of the fact that it is talking to the GitLab
Runner Autoscaler instead of a GitLab instance.

### State management

GitLab Runner Autoscale is responsible for keeping track on machines owned by
it. By being able to enumerate all the machines, it will know the amount of
machines created and the number of machines that were pre-provisioned. This can
be used to provide efficient autoscaling algorithms.

No shared database / storage should be required to manage the state of
machines, instead local or memory storage should be used.

The autoscaler will also own runner tokens that belong to runners injected into
machines it manages.

This can lead to machines being orphaned when an autoscaler crashes. In order
to resolve that, other autoscalers should be able to remove orphaned machines
according to policies configured.

When a build is done, and autoscaler decides that the machine used to run is no
longer needed it can use a custom provisioner to tear the machine down,
alternatively it can be reused.

### Dispatching builds

GitLab Runner Autoscaler polls `/api/v4/jobs/request` to find new builds.
Runners running in machines poll autoscalers's API.

Because the autoscaler keeps track on machines that are available, their sizes
and processing that happens inside them, it can be smart enough to dispatch
jobs in a way to increase utilization. A runner running in a machine should be
able to process more than one job if needed. GitLab Runner Autoscaler can also
dispatch jobs based on preconfigured policies, like plan type, preferred
machine size and desirable concurrency of processing.

### Submitting output

When GitLab Runner Autoscaler receives output from a Runner (build status,
partial build log, file artifacts), it passes it to a GitLab instance.

### Caveats

* Custom provisioners should be smart enough to create machines with
  dependencies before a Runner sidecar gets injected (Docker)

## Who

Proposal:

<!-- vale gitlab.Spelling = NO -->

| Role                         | Who
|------------------------------|-------------------------|
| Author                       |     Grzegorz Bizon      |

<!-- vale gitlab.Spelling = YES -->
