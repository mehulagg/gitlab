---
stage: none
group: Style Guide
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#designated-technical-writers
description: 'Writing styles, markup, formatting, and other standards for GitLab Documentation.'
---

# Documentation Style Guide: Markdown syntax

All GitLab documentation is written using [Markdown](https://en.wikipedia.org/wiki/Markdown).
This document defines the standards for using Markdown in GitLab's documentation content and
files.

The [documentation website](https://docs.gitlab.com) uses GitLab Kramdown as its
Markdown rendering engine. For a complete Kramdown reference, see the
[GitLab Markdown Kramdown Guide](https://about.gitlab.com/handbook/markdown-guide/).

The [`gitlab-kramdown`](https://gitlab.com/gitlab-org/gitlab_kramdown) Ruby gem
will support all [GFM markup](../../user/markdown.md) in the future, which is
all markup supported for display in the GitLab application itself. For now, use
regular Markdown markup, following the rules in the linked style guide.

Note that Kramdown-specific markup (for example, `{:.class}`) doesn't render
properly on GitLab instances under [`/help`](index.md#gitlab-help).

### HTML in Markdown

Hard-coded HTML is valid, although it's discouraged from being used while we
have `/help`. HTML is permitted if:

- There's no equivalent markup in Markdown.
- Advanced tables are necessary.
- Special styling is required.
- Reviewed and approved by a technical writer.

### Markdown Rules

GitLab ensures that the Markdown used across all documentation is consistent, as
well as easy to review and maintain, by [testing documentation changes](index.md#testing)
with [markdownlint](index.md#markdownlint). This lint test fails when any
document has an issue with Markdown formatting that may cause the page to render
incorrectly within GitLab. It will also fail when a document is using
non-standard Markdown (which may render correctly, but is not the current
standard for GitLab documentation).

#### Markdown rule `MD044/proper-names` (capitalization)

A rule that could cause confusion is `MD044/proper-names`, as it might not be
immediately clear what caused markdownlint to fail, or how to correct the
failure. This rule checks a list of known words, listed in the `.markdownlint.json`
file in each project, to verify proper use of capitalization and backticks.
Words in backticks will be ignored by markdownlint.

In general, product names should follow the exact capitalization of the official
names of the products, protocols, and so on. See [`.markdownlint.json`](https://gitlab.com/gitlab-org/gitlab/-/blob/master/.markdownlint.json)
for the words tested for proper capitalization in GitLab documentation.

Some examples fail if incorrect capitalization is used:

- MinIO (needs capital `IO`)
- NGINX (needs all capitals)
- runit (needs lowercase `r`)

Additionally, commands, parameters, values, filenames, and so on must be
included in backticks. For example:

- "Change the `needs` keyword in your `.gitlab.yml`..."
  - `needs` is a parameter, and `.gitlab.yml` is a file, so both need backticks.
    Additionally, `.gitlab.yml` will fail markdownlint without backticks as it
    does not have capital G or L.
- "Run `git clone` to clone a Git repository..."
  - `git clone` is a command, so it must be lowercase, while Git is the product,
    so it must have a capital G.