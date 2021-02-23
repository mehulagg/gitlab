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

## License compliance

Refer to [licensing guidelines](licensing.md) for ensuring license compliance.

## Upgrade Rails

When upgrading the Rails gem and its dependencies, you also should update the following:

- The [`Gemfile` in the `qa` directory](https://gitlab.com/gitlab-org/gitlab/-/blob/master/qa/Gemfile).
- The [`Gemfile` in Gitaly Ruby](https://gitlab.com/gitlab-org/gitaly/-/blob/master/ruby/Gemfile),
  to ensure that we ship only one version of these gems.

You should also update npm packages that follow the current version of Rails:

- `@rails/ujs`
- `@rails/actioncable`

## Upgrading dependencies because of vulnerabilities

When upgrading second level dependency because of a vulnerability. We
should pin the minimal version of the gem which was vulnerable in our
Gemfile to avoid accidentally downgrading. Take this fictional
example:

- GitLab
  - license_finder
    - thor

If the thor-gem was vulnerable, and license_finder did not have the
version pinned, we should pin it in our own Gemfile to avoid
accidental downgrades.

A downgrade like that could happen if we introduced a new dependency
that also relied on thor but had it's version pinned to a vulnerable
one. These changes are easy to miss in the Gemfile.lock. Pinning the
version would result in a conflict that will need to be solved.
