---
stage: none
group: unassigned
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#assignments
comments: false
description: 'Making a GitLab codebase composable - allowing to run parts of the application'
---

# Composable GitLab codebase

The one of the major risks of a single codebase is an infinite growth of the whole
application. The more code being added results in a ever increasing resource requirements
for running the application, but increased application coupling and explosion of the complexity.

This proves hard for various reasons:

- Deep coupling between parts of the codebase making it harder to test, or have to run the whole test suite
- All components needs to be loaded all times in order to run only parts of the application
- Increased resource usage, like memory in order to load parts of the application that is rarely used
- Increased application boot-up times
- Longer boot-up times slows down the development, as running application or tests takes singificantly longer
  reducing velocity and amount of iterations

## The contexes idea

This is one of the ideas to look at application from the perspective of how we run it.
The application still is the same, sharing the repository and codebase, but better
modeling a place where we put code to make it easier to define components boundaries
for aspects that we do know that do not need to be exposed elsewhere.

### Application contexes

We today run the application in multiple contexes (as presented by GitLab.com):

- Git nodes running Puma serving only internal API for `ssh/git pull/push` authorization
- Web nodes running Puma serving all Rails controllers
- API nodes running Puma serving all API requests
- GraphQL nodes running Puma (unsure?)
- ActionCable nodes running Puma serving only Websockets connections with GraphQL backend
- Background jobs nodes running Sidekiq in multiple variants, where we selectively pick queues to run in a given context, like: `CI pipelines`

For smaller installations we today in fact have two major contexes:

- Processes running Puma
- Processes running Sidekiq

Even, in this smaller case we have a potential big gain to achieve:

- For Puma do not load Sidekiq workers and all dependent services
- For Sidekiq do not load Controllers / API / GraphQL and all dependent services

### Contexes dependencies

Each of these contexes do really only need a fraction of the codebase with all relevant dependencies:

- Context does need a code responsible for running the given context (like `API` or `GraphQL` endpoints)
- All database models
- Only part of the application common library
- Gems to support the requested functionality

### Example: GraphQL

Today, the GraphQL requires a bunch of dependencies to run after the https://gitlab.com/gitlab-org/gitlab/-/issues/288044:

> We also discovered that we load/require 14480 files, [gitlab-org/memory-team/memory-team-2gb-week#9](https://gitlab.com/gitlab-org/memory-team/memory-team-2gb-week/-/issues/9#note_452530513) when we start GitLab. 1274 files belong to Graphql. This means that if we don't load 1274 application files and all related Graphql gems when we don't need them (Sidekiq), we could save a lot of memory.

The GraphQL only needs to run in a specific context. If we could limit when it is being loaded we could effectively improve application efficency, by: reducing application load time, required memory to use. This for example is applicable for every size installation.

### Proposal

One of the approaches here is to model the codebase around these major components and allow to selectively decide
what context is being loaded. The major contexes that could be approached for example with the `Rails Engines` could be:

- Puma running Web / API / GraphQL / ActionCable
- Sidekiq running all Background Jobs

Another idea is to cut the major components and load them selectively:

- Move GraphQL into a Rails Engine component that is mounted into a Puma process

## Issues

- [Split application into functional parts to ensure that only needed code is loaded with all dependencies](https://gitlab.com/gitlab-org/gitlab/-/issues/290935)
- [Provide mechanism to load GraphQL with all dependencies only when needed](https://gitlab.com/gitlab-org/gitlab/-/issues/288044)

## Who

Proposal:

<!-- vale gitlab.Spelling = NO -->

| Role                         | Who
|------------------------------|-------------------------|
| Author                       |    Kamil Trzciński      |
| Architecture Evolution Coach |    ?                    |
| Engineering Leader           |    ?                    |

DRIs:

| Role                         | Who
|------------------------------|------------------------|
| Product                      |    ?                   |
| Leadership                   |    ?                   |
| Engineering                  |    ?                   |

Domain Experts:

| Role                         | Who
|------------------------------|------------------------|
| Domain Expert                |    ?                   |
| Domain Expert                |    ?                   |
| Domain Expert                |    ?                   |

<!-- vale gitlab.Spelling = YES -->
