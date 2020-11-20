---
stage: Configure
group: Configure
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#designated-technical-writers
---

# Kubernetes Agent configuration repository **(PREMIUM ONLY)**

The GitLab Kubernetes Agent integration supports hosting your configuration for
multiple GitLab Kubernetes Agents in a single repository. These agents can be running
in the same cluster or in multiple clusters, and potentially with more than one Agent per cluster.

The Agent bootstraps with the GitLab installation URL and an authentication token,
and you provide the rest of the configuration in your repository, following
Infrastructure as Code (IaaC) best practices.

