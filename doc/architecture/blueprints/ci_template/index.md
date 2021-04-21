---
stage: verify
group: group::pipeline authoring
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#assignments
comments: false
description: 'Next iteration of CI/CD template architecture at GitLab'
---

# CI/CD template

This documentation describes the next iteration of CI/CD template and how it'll
be beneficial for end-users and us.

CI/CD template is the feature to quickly bootstrap CI/CD workflow or specifc
task without manually authoring the job details in .gitlab-ci.yml. The template
is versatile that does work in projects with different context.
Often, it provides some flexibilities to customize the behavior to fit into an ideal shape.
The target audience is DevOps Engineer who manages the CI/CD worlflow in organizations/projects.

## Quick walkthrough of this blueprint

Given that this documentaion is quite lengthy and tech centered, you might
feel it's hard to understand. In that case, please watch the following summary video:

[video to the link](link).

## Previous architecture

Previously, CI/CD templates are:

- GitLab can only manage.
- GitLab can only manage.

The summary of previous architecture, tech spec

### Details

The detail of previous architecture

### Problems

- Inconsistency. 
- `include:template:` is misleading.
- Lacks of versioning concept. 
- Lacks of C2C (Customer to Customer) concept e.g. Market place.

## New architecture

The summary of the new architecture

Library

### Redifinition of CI/CD template

### CI/CD Template Metadata

- Validations

### CI/CD Template Registry

- Consumers: Search CI/CD Template in interest.
- Publishers: Publish CI/CD Template 
- Container Regisry.

### Including CI/CD Template

- Consumers

## Iterations

- The ability to specify the CI/CD template regisry (Admin only)
- https://gitlab.com/gitlab-org/gitlab/-/issues/326298
- https://gitlab.com/groups/gitlab-org/-/epics/4858

## References

- [Development guide for GitLab CI/CD templates](https://docs.gitlab.com/ee/development/cicd/templates.html)
- [How to use GitLab’s CI/CD pipeline templates](https://about.gitlab.com/blog/2020/09/23/get-started-ci-pipeline-templates/)
- [GitLab CI/CD include examples](https://docs.gitlab.com/ee/ci/yaml/includes.html)

## Who

Proposal:

<!-- vale gitlab.Spelling = NO -->

| Role                         | Who
|------------------------------|-------------------------|
| Author                       |      Shinya Maeda       |
| Architecture Evolution Coach | Gerardo Lopez-Fernandez |
| Engineering Leader           |       Cheryl Li         |
| Domain Expert                |     Kamil Trzciński     |
| Domain Expert                |     Grzegorz Bizon      |

DRIs:

| Role                         | Who
|------------------------------|------------------------|
| Product                      |    Dov Hershkovitch    |
| Leadership                   |       Cheryl Li        |
| Engineering                  |     Shinya Maeda       |

<!-- vale gitlab.Spelling = YES -->
