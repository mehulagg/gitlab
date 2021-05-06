---
stage: Verify
group: Continuous Integration
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#assignments
type: reference, howto
---

# External Pipeline Validation

You can use an external service to validate a pipeline before it's created.

WARNING:
This is an experimental feature and subject to change without notice.

## Usage

GitLab sends a POST request to the external service URL with the pipeline
data as payload. GitLab then invalidates the pipeline based on the response
code. If there's an error or the request times out, the pipeline is not
invalidated.

Response codes:

- `200`: Accepted
- `4XX`: Not accepted
- All other codes: accepted and logged

### Service Result

Pipelines not accepted by the external validation service are failed. They are visible in pipeline lists with errors, in either the GitLab user interface or API. Creating an unaccepted pipeline when using the GitLab user interface displays an error message that states: `Pipeline cannot be run. External validation failed`

## Configuration

To configure external pipeline validation, add the
[`EXTERNAL_VALIDATION_SERVICE_URL` environment variable](environment_variables.md)
and set it to the external service URL.

By default, requests to the external service time out after five seconds. To override
the default, set the `EXTERNAL_VALIDATION_SERVICE_TIMEOUT` environment variable to the
required number of seconds.

## Payload Schema

```json
{
  "type": "object",
  "required" : [
    "project",
    "user",
    "pipeline",
    "builds",
    "namespace"
  ],
  "properties" : {
    "project": {
      "type": "object",
      "required": [
        "id",
        "path",
        "created_at"
      ],
      "properties": {
        "id": { "type": "integer" },
        "path": { "type": "string" },
        "created_at": { "type": ["string", "null"], "format": "date-time" }
      }
    },
    "user": {
      "type": "object",
      "required": [
        "id",
        "username",
        "email",
        "created_at"
      ],
      "properties": {
        "id": { "type": "integer" },
        "username": { "type": "string" },
        "email": { "type": "string" },
        "created_at": { "type": ["string", "null"], "format": "date-time" }
      }
    },
    "pipeline": {
      "type": "object",
      "required": [
        "sha",
        "ref",
        "type"
      ],
      "properties": {
        "sha": { "type": "string" },
        "ref": { "type": "string" },
        "type": { "type": "string" }
      }
    },
    "builds": {
      "type": "array",
      "items": {
        "type": "object",
        "required": [
          "name",
          "stage",
          "image",
          "services",
          "script"
        ],
        "properties": {
          "name": { "type": "string" },
          "stage": { "type": "string" },
          "image": { "type": ["string", "null"] },
          "services": {
            "type": ["array", "null"],
            "items": { "type": "string" }
          },
          "script": {
            "type": "array",
            "items": { "type": "string" }
          }
        }
      }
    },
    "namespace": {
      "type": "object",
      "required": [
        "plan",
        "trial"
      ],
      "properties": {
        "plan": { "type": "string" },
        "trial": { "type": "boolean" }
      }
    }
  }
}
```

The `namespace` field is only available in [GitLab Premium](https://about.gitlab.com/pricing/)
and higher.
