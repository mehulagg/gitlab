---
stage: Verify
group: Continuous Integration
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#designated-technical-writers
---

# Validate the CI YAML config (API)

> [Introduced](https://gitlab.com/gitlab-org/gitlab-foss/-/merge_requests/5953) in GitLab 8.12.

Checks if your CI YAML config is valid. This endpoint is useful when validating
basic logic and syntax of your CI config. It doesn't have any namespace specific
context.

```plaintext
POST /ci/lint
```

| Attribute  | Type    | Required | Description |
| ---------- | ------- | -------- | -------- |
| `content`              | string     | yes      | the `.gitlab-ci.yaml` content|
| `include_merged_yaml`  | boolean    | no       | Whether to include the
expanded CI config in the response or not. |

```shell
curl --header "Content-Type: application/json" "https://gitlab.example.com/api/v4/ci/lint" --data '{"content": "{ \"image\": \"ruby:2.6\", \"services\": [\"postgres\"], \"before_script\": [\"bundle install\", \"bundle exec rake db:create\"], \"variables\": {\"DB_NAME\": \"postgres\"}, \"types\": [\"test\", \"deploy\", \"notify\"], \"rspec\": { \"script\": \"rake spec\", \"tags\": [\"ruby\", \"postgres\"], \"only\": [\"branches\"]}}"}'
```

Be sure to paste the exact contents of your GitLab CI YAML config since YAML is
very sensitive about indentation and spaces.

Example responses:

- Valid content:

  ```json
  {
    "status": "valid",
    "errors": []
  }
  ```

- Invalid content:

  ```json
  {
    "status": "invalid",
    "errors": [
      "variables config should be a hash of key value pairs"
    ]
  }
  ```

- Without the content attribute:

  ```json
  {
    "error": "content is missing"
  }
  ```

## YAML expansion example

The expansion works only for project-agnostic CI configurations, i.e.
configurations that don't have local includes.

`.gitlab-ci.yml`

```yaml
include:
  remote: 'https://example.com/remote.yaml'

test:
  stage: test
  script:
    - echo 1
```

`https://example.com/remote.yaml`

```yaml
another_test:
  stage: test
  script:
    - echo 2
```

Example response:

  ```json
  {
    "status": "valid"
    "errors": [],
    "merged_config": "---\n:another_test:\n  :stage: test\n  :script: echo 2\n:test:\n  :stage: test\n  :script: echo 1\n"
  }
  ```
