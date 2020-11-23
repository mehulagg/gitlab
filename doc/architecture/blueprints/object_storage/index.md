---
stage: none
group: unassigned
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#designated-technical-writers
comments: false
description: 'Object Storage: direct_upload consolidation - architecture blueprint.'
---

# Object Storage: `direct_upload` consolidation

Object Storage is a fundamental part of GitLab, it's our distributed, high-available (HA), file storage.

With the release of cloud native GitLab, we had to get rid of the Network File System (NFS) shared storage,
a significant effort was spent developing [direct upload][direct upload], a feature where
[GitLab Workhorse](https://gitlab.com/gitlab-org/gitlab-workhorse) can intercept incoming files and upload
them directly to Object Storage with a more efficient and cost effective implementation.

Cloud Native and the adoption of Kubernetes has been recognised by GitLab to be
one of the top two biggest tailwinds that are helping us grow faster as a
company behind the project.

There are several problems with direct upload and we are at risk of going back to 2017,
with new features not working on Kubernetes and potentially to GitLab.com:

1. The feature is a shared component, not owned by a specific team.
1. The implementation is split between Rails and Workhorse, with a [similar ownership problem](https://gitlab.com/gitlab-org/gitlab-workhorse/-/issues/300).
1. Development has always been reactive: initially it was a blocker to cloud native,
   later on we invested time mostly after several security issues.
1. It's a complex topic, people with the right experience are spread thin across the company.
1. There is some friction in implementing new features with direct upload, and the failure are
   not evident until we run GitLab in an HA environment without a shared storage.

## Additional reading on the topic

* A 2 years old [Object Storage improvements epic](https://gitlab.com/groups/gitlab-org/-/epics/483).
* We are moving to GraphQL API, but [we do not support direct upload](https://gitlab.com/gitlab-org/gitlab/-/issues/280819).
* [Speed up the monolith, speed up the monolith building a smart reverse proxy in Go](https://archive.fosdem.org/2020/schedule/event/speedupmonolith/) a presentation explaining a bit of workhorse history and the challenge we faced in releasing the first cloud-native installation.
* [Uploads development documentation: The problem description](https://docs.gitlab.com/ee/development/uploads.html#the-problem-description).

## Iterations

1. TBD

## Who

Proposal:

<!-- vale gitlab.Spelling = NO -->

| Role                         | Who
|------------------------------|-------------------------|
| Author                       |    Alessio Caiazza      |
| Architecture Evolution Coach |    TBD                  |
| Engineering Leader           |    TBD                  |
| Domain Expert                |    TBD                  |

DRIs:

| Role                         | Who
|------------------------------|------------------------|
| Product                      |    TBD                 |
| Leadership                   |    TBD                 |
| Engineering                  |    TBD                 |

<!-- vale gitlab.Spelling = YES -->

[direct upload]: https://docs.gitlab.com/ee/development/uploads.html#direct-upload
