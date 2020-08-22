---
type: index, dev
stage: none
group: Development
info: "See the Technical Writers assigned to Development Guidelines: https://about.gitlab.com/handbook/engineering/ux/technical-writing/#assignments-to-development-guidelines"
---

# Feature flags in development of GitLab

[Feature Flags](../../operations/feature_flags.md)
can be used to gradually roll out changes, be
it a new feature, or a performance improvement. By using feature flags, we can
comfortably measure the impact of our changes, while still being able to easily
disable those changes, without having to revert an entire release.

Before using feature flags for GitLab's development, read through the following:

- [Process for using features flags](process.md).
- [Developing with feature flags](development.md).
- [Controlling feature flags](controls.md).
- [Documenting features deployed behind feature flags](../documentation/feature_flags.md).
- [How GitLab administrators can enable and disable features behind flags](../../administration/feature_flags.md).
