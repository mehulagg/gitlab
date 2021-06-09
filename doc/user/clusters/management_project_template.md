---
stage: Configure
group: Configure
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#assignments
---

# Cluster Management Project Template **(FREE)**

> [Introduced](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/25318) in GitLab 12.10 with Helmfile support via Helm v2.
> [Improved](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/63577) in GitLab 14.0 with Helmfile support via Helm v3 instead, and a much more flexible usage of Helmfile. This introduces breaking changes that are detailed below.

This project template provides a quick-start for users interested in managing cluster
applications via [Helm v3](https://helm.sh/) charts. Most specifically, taking advantage of the
[Helmfile](https://github.com/roboll/helmfile) utility client.

## How to use this template

Requirements:

- Connect a cluster with gitlab
- configure a management cluster

This template it's currently designed to be compatible with a [Cluster management project](https://docs.gitlab.com/ee/user/clusters/management_project.html). It comprehends a set of [Helmfiles]() that aim to facilitate the management of certain apps that we believe can integrate well and add value to the services you deploy via GitLab. Still, you have full control and flexibility to customize this template, so to add new applications or even delete the ones you do not care about.

Here you'll find:

- a predefined `.gitlab-ci.yml`, with a CI pipeline already configured.
- a main `helmfile` to toggle which applications you would like to manage.
- an `/applications` folder with the `helmfile` configured for each app we provide.

If you have existing appls deployed either via Gitlab managed apps One click install or via CI/CD install, please refer to [Migrating from GitLab managed apps](#migrating-from-gitlab-managed-apps).

### The `.gitlab-ci.yml`

The base image used in your pipeline is built by the [cluster-applications](https://gitlab.com/gitlab-org/cluster-integration/cluster-applications) project. This image comprises a set of Bash utility scripts to support [Helm v3 releases](https://helm.sh/docs/intro/using_helm/#three-big-concepts). They are:

- `./gl-fail-if-helm2-releases-exist {namespace}`: It tries to detect whether you have apps deployed through Helm v2 releases for a given namespace. If so, it will fail the pipeline and ask you to manually [migrate your Helm v2 releases to Helm v3](https://helm.sh/docs/topics/v2_v3_migration/).

- `./gl-ensure-namespace {namespace}`: It creates the given namespace if it does not exist and adds the necessary label for [Cilium]() network policies to work.
- ``


### The main [`helmfile.yml`]()

This file has a list of paths to sub-helmfiles for each app. They're all commented out by default. You must uncomment the paths for the apps that you'd like to manage.

Each sub-path


### Available applications

The available applications are the same as GitLab Man...

- Ingress
- ...


### Migrating from GitLab managed apps (GMA)

Move to a new page

We can break down the migration in X main steps:

1. Detect apps deployed through Helm v2 releases.

   For this, you can simply rely on the preconfigure [`.gitlab-ci.yml`](#the-gitlab-ci-yml). In case you had ovewritten the default GMA namespace, just make sure that the [`./gl-fail-if-helm2-releases-exist`]() script is receiving the correct namespace as an argument. If you kept the default (`gitlab-managed-apps`), the the script is already setup. So, manually trigger the pipeline and read the logs of the `detect-helm2-releases` job to know if you need to migrate any releases.

1. Migrate your Helm v2 releases, if any. Follow the official Helm docs on [how to migrate from Helm v2 to Helm v3](https://helm.sh/blog/migrate-from-helm-v2-to-helm-v3/).
1. For each app, edit the Helmfiles in this repo to match the chart version currently deployed for those apps with. Take GitLab runner as an example:

   ```bash
   ~> helm ls -n gitlab-managed-apps
NAME              	NAMESPACE          	REVISION	UPDATED                                	STATUS  	CHART                     	APP VERSION
runner       	gitlab-managed-apps	1       	2021-06-07 22:47:47.977375105 +0000 UTC	deployed	runner-v0.10.1      	v0.10.1
   ```
   
   Take the version from the `CHART` column whic is in the format `{release}-v{chart_version}`. Then edit the `version:` attribute for the ingress release helmfile inside this repo at [`./applications/ingress/helmfile.yaml`]() to match the version you have deployed.

1. For each app, edit the `values.yaml` in this repo to match the currently deployed values for your apps. E.g. for GitLab Runner:

   Copy the output of below command, which might be big:
   
   ```bash
   ~> helm get values certmanager -n gitlab-managed-apps -a --output yaml
   
   ```


1. Trigger a new pipeline to validate that everything worked as expected.

#### Special cases

##### Ingress

##### Certmanager

##### vault
