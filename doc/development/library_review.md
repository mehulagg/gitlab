---
stage: none
group: unassigned
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#assignments
---

# Library Review Guidelines

This page is specific to the review of libraries (i.e. Ruby gems, Node.js modules, Go modules). Please refer to our
[code review guide](code_review.md) for broader advice and best
practices for code review in general.

Whenever new libraries are introduced or existing libraries are updated, the guidelines for reviewing libraries described on this page have to be followed. The goal of this process is to ensure that all libraries that our code relies on meet our standards for performance, security, and complicance.

## General Process

The library review guidelines have to be followed when an MR changes:

- a library manifest (e.g. `Gemfile`, `package.json`, `go.mod`)
- a lockfile (e.g. `Gemfile.lock`, `yarn.lock`, `go.sum`)

The process differs based on if an MR introduces a new library or if an MR updates the version an existing library. When introducing a new library, please follow the procedure documented in:

- [Introducing a new library](#adding-a-new-library)
- [Vetting a library](#vetting-a-library)

When updating the version of an existing library, skip to [vetting a library](#vetting-a-library).

## Roles and Responsibilities

A merge request's **author** responsbilities are:
- Before adding a new library, evaluate it as described in [introducing a new library](#adding-a-new-library). Document the result of the evaluation for the MR reviewer.
- Before assigning to a reviewer, vet the dependency as described in [vetting a library](#vetting-a-library). If the library passes the vetting, continue to assign the MR to the reviewer.

A merge request's **reviewers** responsbilities are:
- In case the MR adds a new library, check that the author evaluated the library as described in [introducing a new library](#adding-a-new-library) and that the evaluation is sound.
- Vet the dependency as described in [vetting a library](#vetting-a-library). If no issues are identified, proceed with merging the changes.

## Adding a new library

Adding a new library is an important decision. Implications and alternatives should be carefully considered. Keep in mind that adding a new library creates additional maintaince effort for keeping the library up-to-date and it will need to be replaced when it reaches the end of life. Also be aware of the security implications: Having another library in our dependency tree is another vector of attack (a library might have unknown vulnerabilites, could get compromissed, etc.). Before adding a new library consider alternatives such as implementing the functionality yourself. For example, if you only use a small utility function of a library with a large code base, it might be better to implement the functionality yourself instead of adding a large library.

If adding a new library cannot be avoided, create a short-list of libraries that implement the desired functionality and evaluate them for:

- Activity volume: Is the project being actively maintained? Are there new releases and issues being closed?
- Maintainer: Are the maintainers responsive on issues and MRs/PRs? Is it maintained by a single person or a group or an organization?
- No unpatched vulnerabilities: Does the library have unpatched and publicly-known vulnerabilities or relies on dependencies with unpatched vulnerabilities?
- Project maturity: Does the project have sufficient documentation? Does it have processes established, e.g. for contributing and reporting bugs?

If your merge request includes adding a new JavaScript library (*1*), you also need to do the following:
   - If the library significantly increases the
     [bundle size](https://gitlab.com/gitlab-org/frontend/playground/webpack-memory-metrics/-/blob/master/doc/report.md), it must
     be **approved by a [frontend foundations member](https://about.gitlab.com/direction/create/ecosystem/frontend-ux-foundations/)**.
   - If the license used by the new library hasn't been approved for use in
     GitLab, the license must be **approved by a [legal department member](https://about.gitlab.com/handbook/legal/)**.
     More information about license compatibility can be found in our
     [GitLab Licensing and Compatibility documentation](licensing.md).

After selecting a library that satisfies these criteria, move on to [vet library code](#Vetting-a-library). If no library on your shortlist satisfies the criteria, consider implementing the functionality yourself or creating a fork.

## Vetting a library

Code contained in libraries needs to be vetted for security issues. This process should be followed to vet library code:

1. Inspect the findings of security scanners. The scanners are executed in CI jobs and their findings are available as job artifacts and/or in the MR Security Widget. The findings of the following scanners have to be inspected:
  - *[GitLab Dependency Scanning](https://docs.gitlab.com/ee/user/application_security/dependency_scanning/).* If Dependency Scanning reports a vulnerability for the added library, or any of its sub-libraries, check if a newer version of the library exists that patches the vulnerabilities. If no such version exists, the library should not be added. (ToDo: do we need an exception process for adding libs with known vulns?)
  - *[Package Hunter](https://gitlab.com/gitlab-com/gl-security/security-research/package-hunter)*. Package Hunter findings indicate that a library might contain malicious code or other undesired behavior (e.g. a binary is downloaded and executed form a 3rd party server without checking it's integrity first). Any Package Hunter findings should be triaged before the MR is merged. Please involve the Security Engineering and Research team if you are unsure how to proceed with the triage.
  - *[untamper-my-lockfile](https://gitlab.com/gitlab-org/frontend/untamper-my-lockfile/)*. If this job is failing, do not merge the MR. Instead, ping the Security Engineering and Research team on the MR.
2. Inspect Code: All library code should be reviewed for malicious or otherwise problematic code, just as you would do for any other MR with code changes. When inspecting the code, take care to inspect the actual code that is distributed (i.e. the code contained in a Gem or Node.js package). **DO NOT** review the code in the code repository associated with a library. There is no gurantee that the code in the repository matches the distributed code. There are several services which allow to inspect the distributred library code. For example, for Gems there is diffend.io ([example](https://my.diffend.io/gems/aliyun-sdk/0.7.1/0.8.0)) and for Node.js there is app.renovatebot.com ([example](https://app.renovatebot.com/package-diff?name=copy-webpack-plugin&from=5.0.5&to=5.1.2)). // ToDo: Give recommendation for go

If the vetting didn't identify any issues, the MR can be merged.
