---
stage: none
group: unassigned
comments: false
description: 'Improvements to CI/CD builds data storage model'
---

# Improve CI/CD builds data storage model

## Summary

GitLab CI/CD is one of GitLab's most data and compute intensive components.
Since its [initial release in November 2012][ci-initial-release], the CI/CD
subsystem has evolved significantly. It was [integrated into GitLab in
September 2015][ci-integrated] and has become [one of the most beloved CI/CD
solutions][ci-leader].


GitLab CI/CD has come a long way since the initial release, but the design of
the data storage for pipeline builds remains almost the same since 2012. We
store all the builds in PostgreSQL in `ci_builds` table, and because we are
creating more than 0.5 million builds each day on GitLab.com, we are reaching
database limits that are slowing our development velocity down.

[ci-initial-release]: https://about.gitlab.com/blog/2012/11/13/continuous-integration-server-from-gitlab/
[ci-integrated]: https://about.gitlab.com/releases/2015/09/22/gitlab-8-0-released/
[ci-leader]: https://about.gitlab.com/blog/2017/09/27/gitlab-leader-continuous-integration-forrester-wave/

## Goals

1. Transition primary key for `ci_builds` to 64-bit integer
1. Reduce the amount of data stored in `ci_builds` table
1. Reduce the size of indices associated with `ci_builds` table
1. Reduce the number of columns in `ci_builds` table

## Challenges

[TODO]

## Iterations

1. Implement partitioning strategy for `ci_builds` table
1. Rebuild background migrations to allow them to run reliably in parallel
1. Migrate primary key of `ci_builds` table to 64-bit integer
1. Remove columns storing redundant data in `ci_builds` table

## Status

Blueprint in progress.

## Who

Proposal:

<!-- vale gitlab.Spelling = NO -->

| Role                         | Who
|------------------------------|-------------------------|
| Author                       | Grzegorz Bizon          |
| Architecture Evolution Coach | Kamil Trzciński         |
| Engineering Leader           | Darby Frey              |
| Product Manager              | TBD                     |
| Domain Expert / Verify       | Fabio Pitino            |
| Domain Expert / Database     | Jose Finotto            |
| Domain Expert / PostgreSQL   | TBD                     |

DRIs:

| Role                         | Who
|------------------------------|------------------------|
| Leadership                   | Darby Frey             |
| Product                      | TBD                    |
| Engineering                  | Grzegorz Bizon         |

<!-- vale gitlab.Spelling = YES -->
