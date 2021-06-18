---
stage: 
group: 
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#assignments
---

# Use GitLab **(FREE)**

Get to know the GitLab end-to-end workflow. Configure permissions,
organize your work, create and secure your application, and analyze its performance. Report on team productivity throughout the process.

- [Set up your organization](set_up_organization.md)
- [Organize work with projects](../user/project/index.md)
- [Plan and track work](plan_and_track.md)
- [Build your application](build_your_application.md)
- [Secure your application](../user/application_security/index.md)
- [Release your application](release_your_application.md)
- [Monitor application performance](../operations/index.md)
- [Analyze GitLab usage](../user/analytics/index.md)


# Language-Specific Fast Paths

GitLab thrives as a language-agnostic, DevSecOps Platform. That being said, there are a few locations where we interact with programming languages in very specific ways and our support for languages may vary. This aims to give you quick access to the locations where we have language-specific support.

### Commit

* [Syntax Highlighting within Web IDE](../user/project/web_ide/#syntax-highlighting)
* [Project Templates](https://gitlab.com/gitlab-org/project-templates)
* [CI Template Repository](https://gitlab.com/gitlab-org/gitlab-foss/tree/master/lib/gitlab/ci/templates)
* [CI/CD Examples in Docs](../ci/examples/README.md)

### Verify

* [Dependency Caching Examples](../ci/caching/#common-use-cases)
* [Setting Up Unit Test Reports](../ci/unit_test_reports.md#how-to-set-it-up)
* [Code Quality Engines](../user/project/merge_requests/code_quality.md)

### Package

* [Auto DevOps / Heroku Buildpack Support](https://devcenter.heroku.com/articles/buildpacks#officially-supported-buildpacks)
* [Dependency Proxy Support](../user/packages/dependency_proxy/)
* [Package Registry Support](../user/packages/)
* [Package Registry Administration](../administration/packages/


### Configure

* [Feature Flag Client SDKs](https://docs.getunleash.io/sdks/)

### Monitor

* [Sentry Integration SDKs](https://sentry.io/platforms/)

### Secure

* [SAST Supported Languages](../user/application_security/sast/#supported-languages-and-frameworks)
* [Dependency Scanning Supported Languages](../user/application_security/dependency_scanning/#supported-languages-and-package-managers)
* [Coverage Fuzzing Supported Languages](../user/application_security/coverage_fuzzing/#supported-fuzzing-engines-and-languages)
* [DAST Header Validation Examples](../user/application_security/dast/index.md#ruby-on-rails-example-for-on-demand-scan)
