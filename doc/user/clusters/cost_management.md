---
stage: Configure
group: Configure
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#designated-technical-writers
---

# Cluster Cost Management

NOTE: **Note:**
GitLab has basic support for cluster cost management. 

Cluster cost management provides insights into cluster resource usage. 

## Getting Started

For getting started, we provide an example project that uses GitLab's Prometheus integration and [kubecost's `cost-model`](https://github.com/kubecost/cost-model).

### Clone our example repository

Clone our [example repository](https://gitlab.com/gitlab-examples/kubecost-cost-model/). This repository contains minor modifications to the upstream kubecost `cost-model`. Namely, 

- it configure your Prometheus endpoint to the GitLab Managed Prometheus, you might need to change this if you use a non-managed Prometheus; See the next section for details. 
- it changes the Google Pricing API access key to GitLab's access key.
- it contains definitions for a custom GitLab Metrics dashboard to show the cost insights.

### Setting up Prometheus integration

GitLab provides several ways to connect GitLab with Prometheus. If you already have Prometheus set up, it can be added to GitLab under a project's settings. Navigate to Settings / Integrations / Prometheus to provide the API endpoint of your Prometheus server. If you'd prefer to use GitLab Managed Prometheus, navigate to your cluster's details page. You can install Prometheus under the "Applications" tab. This will set up the previously mentioned integration being Auto configured.

The Prometheus integration should be set up on the cloned example project.

### Deploying `cost-model`

The kubecost `cost-model` should be added to your cluster either manually or using GitLab CI/CD if you have a non-managed cluster. The following description is for manual deployment.

```
kubectl create namespace cost-model
kubectl apply -f kubernetes/ --namespace cost-model
```

## Accessing cost insights

Navigate to Operations / Metrics and select the "default_costs.yml" dashboard.