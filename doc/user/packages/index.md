---
stage: Package
group: Package
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#designated-technical-writers
---

# Packages & Registries

The GitLab [Package Registry](package_registry/index.md) acts as a private or public registry
for a variety of common package managers. You can publish and share
packages, which can be easily consumed as a dependency in downstream projects.

| Format | Status |
| ------ | ------ |
| [Composer](composer_repository/index.md) | 13.2+  |
| [Conan](conan_repository/index.md) | 12.6+  |
| [Generic packages](generic_packages/index.md) | 13.5+  |
| [Go](go_proxy/index.md) | 13.1+  |
| [Maven](maven_repository/index.md) | 11.3+  |
| [NPM](npm_registry/index.md) | 11.8+  |
| [NuGet](nuget_repository/index.md) | 12.10+  |
| [PyPI](pypi_repository/index.md) | [Accepting Merge Requests](../../development/packages.md)  |
| [Chef](https://gitlab.com/gitlab-org/gitlab/-/issues/36889) | [Accepting Merge Requests](../../development/packages.md) |
| [CocoaPods](https://gitlab.com/gitlab-org/gitlab/-/issues/36890) | [Accepting Merge Requests](../../development/packages.md) |
| [Conda](https://gitlab.com/gitlab-org/gitlab/-/issues/36891) | [Accepting Merge Requests](../../development/packages.md) |
| [CRAN](https://gitlab.com/gitlab-org/gitlab/-/issues/36892) | [Accepting Merge Requests](../../development/packages.md) |
| [Debian](https://gitlab.com/gitlab-org/gitlab/-/issues/5835) | [WIP: Community Contribution](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/44746) |
| [Opkg](https://gitlab.com/gitlab-org/gitlab/-/issues/36894) | [Accepting Merge Requests](../../development/packages.md) |
| [P2](https://gitlab.com/gitlab-org/gitlab/-/issues/36895) | [Accepting Merge Requests](../../development/packages.md) |
| [Puppet](https://gitlab.com/gitlab-org/gitlab/-/issues/36897) | [Accepting Merge Requests](../../development/packages.md) |
| [RPM](https://gitlab.com/gitlab-org/gitlab/-/issues/5932) | [Accepting Merge Requests](../../development/packages.md) |
| [RubyGems](https://gitlab.com/gitlab-org/gitlab/-/issues/803) | [Accepting Merge Requests](../../development/packages.md) |
| [SBT](https://gitlab.com/gitlab-org/gitlab/-/issues/36898) | [Accepting Merge Requests](../../development/packages.md) |
| [Vagrant](https://gitlab.com/gitlab-org/gitlab/-/issues/36899) | [Accepting Merge Requests](../../development/packages.md) |

You can also use the [API](../../api/packages.md) to administer the Package Registry.

The GitLab [Container Registry](container_registry/index.md) is a secure and private registry for container images.
It's built on open source software and completely integrated within GitLab.
Use GitLab CI/CD to create and publish images. Use the GitLab [API](../../api/container_registry.md) to
manage the registry across groups and projects.

The [Dependency Proxy](dependency_proxy/index.md) is a local proxy for frequently-used upstream images and packages.
