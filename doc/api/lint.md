---
stage: Verify
group: Continuous Integration
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#designated-technical-writers
---

# CI Lint API

## Validate the CI YAML config

> [Introduced](https://gitlab.com/gitlab-org/gitlab-foss/-/merge_requests/5953) in GitLab 8.12.

Checks if CI/CD YAML configuration is valid. This endpoint validates basic CI/CD
configuration syntax. It doesn't have any namespace specific context.

```plaintext
POST /ci/lint
```

| Attribute  | Type    | Required | Description |
| ---------- | ------- | -------- | -------- |
| `content`              | string     | yes      | The CI/CD configuration content. |
| `include_merged_yaml`  | boolean    | no       | If the [expanded CI/CD configuration](#yaml-expansion) should be included in the response. |

```shell
curl --header "Content-Type: application/json" "https://gitlab.example.com/api/v4/ci/lint" --data '{"content": "{ \"image\": \"ruby:2.6\", \"services\": [\"postgres\"], \"before_script\": [\"bundle install\", \"bundle exec rake db:create\"], \"variables\": {\"DB_NAME\": \"postgres\"}, \"types\": [\"test\", \"deploy\", \"notify\"], \"rspec\": { \"script\": \"rake spec\", \"tags\": [\"ruby\", \"postgres\"], \"only\": [\"branches\"]}}"}'
```

Be sure to paste the exact contents of your GitLab CI/CD YAML config because YAML
is very sensitive about indentation and spacing.

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

### YAML expansion

The expansion only works for CI configurations that don't have local [includes](../ci/yaml/README.md#include). 
`extends:` is also not yet merged in the result.

Example contents of a `.gitlab-ci.yml` passed to the CI Lint API with
`include_merged_yaml` set as true:

```yaml
include:
  remote: 'https://example.com/remote.yaml'

test:
  stage: test
  script:
    - echo 1
```

Example contents of `https://example.com/remote.yaml`:

```yaml
another_test:
  stage: test
  script:
    - echo 2
```

Example response:

```json
{
  "status": "valid",
  "errors": [],
  "merged_config": "---\n:another_test:\n  :stage: test\n  :script: echo 2\n:test:\n  :stage: test\n  :script: echo 1\n"
}
```

### Use jq to create and process YAML & JSON Payloads

To `POST` a YAML configuration to the CI Lint endpoint, it must be properly escaped and JSON encoded.
You can use `jq` and `curl` to escape and upload YAML to the GitLab API.

### Escape YAML for JSON encoding

To escape quotes and encode your YAML in a format suitable for embedding within
a JSON payload, you can use `jq`. For example, create a file named `example-gitlab-ci.yml`:

```shell
cat >example-gitlab-ci.yml <<EOL
.api_test:
  rules:
    - if: '$CI_PIPELINE_SOURCE=="merge_request_event"'
      changes:
        - src/api/*
deploy:
  extends:
    - .api_test
  rules:
    - when: manual
      allow_failure: true
  script:
    - echo "hello world"
EOL
```

Next, use `jq` to escape and appropriately JSON ecode this YAML file:

```shell
jq --raw-input --slurp < example-gitlab-ci.yml
```

### Escape, encode and post a YAML file

To escape and encode an input YAML file (`example-gitlab-ci.yml`), and `POST` it to the
GitLab API using `curl` and `jq` in a one-line command:

```shell
jq --null-input --arg yaml "$(<example-gitlab-ci.yml)" '.content=$yaml' \
| curl 'https://gitlab.com/api/v4/ci/lint?include_merged_yaml=true' \
--header 'Content-Type: application/json' \
--data @-
```

### Parse a CI Lint response

To reformat the CI Lint response, you can use `jq`. You can pipe the CI Lint response to jq,
or store the API response as a text file and provide it as an argument:

```shell
jq --raw-output '.merged_yaml | fromjson' <your_input_here>
```

Example input:

```json
{"status":"valid","errors":[],"merged_yaml":"---\n:.api_test:\n  :rules:\n  - :if: $CI_PIPELINE_SOURCE==\"merge_request_event\"\n    :changes:\n    - src/api/*\n:deploy:\n  :rules:\n  - :when: manual\n    :allow_failure: true\n  :extends:\n  - \".api_test\"\n  :script:\n  - echo \"hello world\"\n"}
```

Becomes:

```yaml
:.api_test:
  :rules:
  - :if: $CI_PIPELINE_SOURCE=="merge_request_event"
    :changes:
    - src/api/*
:deploy:
  :rules:
  - :when: manual
    :allow_failure: true
  :extends:
  - ".api_test"
  :script:
  - echo "hello world"
```

All steps can be combined and run using the below command:

```shell
jq --null-input --arg yaml "$(<example-gitlab-ci.yml)" '.content=$yaml' \
| curl 'https://gitlab.com/api/v4/ci/lint?include_merged_yaml=true' \
--header 'Content-Type: application/json' --data @- \
| jq --raw-output '.merged_yaml | fromjson'
```
