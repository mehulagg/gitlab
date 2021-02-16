---
stage: Release
group: Release
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#assignments
---

# Getting started with ECS deployment **(FREE)**

This step-by-step guide helps you use [ECS deployment](../index.md#deploy-your-application-to-the-aws-elastic-container-service-ecs)
to deploy a project hosted on GitLab.com to Elastic Container Service on AWS.

GitLab doesn't have a native AWS integration yet, so you have to create an ECS
cluster manually using the AWS console.
You are creating and deploying a simple application that you create from a GitLab template.

These instructions also work for a self-managed GitLab instance;
ensure your own [runners are configured](../../ci/runners/README.md).

## Configure your AWS account

Before creating and connecting your ECS cluster to your GitLab project,
you need a [AWS account](https://aws.amazon.com/premiumsupport/knowledge-center/create-and-activate-aws-account/).
Sign in with an existing AWS account or create a new one.

## Initial Setup

### Create a new project from a template

We are using a GitLab project template to get started. As the name suggests,
those projects provide a bare-bones application built on some well-known frameworks.

1. In GitLab, click the plus icon (**{plus-square}**) at the top of the navigation bar, and select
   **New project**.
1. Go to the **Create from template** tab, where you can choose among a Ruby on
   Rails, Spring, or NodeJS Express project.
   For this tutorial, use the Ruby on Rails template.

   ![Select project template](img/guide_project_template_v12_3.png)

1. Give your project a name, optionally a description, and make it public so that
   you can take advantage of the features available in the
   [GitLab Ultimate plan](https://about.gitlab.com/pricing/).

   ![Create project](img/guide_create_project_v12_3.png)

1. Click **Create project**.

Now that you've created a project, create the ECS cluster
to deploy this project to.

### Push a docker image to GitLab's Container Registry

1. Click "Setup up CI/CD"
1. Create .gitlab-ci.yml with ECS Deploy template
  ```yaml
  include:
    - template: AWS/Deploy-ECS.gitlab-ci.yml
  ```
1. Click "Commit Change"
1. A new pipeline automatically starts running.
   `build` job creates a docker image with herokuish (Automatic Containerization Tool)
   and push it to GitLab's Container Registry.

NOTES:
- The pipeline will fail at deployment stage because ECS Cluster is not connected yet.
  We'll fix this later.

Now that you've created a docker image, create the ECS cluster
to deploy this project to.

### Create an initial task definition

1. Login to AWS console in web browser
1. Go to ECS > Task Definitions
1. Click "Create new Task Definition"
1. Click EC2
1. Task Definition Name: "sm-ado-rails-app"
1. Task Memory/CPU: 512
1. Click Add Container
  1. Name: web
  1. Image: registry.gitlab.com/shinya.maeda/ecs-deploy-test/master:latest
1. Port Mapping: 80:5000
1. Command: `bin/herokuish,procfile,start,web`
# 1. Set Env Var
  # (Optional) RAILS_LOG_TO_STDOUT: ENABLE
  # (Optional) PORT: 80
# 1. STORAGE AND LOGGING > Auto-configure CloudWatch Logs > Check
1. Create

NOTES:
- Having ECS Cluster might cause a cost you.

### Create ECS cluster

1. Click "Create Cluster"
1. Choose "EC2 Linux + Networking"
1. Name: sm-ado-app
1. (Optional) Set Key Pair to "sm-ubuntu-2" 
1. (Optional) Set default VPC (vpc-b) and existing subnets
1. Create

### Create ECS Service

1. Click the created cluster
1. Choose "Services" tab
1. Click "Create"
1. Launch Type: EC2
1. Task Definition: sm-ado-rails-app
1. Service Name: sm-ado-rails-app
1. Number of Tasks: 1
1. Create Service

### See the instance

1. Go to the ECS cluster
1. Choose "ECS Instances"
1. Click the Instance Id
1. Open Public IPv4 DNS in your browser via HTTP (e.g. `http://ec2-18-216-45-152.us-east-2.compute.amazonaws.com`)
   Not HTTPS.
1. Now you see the app running

## Setup Continuous Deployment

### Create a deployer user on AWS

1. Login to AWS console in web browser
1. Go to IAM
1. Click "Users"
1. Click "Add user"
  1. User name: "sm-ado-rails-app-3"
  1. Check "Programmatic access"
  1. Next
1. Click "Attach existing policies directly"
1. Check "AmazonECS_FullAccess"
1. Next
1. Next Review
1. Create User
1. Take a note secrets 
  - Access key ID: REDACTED
  - Secret: REDACTED

### Setup credentials in GitLab to let Runners access to the ECS cluster

1. Settings > Variables > Add Variable
  AWS_ACCESS_KEY_ID: REDACTED
  AWS_SECRET_ACCESS_KEY: REDACTED
  AWS_DEFAULT_REGION: us-east-2
  CI_AWS_ECS_CLUSTER: sm-ado-app
  CI_AWS_ECS_SERVICE: sm-ado-rails-app-3
  CI_AWS_ECS_TASK_DEFINITION: sm-ado-rails-app-3

### Re-run deployment pipelines

1. Open app > views >welcome > index.html.erb
1. Click "Edit"
1. Change it to "You're on ECS!"
1. Click "Commit Changes"
1. Wait for the pipeline finished.
   This pipeline builds and push a new docker image with the latest application change.
   Later, it updates the docker image in the ECS task definition and service.

## Conclusion

ECS deployments is

For findiing more cloud deployment solutions, please see the [cloud deployment main page](../index.md)

## Trouble shooting

### The maximum number of internet gateways has been reached.

If you failed at CloudFormation Stack by the following error:
Failed  { The maximum number of internet gateways has been reached. (Service: AmazonEC2; Status Code: 400; Error Code: InternetGatewayLimitExceeded; Request ID: b1406b7c-a6be-42f7-92b4-a5a48af4864f; Proxy: null) }
