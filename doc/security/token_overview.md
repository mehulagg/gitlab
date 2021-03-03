---
stage: Manage
group: Access
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#assignments
type: reference
---

# GitLab Token overview

This document lists tokens used in GitLab, their purpose and, where applicable, security guidance.

## Personal access tokens

You can create [Personal access tokens](../user/profile/personal_access_tokens.md) to authenticate with:

- The GitLab API.
- GitLab repositories.
- The GitLab registry.

You can limit the scope and expiration date of your personal access tokens. By default,
they inherit permissions from the user who created them.

## OAuth2 tokens

GitLab can serve as an [OAuth2 provider](../api/oauth2.md) to allow other services to access the GitLab API on a user’s behalf.

You can limit the scope and lifetime of your OAuth2 tokens.

## Impersonation tokens

[Impersonation tokens](../api/README.md#impersonation-tokens) are a type of personal access token that can be created only by an administrator for a specific user. They can be useful if you want to build applications or scripts that authenticate with the GitLab API, repositories and the GitLab registry as a specific user.

Impersonation tokens can be limited in scope and expiration time. They inherit their permissions from the user they were created for.

## Project access tokens

[Project access tokens](../user/project/settings/project_access_tokens.md#project-access-tokens)
are scoped to a project. As with [Personal access tokens](#personal-access-tokens), you can use them to authenticate with:

- The GitLab API.
- GitLab repositories.
- The GitLab registry.

You can limit the scope and expiration date of project access tokens. When you
create a project access token, GitLab creates a [project bot user](../user/project/settings/project_access_tokens.md#project-bot-users). Project
bot users are service accounts and do not count as licensed seats.

## Deploy tokens

[Deploy tokens](../user/project/deploy_tokens/index.md) allow you to download (`git clone`) or push and pull packages and container registry images of a project without having a user and a password. Deploy tokens cannot be used with the GitLab API.

Deploy tokens can be managed by project maintainers and owners.

## Deploy keys

[Deploy keys](../user/project/deploy_keys/index.md) allow read-only or read-write access to your repositories by importing an SSH public key into your GitLab instance. Deploy keys cannot be used with the GitLab API or the registry.

This is useful, for example, for cloning repositories to your Continuous Integration (CI) server. By using deploy keys, you don’t have to set up a fake user account.

Project maintainers and owners can add or enable a deploy key for a project repository

## Runner registration tokens

Runner registration tokens are used to [register](https://docs.gitlab.com/runner/register/) a [runner](https://docs.gitlab.com/runner/) with GitLab. Group or project owners or instance admins can obtain them through GitLab interfaces. The registration token is limited to runner registration and has no further scope.

Because it can be used to add new runners that may execute jobs in a project or group and thus have access to the project’s code, careful consideration should be given as to who has project or group owner-level permissions.

We are [actively working on security improvements](https://gitlab.com/gitlab-org/gitlab-runner/-/issues/25351) to the runner API.

## Runner authentication tokens (also called runner tokens)

After registration, the runner will receive an authentication token used to authenticate with GitLab when picking up jobs from the job queue. The authentication token is stored locally in the Runner's [`config.toml`](https://docs.gitlab.com/runner/configuration/advanced-configuration.html) file.

After authentication with GitLab, the Runner will receive a [job token](../user/project/new_ci_build_permissions_model.md#job-token) to execute the job.

In case of Docker Machine/Kubernetes/VirtualBox/Parallels/SSH executors, the execution environment has no access to the runner authentication token as it stays on the runner machine. They have only access to the job token, which is needed to execute the job.

Malicious access to a runner's file system may expose the `config.toml` file and thus the authentication token, allowing an attacker to [clone the runner](https://docs.gitlab.com/runner/security/#cloning-a-runner).

## CI/CD job tokens

The [CI/CD](../api/README.md#gitlab-ci-job-token) job token
is a short lived token only valid for the duration of a job. It gives a CI/CD job
access to a limited amount of [API endpoints](../api/README.md#gitlab-ci-job-token).
API authentication uses the job token, by using the authorization of the user
triggering the job.

The job token is secured by its short life-time and limited scope. It could possibly be leaked if multiple jobs run on the same machine ([like with the shell runner](https://docs.gitlab.com/runner/security/#usage-of-shell-executor)). On Docker Machine runners, configuring [`MaxBuilds=1`](https://docs.gitlab.com/runner/configuration/advanced-configuration.html#the-runnersmachine-section) is recommended to make sure runner machines only ever run one build and are destroyed afterwards. This may impact performance, as provisioning machines takes some time.

## Available scopes

This table shows available scopes per token. Scopes can be limited further on token creation.

|                             | API Access | Registry Access | Repository Access |
|-----------------------------|------------|-----------------|-------------------|
| Personal Access Token       | ✅          | ✅               | ✅                 |
| OAuth2 Token                | ✅          | 🚫               | ✅                 |
| Impersonation Token         | ✅          | ✅               | ✅                 |
| Project Access Token        | ✅(1)       | ✅(1)            | ✅(1)              |
| Deploy Token                | 🚫          | ✅               | ✅                 |
| Deploy Key                  | 🚫          | 🚫               | ✅                 |
| Runner Registration Token   | 🚫          | 🚫               | 🚫                 |
| Runner Authentication Token | 🚫          | 🚫               | 🚫                 |
| Job Token                   | ✴️(2)       | 🚫               | 🚫                 |

1. Limited to the one project.
1. Limited to certain [endpoints](../api/README.md#gitlab-ci-job-token).
