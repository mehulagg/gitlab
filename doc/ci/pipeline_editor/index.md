---
stage: Verify
group: Pipeline Authoring
info: This is the go-to place for creating new, and editing existing pipeline configs.
type: reference
---
<!-- 
TODO: 
 - [ ] Fill out the description / intro
 - [ ] Fill out the use cases
 - [ ] Reword features as "tasks"
 - [ ] Get some screenshots
 - [ ] Move the linter and visualiser to their own pages
-->

# Pipeline Editor **(CORE)**

> [Introduced](https://gitlab.com/gitlab-org/gitlab/-/issues/263147) in GitLab 13.8.

<!-- DESCRIPTION -->

## Editor

### Schema

### Validation

### Committing

## Linter
<!-- TODO: This should be a seperate page -->

## Visualiser
<!-- TODO: This should be a seperate page -->


<!-- 

# Feature or Use Case Name **[TIER]** (1)
If you are writing about a use case, start with a verb,
for example, "Configure", "Implement", + the goal/scenario

For pages on newly-introduced features, add the following line.
If only some aspects of the feature have been introduced, specify which parts of the feature.
> [Introduced](link_to_issue_or_mr) in GitLab (Tier) X.Y (2).

## Use cases

Describe common use cases, typically in bulleted form. Include real-life examples
for each.

If the page itself is dedicated to a use case, this section usually includes more
specific scenarios for use (for example, variations on the main use case), but if
that's not applicable, you can omit this section.

Examples of use cases on feature pages:

- CE and EE: [Issues](../../user/project/issues/index.md#use-cases)
- CE and EE: [Merge Requests](../../user/project/merge_requests/index.md)
- EE-only: [Geo](../../administration/geo/index.md)
- EE-only: [Jenkins integration](../../integration/jenkins.md)

## Prerequisites

State any prerequisites for using the feature. These might include:

- Technical prereqs (for example, an account on a third-party service, an amount
  of storage space, or prior configuration of another feature)
- Prerequisite knowledge (for example, familiarity with certain GitLab features
  or other products and technologies).

Link each one to an appropriate place for more information.

## Tasks

Each topic should help users accomplish a specific task.

The heading should:

- Describe the task and start with a verb. For example, `Create a package` or
  `Configure a pipeline`.
- Be short and descriptive (up to ~50 chars).
- Start from an `h2` (`##`), then go over `h3`, `h4`, `h5`, and `h6` as needed.
  Never skip a hierarchy level (like `h2` > `h4`). It breaks the table of
  contents and can affect the breadcrumbs.

Bigger tasks can have subsections that explain specific phases of the process.

Include example code or configurations when needed. Use Markdown to wrap code
blocks with [syntax highlighting](../../user/markdown.md#colored-code-and-syntax-highlighting).

Example topic:

## Create a teddy bear

Create a teddy bear when you need something to hug. (Include the reason why you
might do the task.)

To create a teddy bear:

1. Go to **Settings > CI/CD**.
1. Expand **This** and click **This**.
1. Do another step.

The teddy bear is now in the kitchen, in the cupboard above the sink. _(This is the result.)_

You can retrieve the teddy bear and put it on the couch with the other animals. _(These are next steps.)_

Screenshots are not necessary. They are difficult to keep up-to-date and can
clutter the page.

## Troubleshooting

Include any troubleshooting steps that you can foresee. If you know beforehand
what issues one might have when setting this up, or when something is changed,
or on upgrading, it's important to describe those, too. Think of things that may
go wrong and include them here. This is important to minimize requests for
Support, and to avoid documentation comments with questions that you know
someone might ask.

Each scenario can be a third-level heading, for example, `### Getting error message X`.
If you have none to add when creating a doc, leave this section in place but
commented out to help encourage others to add to it in the future.

---

Notes:

- (1): Apply the [tier badges](styleguide/index.md#product-badges) accordingly.
- (2): Apply the correct format for the
       [GitLab version that introduces the feature](styleguide/index.md#gitlab-versions-and-tiers).

-->
