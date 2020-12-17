# Terraform security best practices with GitLab CI

The risks with source code and traditional DevOps CI jobs are minimal since it uses ephemeral environments for testing purposes and any variables or credentials do not usually pose a significant risk to infrastructure or sensitive data.

When using GitLab CI for managing infrastructure, it is important to take a closer look at security and adopt a least privilege and private access mentality. Many aspects of a GitLab project are visible to most project contributors. This documentation allows you to evaluate the best approach for hardening the security of your infrastructure-as-code projects.

NOTE:
We recommend that you start using Terraform with GitLab CI using a simple test project. You should have several months of experience with managing your production infrastructure with Terraform using your local terminal before automating larger Terraform configurations with GitLab CI.

## Types of data

The security best practices in this documentation are primarily focused on the compromise and exposure of sensitive values and credentials.

### Sensitive Values

For the purposes of this documentation, we define "sensitive value" to be any information that could be used by a malicious actor to access or create a vector for attacking your infrastructure. This includes, but is not limited to, the following data types:

* IP addresses
* Hostnames
* DNS addresses
* Usernames
* Passwords
* API keys
* SSH keys
* SSL certificates
* Other infrastructure schemas

### Credentials

Although several data types above are considered credentials, we define "credentials" as the security tokens used by Terraform providers for authentication with cloud providers and other services that create Terraform resources or access data sources. These are usually declared as an environment variable when using infrastructure-as-code. This includes, but is not limited to:

* AWS access key and secret
* GCP service account JSON key file

### Permission levels for Terraform outputs

Due to the verbose nature of Terraform, most of the outputs that Terraform generates in the `terraform plan` and `terraform apply` jobs that run in GitLab CI are exposed in CI job output and artifacts that are accessible to all users that have access to the project. Many of the protection features that GitLab offers are circumvented by Terraform, so additional security precautions and least privilege configuations are needed.

To help protect your infrastructure and sensitive values, this documentation provides best practices to mitigate the exposed values in this table.

| Permission Level                | Source Code | CI Variable | CI Output   | CI Artifact | API Call    |
|---------------------------------|-------------|-------------|-------------|-------------|-------------|
| Public Web (Non-authenticated)  | **Exposed** | No          | **Exposed** | **Exposed** | **Exposed** |
| Guest (Authenticated)           | **Exposed** | No          | **Exposed** | **Exposed** | **Exposed** |
| Reporter                        | **Yes**     | No          | **Exposed** | **Exposed** | **Exposed** |
| Developer                       | **Yes**     | No          | **Yes**     | **Exposed** | **Exposed** |
| Maintainer                      | **Yes**     | **Yes**     | **Yes**     | **Yes**     | **Yes**     |
| Owner                           | **Yes**     | **Yes**     | **Yes**     | **Yes**     | **Yes**     |

## GitLab Projects

Any GitLab project that includes Terraform `.tf` files in your GitLab project should follow the the security best practices included in this documentation.

### GitLab public projects

WARNING:
Any GitLab project with Terraform `.tf` files that uses GitLab CI to run Terraform commands **must be a private or internal project** to avoid exposing credentials or sensitive values that can be used to access and compromise your infrastructure.

You can make a GitLab project public that includes Terraform code if:

1. the project only contains examples, templates, or Terraform modules
2. you do not have a `.gitlab-ci.yml` file unless it is an example and not executable
3. your `.tf` files do not include any sensitive values for real infrastructure
4. you do not have CI variables defined

#### Behind the scenes at GitLab

At GitLab, we have [public projects for many of the Terraform modules](https://gitlab.com/gitlab-com/gl-infra/terraform-modules) that we use to host GitLab.com. Like other modules on the [Terraform registry](https://registry.terraform.io/browse/modules), the GitLab infrastructure modules do not contain any sensitive values in the `.tf` source code. Each Terraform module has a README with variables that are defined when the Terraform modules are consumed in your environment configuration. However, our Terraform configuration that contains all of our environment variables and run GitLab CI jobs are hosted in private projects that have least privilege access.

### GitLab repository mirroring

You can use GitLab [repository mirroring](https://docs.gitlab.com/ee/user/project/repository/repository_mirroring.html) to have the GitLab project with your Terraform source code accessible to team members outside of your least privilege infrastructure team.

Your Terraform source code and CI configuration should be in a private GitLab project (your primary project). You can then use push mirroring to publish the Terraform source code in a another GitLab project (your secondary project) that additional users have access to.

WARNING:
If you configure a repository mirror to a GitLab **public** project, you will expose sensitive values contained in your `.tf` source code files, even if you are not using GitLab CI in that project. You should still use a private project unless the project only contains examples, templates, or Terraform modules that do not contain sensitive values.

### GitLab project members

Your primary GitLab project (that runs GitLab CI) should have the fewest number of project members needed for day-to-day operations to ensure a least privilege security posture. This typically includes but is not limited to the following roles:

* DevOps engineers with elevated responsibilities
* Infrastructure team
* IT server and system administrators
* Security engineers with elevated responsibilities
* Site Reliability Engineers

Your secondary GitLab project (mirror) can have additional project members who should have read-only access to see your Terraform configuration. This may include the following roles:

* Compliance or systems analysts
* DevOps engineers without elevated responsibilities
* Infrastructure and IT managers or executives
* IT support engineers
* Quality assurance engineers
* Security engineers without elevated responsibilities
* Software developers or engineers
* Support engineers for SaaS products

To simplify user and permission administration, it is recommended to use GitLab groups for granting multiple users access to your project(s). See the GitLab documentation for [sharing a project with a group of users](https://docs.gitlab.com/ee/user/project/members/share_project_with_groups.html).

See the GitLab documentation for [project member permissions](https://docs.gitlab.com/ee/user/permissions.html#project-members-permissions) or [group member permissions](https://docs.gitlab.com/ee/user/permissions.html#group-members-permissions) to learn more about the levels of access that you can grant to each team member or group.

### GitLab group inherited permissions

When your project belongs to the group, group members inherit the membership and permission level for the project from the group. In many organizations, most team members have Reporter or Developer permission to the top-level GitLab group. As each team creates sub-groups, these permissions are inheritted for each sub-group and project.

WARNING:
To enforce least privilege access to your primary GitLab project, it is strongly recommended to create a top-level group for sensitive projects that allows you to grant access explictely to each sub-group or project as needed without worrying about top-level permissions for a large number of users (ex. developers) being propogated down to your project with sensitive values.

See the GitLab documentation for [project inherited membership](https://docs.gitlab.com/ee/user/project/members/#inherited-membership) to learn more. You could use [maximum access level](https://docs.gitlab.com/ee/user/project/members/share_project_with_groups.html#maximum-access-level) configuration to limit inherited permissions, however we recommend a top-level group without inherited permissions for this use case.

### GitLab API authentication

You will need a Personal Access Token for GitLab CI to access and update your GitLab-managed Terraform state file with at least `maintainer` [permissions](https://docs.gitlab.com/ee/user/permissions.html#project-members-permissions).

[CI job tokens](https://docs.gitlab.com/ee/user/project/new_ci_build_permissions_model.html#job-token) provide short-term API credentials to the GitLab project. CI job tokens provide read-write access when the user executing the CI pipeline is a Maintainer or Owner. CI job tokens provide read-only access for Developer and below permission levels.

If you're using CI job tokens, you will use the `GITLAB_USER_LOGIN` and `CI_JOB_TOKEN` predefined variables in your `.gitlab-ci.yml` file in the `terraform init` job for the `backend-config` parameters.

Since Terraform managed state requires read-write access, only Maintainers and Owners will be able to run Terraform CI jobs in GitLab projects.

If you have Developer permission or below contributing to your primary GitLab project, the best practice is to create a new GitLab user account and [Personal Access Token](https://docs.gitlab.com/ee/user/profile/personal_access_tokens.html) (license charges apply) or a create [Project Access Token](https://docs.gitlab.com/ee/user/project/settings/project_access_tokens.html) that is considered a service account that only has permissions for the specific project and does not have access to any groups or other projects.

### GitLab project source code

The source code for the environment configuration is accessible to all users, including non-authenticated users if the GitLab project is public. Although most secrets are defined as variables, there is usually sufficient values statically defined in the source code to have an attack vector on existing infrastructure.

It is important to ensure least privilege access for your primary GitLab project and acceptable risk for who gets access to your secondary GitLab project (mirror).

### GitLab CI variables

The CI variables that are declared usually contain credentials for AWS, GCP, and other Terraform providers or infrastructure services that you are creating resources for. The unmasked plain text values of these variables are visible to all project members with Maintainer permissions. Access to your primary GitLab project should be treated with the same level of security as shared SSH keys and passwords for other systems that your infrastructure team manages.

The configuration of your CI variables is not accessible to Reporters and Developers in your primary project, however the CI job outputs include unmasked variables due to the verbose nature of Terraform jobs.

NOTE:
Do not use Protected or Masked variables in Terraform projects. Terraform is not able to interpret **masked** variables due to the nature of file outputs and you will see empty values and error messages that sometimes appear as authentication errors. You will also see errors if using **protected** variables when working in a branch that is running a `terraform init`, `terraform validate`, or `terraform plan` job using GitLab CI. It is recommended to use least privlege access to the primary GitLab project instead.

### GitLab CI artifacts

WARNING:
The GitLab CI artifacts are accessible to all users who have access to the project, including non-authenticated users if the GitLab project is public.

The CI artifacts may include your Terraform state file, sensitive values and credentials. It is recommended to enforce least privilege for your primary GitLab project and use repository mirroring to grant access to the Terraform source code without exposing CI artifacts.

When running the `terraform init` command, a local copy of the remote state is stored in `.terraform/terraform.tfstate`. This state file includes unmasked secrets and environment variables (regardless of CI variable masking), including the API key with Maintainer+ permissions used for accessing the project's remote state that can be used for gaining access using the API to all of the other CI variables, including AWS and GCP credentials.

The `.terraform` directory is included in CI job artifacts so they can be used in subsequent `terraform plan` and `terraform apply` jobs without reinitializing the Terraform state. The CI artifacts are accessible to all users, including non-authenticated users if the GitLab project is public.

### GitLab CI job outputs

WARNING:
The GitLab CI job outputs are accessible to all users who have access to the project, including non-authenticated users if the GitLab project is public.

The CI job outputs include a full inventory of your infrastructure as defined in your Terraform `outputs.tf` file when running `terraform plan` and `terraform apply` jobs, which usually includes sensitive values.

It is recommended to enforce least privilege for your primary GitLab project and use repository mirroring to grant access to the Terraform source code without exposing CI job outputs.

### GitLab Runner cache

[GitLab Runner](https://docs.gitlab.com/runner/) performs data caching that may store sensitive information from your CI jobs. All shared runners on GitLab.com only perform a single job before they are destroyed to mitigate any risk.

If you manage your own GitLab Runner instances, it is recommended to provision a separate Runner without shared cache storage and [configure it as specific to your GitLab project](https://docs.gitlab.com/ee/ci/runners/README.html#specific-runners) so that it is only running your Terraform CI jobs using the local cache on the GitLab Runner instance.

## GitLab managed Terraform state

The security implications of using GitLab managed Terraform state are included in the [GitLab API authentication](#gitlab-api-authentication) and [GitLab projects](#gitlab-projects) documentation above.

See the GitLab documentation for [Terraform state](https://docs.gitlab.com/ee/user/infrastructure/terraform_state.html) to learn more about using Terraform state.

## Terraform Variables

Your Terraform variables are exposed in plain text in GitLab CI jobs, whether they are defined as a `default` in `variables.tf` or as an environment variable using `TF_VAR_my_variable_name`.

Any variables that you define are also stored in plain text in your Terraform state file which can be accessed in CI job artifacts or with an API call to the `/api/v4/projects/{project_id}/terraform/state/{state_name}` endpoint.

## Terraform AWS Provider

This is an overview of security best practices when using the [Terraform AWS provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs).

See the GitLab documentation for [Terraform authentication with GitLab CI](terraform_authentication.html) to learn more about using CI variables and example syntax for your `.gitlab-ci.yml` and `*.tf` files.

### Use a service account with least privilege

You should not use an AWS Access Key for an IAM account with your human username.

You should create a new IAM user account that is a service account for Terraform that is used by your GitLab project. This IAM user account should have least privilege access (not `AdministratorAccess`) to the services that Terraform will access data sources or provision resources for (ex. EC2, Route53, S3).

After your IAM user account has been created, you will need to generate a programmatic access key and secret key pair. It is strongly recommended to set an expiration date for your access key or add to your key rotation schedule.

See the AWS documentation for [Security best practices in IAM](https://docs.aws.amazon.com/IAM/latest/UserGuide/best-practices.html) to learn more. You can also ask your company's infrastructure team or AWS consulting partner for best practices and policies for using least privilege accounts.

### Use AWS environment variables

The Terraform AWS provider uses the `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` environment variables for authenticating with your AWS account. These pre-defined Variables are **only be used at runtime and not stored or outputted**. You cannot rename the keys for the AWS Terraform environment variables.

See the Terraform documentation for [AWS provider authentication](https://registry.terraform.io/providers/hashicorp/aws/latest/docs#authentication) to learn more.

| Variable Key                | Example Value                                 |
|-----------------------------|-----------------------------------------------|
| `AWS_ACCESS_KEY_ID`         | `AKIAIOSFODNN7EXAMPLE`                        |
| `AWS_SECRET_ACCESS_KEY`     | `wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY`    |
| `AWS_DEFAULT_REGION`        | `us-east-1`                                   |

### Do not create Terraform variables for credentials

Do not define static AWS credentials in your source code or create a custom Terraform variable for your AWS credentials since these will be compromised in your `terraform plan` or `terraform apply` outputs that appear in your CI job console output. They may also be compromised if you statically defined them in your source code.

Your Terraform variables are exposed in plain text, whether they are defined as a `default` in `variables.tf` or as an environment variable using `TF_VAR_aws_access_key`.

Any variables that you define are also stored in plain text in your Terraform state file which can be accessed in CI job artifacts or with an API call to the `/api/v4/projects/{project_id}/terraform/state/{state_name}` endpoint.

See the Terraform documentation for [AWS provider environment variables](https://registry.terraform.io/providers/hashicorp/aws/latest/docs#environment-variables) best practices to define environment variables with the pre-defined syntax that will **only be used at runtime and not stored or outputted**.

### Do not use a credentials file

Do not commit a file with your AWS credentials into your source code. Ensure that your `.gitignore` file includes the filename or path of any configuration files or keys that you use for local development and testing.

## Terraform GCP Provider

This is an overview of security best practices when using the [Terraform Google provider](https://registry.terraform.io/providers/hashicorp/google/latest/docs/guides/getting_started).

See the GitLab documentation for [Terraform authentication with GitLab CI](terraform_authentication.html) to learn more about using CI variables and example syntax for your `.gitlab-ci.yml` and `*.tf` files.

### Use a service account with least privilege

You should create a new IAM service account for Terraform that is used by your GitLab project. This IAM service account should have least privilege access (not `Owner` or `Editor`) to the services that Terraform will access data sources or provision resources for (ex. `Compute Instance Admin`, `Service Account User`).

After your IAM service account has been created, you will need to generate a JSON key file. It is strongly recommended to set an expiration date for your key or add to your key rotation schedule.

See the Google documentation for [service accounts](https://cloud.google.com/iam/docs/service-accounts) and [understanding roles](https://cloud.google.com/iam/docs/understanding-roles#predefined_roles) to learn more. You can also ask your company's infrastructure team for best practices and policies for using least privilege accounts.

### Use GCP environment variables

The Terraform Google provider uses the `GOOGLE_APPLICATION_CREDENTIALS` environment variable which is the location of the JSON key file for authenticating with your GCP account. This pre-defined variable is **only be used at runtime and not stored or outputted**. You cannot rename the keys for the GCP Terraform environment variables.

There is a known limitation with Google's API and Terraform provider that you cannot provide a JSON string and it must be a file.

See the Terraform documentation for [Google provider authentication](https://registry.terraform.io/providers/hashicorp/google/latest/docs/guides/provider_reference#authentication) to learn more.

#### GitLab CI File Tpe Variables

> Introduced in GitLab v11.11.

With [file type variables](https://docs.gitlab.com/ee/ci/variables/#custom-environment-variables-of-type-file), you no longer need to use string type variables and create a temporary file using [before_script](https://docs.gitlab.com/ee/ci/yaml/#before_script) in your `.gitlab-ci.yml` file to create a temporary file before the Terraform code runs.

You do not need to remove line breaks from your JSON key file before adding it as a GitLab CI variables.

| Variable Key                            | Example Value                                      |
|-----------------------------------------|----------------------------------------------------|
| `GOOGLE_APPLICATION_CREDENTIALS` (file) | `{ "type": "service_account", ... account.com" }`  |

### Do not create Terraform variables for credentials

Do not define static GCP credentials in your source code or create a custom Terraform variable for your GCP key file JSOn string since this will be compromised in your `terraform plan` or `terraform apply` outputs that appear in your CI job console output. They may also be compromised if you statically defined it in your source code.

Your Terraform variables are exposed in plain text, whether they are defined as a `default` in `variables.tf` or as an environment variable using `TF_VAR_aws_access_key`.

### Do not use a credentials file

Do not commit a file with your GCP service account JSON key into your source code. Ensure that your `.gitignore` file includes the filename or path of any configuration files or keys that you use for local development and testing.

## Additional resources

If you are new to Terraform, we recommend reading the [Terraform documentation](https://www.terraform.io/docs/index.html) and performing the tutorials on [Hashicorp Learn](https://learn.hashicorp.com/terraform?utm_source=terraform_io).

You can search online to learn more about `least privilege` and how to secure your infrastructure, including the [CIS recommendations](https://www.cisecurity.org/controls/controlled-use-of-administrative-privileges/).
