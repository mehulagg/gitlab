---
stage: Configure
group: Configure
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#assignments
---

# CI/CD Tunnel

> [Introduced](https://gitlab.com/gitlab-org/gitlab/-/issues/327409) in GitLab 14.0.

The CI/CD Tunnel enables users to access Kubernetes clusters from GitLab CI/CD jobs even if there is no network
connectivity between GitLab Runner and a cluster. GitLab Runner does not have to be running in the same cluster.

In the current iteration, only CI/CD jobs in the Configuration project are able to access one of the configured agents.

Prerequisites:

- A running [`kas` instance](index.md#set-up-the-kubernetes-agent-server).
- A [Configuration repository](index.md#define-a-configuration-repository) with an Agent config file
  installed (`.gitlab/agents/<agent-name>/config.yaml`).
- An [Agent record](index.md#create-an-agent-record-in-gitlab).
- The agent is [installed in the cluster](index.md#install-the-agent-into-the-cluster).

To access Kubernetes from your CI/CD job:

1. In your `.gitlab-ci.yml` add a section that creates a `kubectl` compatible configuration file and use it in one
   or more jobs:

   ```yaml
   variables:
     AGENT_ID: 4 # agent id that you got when you created the agent record
     KUBE_CFG_FILE: "$CI_PROJECT_DIR/.kubeconfig.agent.yaml"

   .kubectl_config: &kubectl_config
     - |
       cat << EOF > "$KUBE_CFG_FILE"
       apiVersion: v1
       kind: Config
       clusters:
       - cluster:
           server: https://kas.gitlab.com/k8s-proxy
         name: agent
       users:
       - name: agent
         user:
           token: "ci:$AGENT_ID:$CI_JOB_TOKEN"
       contexts:
       - context:
           cluster: agent
           user: agent
         name: agent
       current-context: agent
       EOF

   deploy:
     image:
       name: bitnami/kubectl:latest
       entrypoint: [""]
     script:
     - *kubectl_config
     - kubectl --kubeconfig="$KUBE_CFG_FILE" get pods
   ```

1. Execute `kubectl` commands directly against your cluster with this CI/CD job you just created.

We are working to [automate the configuration file creation](https://gitlab.com/gitlab-org/gitlab/-/issues/324275)
to simplify the process.
