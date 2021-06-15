---
stage: verify
group: group::pipeline authoring
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#assignments
comments: false
description: 'Next iteration of CI/CD Template architecture at GitLab'
---

# CI/CD Composable Task

## Publisher project

Project structure:

```
.gitlab/
  ci-composable-task/
    task-name-1/
      spec.yml
    task-name-2/
      spec.yml
```

- `.gitlab-ci.yml`
- dependencies
  - bash scripts
  - bins
  - Dockerfiles
  - Helm charts

```yml
### The `.gitlab-ci.yml` to be directly `!reference`d to a job.
job-spec:
  image: registry.gitlab.com/group/project/image:v2.6.0
  script:
    - do the thing...
  artifacts:
    paths:
      - foo/bar.bin

### The section to be directly `!reference`d to a job.
metadata:
  name: Ruby Test
  desc: This executes `rspec`
  author/maintainer: 
  inputs:
    - type: variable
      name: FOO
      required: true
    - type: artifact
      path: foo/bar.yml
      required: true
  outputs:
    - type: artifact
      path: foo/bar.bin
```

Forbidden keywords:

- `rules`/`only`/`except` ... These keywords should be defined in the CI/CD Workflow 
- `stage` ... These keywords should be defined in the CI/CD Workflow 

## Consumer project

Consumer project has `.gitlab-ci.yml` as their CI/CD workflow.

_Example:_

```yml
workflow:
  rules:
    - if: $CI_MERGE_REQUEST_IID
    - if: $CI_COMMIT_TAG
    - if: $CI_COMMIT_BRANCH == $CI_DEFAULT_BRANCH

build:
  stage: build
  script: echo

test:
  stage: test
  script: echo

rspec:
  composed-from: 'group/project/task-name:v1.0'
  stage: test
  # Forbidden keywords can be used here.
  # `rules`/`only`/`except`
  # `stage`

deploy:
  stage: deploy
  script: echo
  rules:
    - if: $CI_COMMIT_BRANCH == $CI_DEFAULT_BRANCH
```

## CI/CD Workflow template

TBD