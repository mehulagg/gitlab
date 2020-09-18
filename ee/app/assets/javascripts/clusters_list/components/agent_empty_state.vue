<script>
import { GlButton, GlEmptyState, GlLink } from '@gitlab/ui';

export default {
  components: {
    GlButton,
    GlEmptyState,
    GlLink,
  },
  props: {
    image: {
      type: String,
      required: true,
    },
  },
};
</script>

<template>
  <gl-empty-state
    :svg-path="image"
    :title="s__('ClusterAgents|Integrate Kubernetes with a GitLab Agent')"
    :description="
      s__(
        'ClusterAgents|The GitLab Kubernetes Agent allows an Infrastructure as Code, GitOps approach to integrating Kubernetes clusters with GitLab. Learn more about the GitLab Kubernetes Agent.',
      )
    "
  >
    <template #actions>
      <gl-link href="https://docs.gitlab.com/ee/user/clusters/agent/" target="_blank">
        {{ s__('ClusterAgents|Learn about managing your clusters with a GitLab Agent') }}
      </gl-link>

      <gl-button
        category="primary"
        variant="success"
        href="https://docs.gitlab.com/ee/user/clusters/agent/#installing-the-agent-server-via-helm"
        target="_blank"
      >
        {{ s__('ClusterAgents|Integrate with the GitLab Agent') }}
      </gl-button>
    </template>
  </gl-empty-state>
</template>
