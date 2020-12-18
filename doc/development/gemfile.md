---
stage: none
group: unassigned
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#assignments
---

# `Gemfile` guidelines

When adding a new entry to `Gemfile` or upgrading an existing dependency pay
attention to the following rules.

## No gems fetched from Git repositories

We do not allow gems that are fetched from Git repositories. All gems have
to be available in the RubyGems index. We want to minimize external build
dependencies and build times.

## Support for gems beyond those included in `Gemfile`

Additional gems that you wish to use for development or testing environments,
but not submitted for inclusion in the Gitlab project itself may be added by
creating `Gemfile.local` in the project root directory. This file should follow
the same format and syntax as `Gemfile`. When present, this file will be
included during `bundle install`, and any gems listed will be accessible to the
application. **They will NOT be available for production environments.** The
purpose of this functionality is to allow developers and teams to include tools
for their specific workflows, or for trial across multiple branches.

## License compliance

Refer to [licensing guidelines](licensing.md) for ensuring license compliance.
