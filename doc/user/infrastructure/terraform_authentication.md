---
stage: Configure
group: Configure
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#assignments
---

# Terraform authentication with GitLab CI

TODO

## Environment variables quick reference

[GitLab CI variables](../../ci/variables/README.md) are the equivalent of Terraform environment variables when running Terraform commands using GitLab CI.

### GitLab CI variables quick reference

You can [define custom CI variables](../../ci/variables/README.md#create-a-custom-variable-in-the-ui) in the GitLab project by navigating to **Settings > CI/CD** and expanding the **Variables** section. You do not need to include both AWS and GCP credentials if you are only using one of these cloud providers.

You can declare a Terraform environment variable for any variables defined in `variables.tf` by prefixing the Terraform variable name with `TF_VAR_` and setting the CI variable `Key` to `TF_VAR_my_variable_name`. The variables that are prefixed with `TF_VAR_` in the documentation examples are for illustrative purposes and are not required. See the [Terraform environment variable docs](https://www.terraform.io/docs/configuration/variables.html#environment-variables) to learn more.

| Variable Key                     | Type     | Example Value                                             |
|----------------------------------|----------|-----------------------------------------------------------|
| `TF_STATE_FILE`                  | Variable | `production`                                              |
| `TF_STATE_GITLAB_USER`           | Variable | `my-project-service-account` or `project_{id}_bot{count}` |
| `TF_STATE_GITLAB_ACCESS_TOKEN`   | Variable | `A1b2C3d4_e5F6g7H8i90`                                    |
| `AWS_ACCESS_KEY_ID`              | Variable | `AKIAIOSFODNN7EXAMPLE`                                    |
| `AWS_SECRET_ACCESS_KEY`          | Variable | `wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY`                |
| `AWS_DEFAULT_REGION`             | Variable | `us-east-1`                                               |
| `GOOGLE_APPLICATION_CREDENTIALS` | File     | `{ "type": "service_account", ... account.com" }`         |
| `TF_VAR_gcp_project`             | Variable | `gcp-project-name` or `123456789012`                      |
| `TF_VAR_gcp_region`              | Variable | `us-east1`                                                |
| `TF_VAR_gcp_region_zone`         | Variable | `us-east1-c`                                              |

### Terraform variables quick reference

```hcl
# [my-project]/variables.tf

variable "gcp_project" {
  type        = string
  description = "The GCP project ID (may be a alphanumeric slug) that the resources are deployed in. (Example: my-project-name)"
}

variable "gcp_region" {
  type        = string
  description = "The GCP region that the resources will be deployed in. (Ex. us-east1)"
}

variable "gcp_region_zone" {
  type        = string
  description = "The GCP region availability zone that the resources will be deployed in. This must match the region. (Example: us-east1-c)"
}
```

## AWS

TODO

[Terraform Provider Documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)

### AWS security best practices

- Do not define static AWS credentials in your source code or create a custom Terraform variable for your AWS credentials, because these are compromised in your `terraform plan` or `terraform apply` outputs, source code, or stored in plain text in your Terraform state file. Your Terraform variables are exposed in plain text, whether they are defined as a `default` in `variables.tf` or as an environment variable using `TF_VAR_aws_access_key`. We recommend following the [Terraform provider documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs#environment-variables) best practices to define environment variables with the pre-defined syntax that is **only be used at runtime and not stored or outputted**. You cannot rename the keys for the AWS Terraform environment variables.
- Do not commit a file with your AWS credentials into your source code. Ensure that your `.gitignore` file includes the filename or path of any configuration files or keys that you use for local development and testing.
- You should not use an AWS Access Key for an IAM account with your human username. You should create a new IAM user account that is a service account for Terraform that is used by your GitLab project. This IAM user account should have least privilege access (not `AdministratorAccess`) to the services that Terraform accesses the data sources or provision resources for (ex. EC2, Route53, S3). Please contact your company's infrastructure team or AWS consulting partner for best practices and policies on least privilege accounts.

### AWS CI variables for authentication

Use the [AWS IAM User Guide documentation](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_users_create.html) to create a new IAM user account with programmatic access.

| Variable Key                | Example Value                                 |
|-----------------------------|-----------------------------------------------|
| `AWS_ACCESS_KEY_ID`         | `AKIAIOSFODNN7EXAMPLE`                        |
| `AWS_SECRET_ACCESS_KEY`     | `wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY`    |
| `AWS_DEFAULT_REGION`        | `us-east-1`                                   |

### AWS CI variables for account meta data

You should store the AWS Account # and IAM username associated with this access key in your system administration password manager vault. If you would like to document this information inside of your GitLab project in a secure way, you can add the following **optional** CI variables. These are visible to `maintainers` and `owners` in your GitLab project in the CI variable configuration, however they are not used in `.gitlab-ci.yml` unless you explicitly add them to a job's script or in an image.

| Optional Variable Key       | Example Value                                 |
|-----------------------------|-----------------------------------------------|
| `AWS_ACCOUNT_ID`            | `123456789012`                                |
| `AWS_IAM_USERNAME`          | `my-terraform-service-account`                |

### AWS Terraform example configuration

```hcl
# [my-project]/main.tf

# Terraform Backend Configuration with GitLab managed remote state
# -----------------------------------------------------------------------------
# See .gitlab-ci.yml jobs that use terraform-init -backend-config variables.

terraform {
  backend "http" {
    lock_method    = "POST"
    unlock_method  = "DELETE"
    retry_wait_min = 5
  }
}

# Define AWS Terraform provider
# -----------------------------------------------------------------------------
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs

provider "aws" {
  version = "~> 3.0"
  region  = "us-east-1"
}
```

```hcl
# [my-project]/variables.tf

# DO NOT create variables for your AWS credentials as shown in this
# bad practice example. DO NOT COPY THIS EXAMPLE INTO YOUR CODE.

variable "aws_access_key" {
  type = "string"
  description = "Your AWS Access Key (ex. AKIAIOSFODNN7EXAMPLE)"
}

variable "aws_access_key_secret" {
  type = "string"
  description = "Your AWS Access Key Secret"
}
```

## GCP

The [Google Terraform provider]((https://registry.terraform.io/providers/hashicorp/google/latest/docs/guides/getting_started)) uses the environment variable `GOOGLE_APPLICATION_CREDENTIALS` which is the location of the JSON key file.

There is a known limitation with Google's API and Terraform provider that you cannot provide a JSON string and it must be a file.

> Introduced in GitLab v11.11.

With [file type variables](../../ci/variables/README.md#custom-environment-variables-of-type-file), you no longer need to use string type variables and create a temporary file using [before_script](../../ci/yaml/README.md#before_script) in your `.gitlab-ci.yml` file to create a temporary file before the Terraform code runs.

### Security Best Practices

- Do not create a custom Terraform variable for your GCP service account credentials because these become compromised in your `terraform plan` or `terraform apply` outputs, source code, or stored in plain text in your Terraform state file. Your Terraform variables are exposed in plain text, whether they are defined as a `default` in `variables.tf` or as an environment variable using `TF_VAR_gcp_service_json`. This project's implementation follows the [Terraform provider documentation](https://registry.terraform.io/providers/hashicorp/google/latest/docs/guides/provider_reference#authentication) best practices to define environment variables with the pre-defined syntax that are **only be used at runtime and not stored or outputted**. You cannot rename the keys for the GCP Terraform environment variables.
- Do not commit the JSON file with your GCP service account credentials into your source code. Ensure that your `.gitignore` file includes the filename or path of any JSON keys that you use for local development and testing.
- You should ensure that the service account has least privilege roles (not `Owner` or `Editor`) for the services (such as `Compute Instance Admin`, and `Kubernetes Engine Admin`) that Terraform provisions resources for. Your Terraform output displays errors in your Terraform output if you are missing the necessary permissions. Please contact your company's infrastructure team or [GCP documentation](https://cloud.google.com/iam/docs/understanding-roles) for best practices and policies on least privilege accounts.

### GCP CI variables for authentication

In your GitLab project, navigate to **Settings > CI/CD** and expand the **Variables** section.

Add a new CI variable with the key `GOOGLE_APPLICATION_CREDENTIALS` and copy/paste the contents of your JSON file. You do not need to remove the line breaks (minify) the JSON contents or worry about formatting when pasting into the CI variable value.

| Variable Key                            | Example Value                                      |
|-----------------------------------------|----------------------------------------------------|
| `GOOGLE_APPLICATION_CREDENTIALS` (file) | `{ "type": "service_account", ... account.com" }`  |

### GCP Terraform example configuration

```hcl
# [my-project]/main.tf

# Terraform Backend Configuration with GitLab managed remote state
# -----------------------------------------------------------------------------
# See .gitlab-ci.yml jobs that use terraform-init -backend-config variables.

terraform {
  backend "http" {
    lock_method    = "POST"
    unlock_method  = "DELETE"
    retry_wait_min = 5
  }
}

# Define Google Terraform providers
# -----------------------------------------------------------------------------
# https://registry.terraform.io/providers/hashicorp/google/latest/docs/guides/getting_started

# Define the Google Cloud Provider
provider "google" {
  project     = var.gcp_project
  version     = "~>3.47"
}

# Define the Google Cloud Provider with beta features
provider "google-beta" {
  project     = var.gcp_project
  version     = "~>3.47"
}
```

```hcl
# [my-project]/variables.tf

variable "gcp_project" {
  type        = string
  description = "The GCP project ID (may be a alphanumeric slug) that the resources are deployed in. (Example: my-project-name)"
}

variable "gcp_region" {
  type        = string
  description = "The GCP region that the resources will be deployed in. (Ex. us-east1)"
}

variable "gcp_region_zone" {
  type        = string
  description = "The GCP region availability zone that the resources will be deployed in. This must match the region. (Example: us-east1-c)"
}
```

## GitLab API and Terraform State

You need a Personal Access Token for GitLab CI to access and update your GitLab-managed Terraform state file with at least `maintainer` [permissions](../user/permissions.md#project-members-permissions).

The best practice is to create a new GitLab user account and [Personal Access Token](../user/profile/personal_access_tokens.md) (license charges apply) or a [Project Access Token](../user/project/settings/project_access_tokens.md) that is considered a service account that only has permissions for the specific project and does not have access to any groups or other projects.

**FAQ: Why can't we use CI job tokens?** [CI job tokens](../user/project/new_ci_build_permissions_model.md#job-token) are read only and do not have write permissions which are needed for modifying the Terraform managed state. In other words, we cannot use the `GITLAB_USER_LOGIN` and `CI_JOB_TOKEN` predefined variables. The workaround is to define the GitLab username or Project Access Token username (`project_{project_id}_bot{bot_count}`) and Personal Access Token as a CI variable that are used for updating the state file.

### GitLab Inherited Predefined Environment Variables

[GitLab Documentation](../../ci/variables/predefined_variables.md)

The following variables in the `.gitlab-ci.yml` example file are GitLab predefined variables for all CI pipelines. You do not need to define these variables in your project and they are provided here for educational reference only.

| Variable Key             | Example Output                                   |
|--------------------------|--------------------------------------------------|
| `CI_API_V4_URL`          | `https://gitlab.com/api/v4/`                     |
| `CI_PROJECT_ID`          | `12345`                                          |

### GitLab Managed Terraform State

[GitLab Documentation](../user/infrastructure/terraform_state.md)

[Terraform Backend Documentation](https://www.terraform.io/docs/configuration/backend.html)

The `terraform {}` block does not allow named values (like input variables, locals, or data source attributes) for security reasons, so you need to use the `-backend-config="key=value"` argument when running `terraform init`.

```hcl
# main.tf

terraform {
  backend "http" {
    lock_method    = "POST"
    unlock_method  = "DELETE"
    retry_wait_min = 5
  }
}
```

When using an HTTP backend configuration with your local Terminal, you would pass the variables during the `terraform init` command to pass in dynamic values.

```bash
# Local Terminal

terraform init \
    -backend-config="address=https://gitlab.com/api/v4/projects/<YOUR-PROJECT-ID>/terraform/state/<YOUR-STATE-NAME>" \
    -backend-config="lock_address=https://gitlab.com/api/v4/projects/<YOUR-PROJECT-ID>/terraform/state/<YOUR-STATE-NAME>/lock" \
    -backend-config="unlock_address=https://gitlab.com/api/v4/projects/<YOUR-PROJECT-ID>/terraform/state/<YOUR-STATE-NAME>/lock" \
    -backend-config="username=<YOUR-USERNAME>" \
    -backend-config="password=<YOUR-ACCESS-TOKEN>" \
    -backend-config="lock_method=POST" \
    -backend-config="unlock_method=DELETE" \
    -backend-config="retry_wait_min=5"
```

With GitLab CI, this is defined as a script run during a CI job.

```yaml
# .gitlab-ci.yml

stages:
  - init

tf init:
  stage: init
  image: hashicorp/terraform:light
  entrypoint:
    - '/usr/bin/env'
    - 'PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin'
  script:
    - |
      terraform init
      -backend-config="address=${CI_API_V4_URL}/${CI_PROJECT_ID}/terraform/state/${TF_STATE_FILE}"
      -backend-config="lock_address=${CI_API_V4_URL}/${CI_PROJECT_ID}/terraform/state/${TF_STATE_FILE}/lock"
      -backend-config="unlock_address=${CI_API_V4_URL}/${CI_PROJECT_ID}/terraform/state/${TF_STATE_FILE}/lock"
      -backend-config="username=${TF_STATE_GITLAB_USER}"
      -backend-config="password=${TF_STATE_GITLAB_ACCESS_TOKEN}"
  artifacts:
    paths:
      - .terraform
```

This opinionated example uses the `|` pipe character to allow for a multi-line script for human readability, however this is not required and you can put this on one line or refactor using [variables](../../ci/yaml/README.md#variables) and [extends](../../ci/yaml/README.md#extends).

```yaml
tf init:
  script:
  - terraform init -backend-config="address=${CI_API_V4_URL}/${CI_PROJECT_ID}/terraform/state/${TF_STATE_FILE}" -backend-config="lock_address=${CI_API_V4_URL}/${CI_PROJECT_ID}/terraform/state/${TF_STATE_FILE}/lock" -backend-config="unlock_address=${CI_API_V4_URL}/${CI_PROJECT_ID}/terraform/state/${TF_STATE_FILE}/lock" -backend-config="username=${TF_STATE_GITLAB_USER}" -backend-config="password=${TF_STATE_GITLAB_ACCESS_TOKEN}"
```
