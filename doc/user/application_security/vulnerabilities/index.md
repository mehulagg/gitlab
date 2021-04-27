---
type: reference, howto
stage: Secure
group: Threat Insights
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#assignments
---

# Vulnerability Pages **(ULTIMATE)**

> [Introduced](https://gitlab.com/gitlab-org/gitlab/-/issues/13561) in [GitLab Ultimate](https://about.gitlab.com/pricing/) 13.0.

Each security vulnerability in a project's [Vulnerability Report](../vulnerability_report/index.md) has an individual page which includes:

- Details of the vulnerability.
- The status of the vulnerability within the project.
- Available actions for the vulnerability.
- Any issues related to the vulnerability.

On the vulnerability's page, you can:

- [Change the vulnerability's status](#change-vulnerability-status).
- [Create an issue](#create-an-issue-for-a-vulnerability).
- [Link issues to the vulnerability](#link-gitlab-issues-to-the-vulnerability).
- [Automatically remediate the vulnerability](#automatically-remediate-the-vulnerability), if an
  automatic solution is available.

## Change vulnerability status

You can change the status of a vulnerability using the **Status** dropdown to one of
the following values:

| Status    | Description                                                                                                    |
|-----------|----------------------------------------------------------------------------------------------------------------|
| Detected  | The default state for a newly discovered vulnerability                                                         |
| Confirmed | A user has seen this vulnerability and confirmed it to be accurate                                             |
| Dismissed | A user has seen this vulnerability and dismissed it because it is not accurate or otherwise not to be resolved |
| Resolved  | The vulnerability has been fixed and is no longer valid                                                        |

A timeline shows you when the vulnerability status has changed
and allows you to comment on a change.

## Create an issue for a vulnerability

From a vulnerability's page you can create an issue to track all action taken to resolve or
mitigate it.

From a vulnerability you can create either:

- [A GitLab issue](#create-a-gitlab-issue-for-a-vulnerability) (default).
- [A Jira issue](#create-a-jira-issue-for-a-vulnerability).

Creating a Jira issue requires that
[Jira integration](../../../integration/jira/index.md) is enabled on the project. Note
that when Jira integration is enabled, the GitLab issue feature is not available.

### Create a GitLab issue for a vulnerability

To create a GitLab issue for a vulnerability:

1. In GitLab, go to the vulnerability's page.
1. Select **Create issue**.

An issue is created in the project, prepopulated with information from the vulnerability report.
The issue is then opened so you can take further action.

### Create a Jira issue for a vulnerability

> - [Introduced](https://gitlab.com/groups/gitlab-org/-/epics/4677) in GitLab 13.9.
> - It's [deployed behind a feature flag](../../../user/feature_flags.md), enabled by default.
> - It's enabled on GitLab.com.
> - It's recommended for production use.
> - For GitLab self-managed instances, GitLab administrators can opt to
>   [disable it](#enable-or-disable-jira-integration-for-vulnerabilities).

WARNING:
This feature might not be available to you. Check the **version history** note above for details.

Prerequisites:

- [Enable Jira integration](../../project/integrations/jira.md).
  The **Enable Jira issues creation from vulnerabilities** option must be selected as part of the configuration.
- Each user must have a personal Jira user account with permission to create issues in the target project.

To create a Jira issue for a vulnerability:

1. Go to the vulnerability's page.
1. Select **Create Jira issue**.
1. If you're not already logged in to Jira, log in.

The Jira issue is created and opened in a new browser tab. The **Summary** and **Description**
fields are pre-populated from the vulnerability's details.

### Enable or disable Jira integration for vulnerabilities **(ULTIMATE SELF)**

The option to create a Jira issue for a vulnerability is under development but ready for production
use. It is deployed behind a feature flag that is **enabled by default**.
[GitLab administrators with access to the GitLab Rails console](../../../administration/feature_flags.md)
can opt to disable it.

To enable it:

```ruby
Feature.enable(:jira_for_vulnerabilities)
```

To disable it:

```ruby
Feature.disable(:jira_for_vulnerabilities)
```

## Link GitLab issues to the vulnerability

NOTE:
If Jira issue support is enabled, GitLab issues are disabled so this feature is not available.

You can link one or more existing GitLab issues to the vulnerability. This allows you to
indicate that this vulnerability affects multiple issues. It also allows you to indicate
that the resolution of one issue would resolve multiple vulnerabilities.

Linked issues are shown in the Vulnerability Report and the vulnerability's page.

## Automatically remediate the vulnerability

You can fix some vulnerabilities by applying the solution that GitLab automatically
generates for you. [Read more about the automatic remediation for vulnerabilities feature](../index.md#apply-an-automatic-remediation-for-a-vulnerability).

## Vulnerability scanner maintenance

The vulnerability scanners, and their databases, are updated regularly.

| Secure scanning tool                                         | Vulnerabilities database updates          |
|:-------------------------------------------------------------|-------------------------------------------|
| [Container Scanning](container_scanning/index.md)            | Uses `clair`. The latest `clair-db` version is used for each job by running the [`latest` Docker image tag](https://gitlab.com/gitlab-org/gitlab/blob/438a0a56dc0882f22bdd82e700554525f552d91b/lib/gitlab/ci/templates/Security/Container-Scanning.gitlab-ci.yml#L37). The `clair-db` database [is updated daily according to the author](https://github.com/arminc/clair-local-scan#clair-server-or-local). |
| [Dependency Scanning](dependency_scanning/index.md)          | Relies on `bundler-audit` (for Ruby gems), `retire.js` (for npm packages), and `gemnasium` (the GitLab tool for all libraries). Both `bundler-audit` and `retire.js` fetch their vulnerabilities data from GitHub repositories, so vulnerabilities added to `ruby-advisory-db` and `retire.js` are immediately available. The tools themselves are updated once per month if there's a new version. The [Gemnasium DB](https://gitlab.com/gitlab-org/security-products/gemnasium-db) is updated at least once a week. See our [current measurement of time from CVE being issued to our product being updated](https://about.gitlab.com/handbook/engineering/development/performance-indicators/#cve-issue-to-update). |
| [Dynamic Application Security Testing (DAST)](dast/index.md) | The scanning engine is updated on a periodic basis. See the [version of the underlying tool `zaproxy`](https://gitlab.com/gitlab-org/security-products/dast/blob/master/Dockerfile#L1). The scanning rules are downloaded at scan runtime. |
| [Static Application Security Testing (SAST)](sast/index.md)  | Relies exclusively on [the tools GitLab wraps](../sast/index.md#supported-languages-and-frameworks). The underlying analyzers are updated at least once per month if a relevant update is available. The vulnerabilities database is updated by the upstream tools. |

You do not have to update GitLab to benefit from the latest vulnerabilities definitions.
The security tools are released as Docker images. The vendored job definitions that enable them use
major release tags according to [Semantic Versioning](https://semver.org/). Each new release of the
tools overrides these tags.
The Docker images are updated to match the previous GitLab releases. You automatically get the
latest versions of the scanning tools. There are some known issues
with this approach, however, and there is a
[plan to resolve them](https://gitlab.com/gitlab-org/gitlab/-/issues/9725).
