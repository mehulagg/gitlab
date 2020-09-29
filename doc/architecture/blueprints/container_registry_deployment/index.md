---
comments: false
description: 'Self-service Container Registry deployment'
---

# Usage of the GitLab Container Registry

Usage of feature flags become crucial for the development of GitLab. The
feature flags are a convenient way to ship changes early, and safely rollout
them to wide audience ensuring that feature is stable and performant.

Since the presence of feature is controlled with a dedicated condition, a
developer can decide for a best time for testing the feature, ensuring that
feature is not enable prematurely.

## Challenges

The extensive usage of feature flags poses a few challenges

- 
- 
- 

## Goals

The biggest challenge today with our feature flags usage is their implicit
nature. Feature flags are part of the codebase, making them hard to understand
outside of development function.

We should aim to make our feature flag based development to be accessible to
any interested party.

- developer / engineer
  - can easily add a new feature flag, and configure it's state
  - can quickly find who to reach if touches another feature flag
  - can quickly find stale feature flags
- engineering manager
  - can understand what feature flags her/his group manages
- engineering manager and director
  - can understand how much ~"technical debt" is inflicted due to amount of feature flags that we have to manage
  - can understand how many feature flags are added and removed in each release
- product manager and documentation writer
  - can understand what features are gated by what feature flags
  - can understand if feature and thus feature flag is generally available on GitLab.com
  - can understand if feature and thus feature flag is enabled by default for on-premise installations
- delivery engineer
  - can understand what feature flags are introduced and changed between subsequent deployments
- support and reliability engineer
  - can understand how feature flags changed between releases: what feature flags become enabled, what removed
  - can quickly find relevant information about feature flag to know individuals which might help with an ongoing support request or incident

## Proposal


## Reasons

These are reason why these changes are needed:

- 
## Iterations

This work is being done as part of dedicated epic: [](). This epic
describes a meta reasons for making these changes.

## Who

Proposal:

| Role                         | Who
|------------------------------|-------------------------|
| Author                       |          |
| Architecture Evolution Coach |  |
| Engineering Leader           |          |
| Domain Expert                |             |

DRIs:

| Role                         | Who
|------------------------------|------------------------|
| Product                      | Tim Rizzi              |
| Leadership                   |            |
| Engineering                  |         |

