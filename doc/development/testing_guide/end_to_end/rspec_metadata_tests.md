# RSpec metadata for end-to-end tests

This is a partial list of the [RSpec metadata](https://relishapp.com/rspec/rspec-core/docs/metadata/user-defined-metadata)
(a.k.a. tags) that are used in our end-to-end tests.

<!-- Please keep the tags in alphabetical order -->

| Tag | Description |
|-----|-------------|
| `:elasticsearch`  | The test requires an Elasticsearch service. It is used by the [instance-level scenario](https://gitlab.com/gitlab-org/gitlab-qa#definitions) [`Test::Integration::Elasticsearch`](https://gitlab.com/gitlab-org/gitlab/-/blob/72b62b51bdf513e2936301cb6c7c91ec27c35b4d/qa/qa/ee/scenario/test/integration/elasticsearch.rb) to include only tests that require Elasticsearch. |
| `:gitaly_cluster` | The test will run against a GitLab instance where repositories are stored on redundant Gitaly nodes behind a Praefect node. All nodes are [separate containers](../../../administration/gitaly/praefect.md#requirements-for-configuring-a-gitaly-cluster). Tests that use this tag have a longer setup time since there are three additional containers that need to be started. |
| `:jira`           | The test requires a Jira Server. [GitLab-QA](https://gitlab.com/gitlab-org/gitlab-qa) will provision the Jira Server in a Docker container when the `Test::Integration::Jira` test scenario is run.
| `:kubernetes`     | The test includes a GitLab instance that is configured to be run behind an SSH tunnel, allowing a TLS-accessible GitLab. This test will also include provisioning of at least one Kubernetes cluster to test against. *This tag is often be paired with `:orchestrated`.* |
| `:only`           | The test is only to be run against specific environments or pipelines. See [Environment selection](environment_selection.md) for more information. |
| `:orchestrated`   | The GitLab instance under test may be [configured by `gitlab-qa`](https://gitlab.com/gitlab-org/gitlab-qa/-/blob/master/docs/what_tests_can_be_run.md#orchestrated-tests) to be different to the default GitLab configuration, or `gitlab-qa` may launch additional services in separate Docker containers, or both. Tests tagged with `:orchestrated` are excluded when testing environments where we can't dynamically modify GitLab's configuration (for example, Staging). |
| `:quarantine`     | The test has been [quarantined](https://about.gitlab.com/handbook/engineering/quality/guidelines/debugging-qa-test-failures/#quarantining-tests), will run in a separate job that only includes quarantined tests, and is allowed to fail. The test will be skipped in its regular job so that if it fails it will not hold up the pipeline. Note that you can also [quarantine a test only when it runs against specific environment](environment_selection.md#quarantining-a-test-for-a-specific-environment). |
| `:reliable`       | The test has been [promoted to a reliable test](https://about.gitlab.com/handbook/engineering/quality/guidelines/reliable-tests/#promoting-an-existing-test-to-reliable) meaning it passes consistently in all pipelines, including merge requests. |
| `:requires_admin` | The test requires an admin account. Tests with the tag are excluded when run against Canary and Production environments. |
| `:runner`         | The test depends on and will set up a GitLab Runner instance, typically to run a pipeline. |
| `:skip_live_env`  | The test will be excluded when run against live deployed environments such as Staging, Canary, and Production. |
| `:testcase`       | The link to the test case issue in the [Quality Testcases project](https://gitlab.com/gitlab-org/quality/testcases/). |
| `:mattermost`     | The test requires a GitLab Mattermost service on the GitLab instance |
| `:ldap_no_server` | The test requires a GitLab instance to be configured to use LDAP. To be used with the `:orchestrated` tag. Uses a docker LDAP server image. |
| `:ldap_no_tls`    | The test requires a GitLab instance to be configured to use an external LDAP server with TLS not enabled. |
| `:ldap_tls`       | The test requires a GitLab instance to be configured to use an external LDAP server with TLS enabled. |
| `:object_storage` | The test requires a GitLab instance to be configured to use multiple [object storage types](https://docs.gitlab.com/ee/administration/object_storage.html). Uses MinIO as the object storage server. |
| `:smtp`           | The test requires a GitLab instance to be configured to use an SMTP server.  Tests SMTP notification email delivery from Gitlab by using MailHog. |
| `:group_saml`     | The test requires a GitLab instance that has SAML SSO enabled. Interacts with an external SAML identity provider. This is configured at the group-level. Paired with the `:orchestrated` tag.  |
| `:saml`           | The test requires a GitLab instance that has SAML enabled. Interacts with an external SAML identity provider. This is configured at the instance-level. Paired with the `:orchestrated` tag. |
| `:skip_signup_disabled` | - |
| `:smoke`          | The test belongs to the test suite which verifies basic functionality of a GitLab instance.   |
| `:github`         | The test requires a GitHub personal access token. |
| `:repository_storage` |  The test requires a GitLab instance to be configured to use multiple [repository storage paths](https://docs.gitlab.com/ee/administration/repository_storage_paths.html). Paired with the `:orchestrated` tag. |
| `:geo`            | The test requires two GitLab Geo instances - a primary and a secondary - to be spun up. |
| `:relative_url`   | The test requires a GitLab instance to be installed under a [relative URL](https://docs.gitlab.com/ee/install/relative_url.html). |
| `:requires_git_protocol_v2`   | - |
| `:requires_praefect`   | - |
| `:packages`   | The test requires a GitLab instance that has the [Package Registry](https://docs.gitlab.com/ee/administration/packages/#gitlab-package-registry-administration) enabled. |
