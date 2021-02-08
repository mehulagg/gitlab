---
stage: none
group: unassigned
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#assignments
comments: false
description: 'Merge groups and projects'
---

# Merging Group and Project

There is are numerous features that exist exclusively within groups or
projects. The boundary between group and project features used to be clear.
However there is growing demand to have group features within projects, and
project features within groups. For example, having issues in groups, and epics
in projects.

The [Simplify Groups & Projects Working Group](https://about.gitlab.com/company/team/structure/working-groups/simplify-groups-and-projects/)
determined that our architecture is a significant hurdle in sharing features across groups and projects.

## Challenges

- Features are coupled to their container. In practice it is not straight forward to decouple a feature from its container. The degree of coupling varies across features.
- Naive duplication of features will result in a more complex and fragile code base.
- Generalizing solutions across groups and projects may degrade system performance.
- The range of features span across many teams and these changes will need to manage development interference.
- The group/project hierarchy creates a natural feature hierarchy. When the features exist across containers the feature hierarchy becomes ambiguous.
- There is potential for significant architectural changes. These changes will have to be independent of the product design so that customer experience remains consistent.

## Goals

For now this blueprint strictly relates to the engineering challenges.

- Merge the group and project container architecture.
- Develop a set of solutions to decouple features from their container.
- Decouple engineering changes from product changes.
- Develop a strategy to make architectural changes without adverseley affecting other teams.

## Iterations

Final details to be decided. The current plan is for engineers across multiple
teams to work on team specific issues that involve porting a group feature to
projects, or a project feature to groups. We will meet bi-weekly to compare solutions
and attempt to pull out common elements across these solutions. 

## Who

Proposal:

<!-- vale gitlab.Spelling = NO -->

| Role                         | Who
|------------------------------|-------------------------|
| Author                       |    Alex Pooley          |
| Architecture Evolution Coach |                         |
| Engineering Leader           |                         |
| Domain Expert                |                         |

<!-- vale gitlab.Spelling = YES -->

DRIs:

<!-- vale gitlab.Spelling = NO -->

| Role                         | Who
|------------------------------|------------------------|
| Product                      |                        |
| Leadership                   |                        |
| Engineering                  |                        |

<!-- vale gitlab.Spelling = YES -->
