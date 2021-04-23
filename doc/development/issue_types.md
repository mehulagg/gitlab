---
stage: Plan
group: Project Management
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#assignments
---

# Issue Types

Sometimes when a new resource type is added it's not clear if it should be only an
"extension" of Issue (Issue Type) or if it should be a new first-class resource type
(similar to Issue, Epic, Merge Request, Snippet).

The idea of Issue Types was first proposed in [this
issue](https://gitlab.com/gitlab-org/gitlab/-/issues/8767) and its usage was
discussed few times since then, for example in [incident
management](https://gitlab.com/gitlab-org/gitlab-foss/-/issues/55532).

We are in the process of making issue types [extensible](https://gitlab.com/groups/gitlab-org/-/epics/3354)
and [converting Plan-related resources into issue types](https://gitlab.com/gitlab-org/gitlab/-/issues/271171).

## What is an Issue Type

Issue Type is a resource type which extends the existing Issue type and is
used anywhere where Issue is used - for example when listing or searching
issues or when linking objects of the type from Epics. It uses the same
`issues` table, additional fields are implemented as [widgets](https://gitlab.com/groups/gitlab-org/-/epics/3354)

## When an Issue Type should be used

- When the new type only adds new fields to the basic Issue type without
  removing existing fields (but it's OK if some fields from the basic Issue
  type are hidden in user interface/API).
- When the new type can be used anywhere where the basic Issue type is used.

## When a first-class resource type should be used

- When a separate model and table is used for the new resource.
- When some fields of the basic Issue type need to be removed - hiding in the UI
  is OK, but not complete removal.
- When the new resource cannot be used instead of the basic Issue type,
  for example:

  - You can't add it to an epic.
  - You can't close it from a commit or a merge request.
  - You can't mark it as related to another issue.

If an Issue type can not be used you can still define a first-class type and
then include concerns such as `Issuable` or `Noteable` to reuse functionality
which is common for all our issue-related resources. But you still need to
define the interface for working with the new resource and update some other
components to make them work with the new type.

Usage of the Issue type limits what fields, functionality, or both is available
for the type. However, this functionality is provided by default.

## Issue Type implementation guidance

- The new issue type should be accessed and managed through the existing Issue UI/API.
  All issue types should be included in the response unless deliberately filtered out in the request params.
  There is currently an option to
  [exclude issues of some type](https://gitlab.com/gitlab-org/gitlab/-/issues/271171#note_502662414)
  when listing issues, but this exclusion is not perfect (and on some other places these are still available).
  Excluding an issue type goes against the benefits of reusing issue types logic and is discouraged and this
  option will be deprecated.
- UI/API should support filtering issues by issue type.
- If needed, there can be additional "special" UI for listing or managing the new issue type, but
  this UI should still re-use the existing generic Issue Vue components and generic issue API for
  listing and managing resources (currently Test case issue type is listed separately).
- Any extra logic for the new issue type should be implemented as a widget. TODO: add
  link to sample implementation of widget, we should avoid mixing issue-type specific logic with
  generic issue logic (in all layers of code), related to [discussion](https://gitlab.com/gitlab-org/gitlab/-/issues/271171#note_521989053).
- Widget specific logic should be exposed in a unified way in GraphQL API (TBD:
  related to [discussion](https://gitlab.com/gitlab-org/gitlab/-/issues/222954#note_554859137)).
