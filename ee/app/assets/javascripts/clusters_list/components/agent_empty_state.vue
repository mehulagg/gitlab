<script>
import { GlButton, GlEmptyState, GlLink, GlSprintf, GlModalDirective } from '@gitlab/ui';
import { INSTALL_AGENT_MODAL_ID } from '../constants';

export default {
  modalId: INSTALL_AGENT_MODAL_ID,
  components: {
    GlButton,
    GlEmptyState,
    GlLink,
    GlSprintf,
  },
  directives: {
    GlModalDirective,
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
  >
    <template #description>
      <p>
        <gl-sprintf
          :message="
            s__(
              'ClusterAgents|The GitLab Kubernetes Agent allows an Infrastructure as Code, GitOps approach to integrating Kubernetes clusters with GitLab. %{linkStart}Learn more.%{linkEnd}',
            )
          "
        >
          <template #link="{ content }">
            <gl-link href="https://docs.gitlab.com/ee/user/clusters/agent/" target="_blank">
              {{ content }}
            </gl-link>
          </template>
        </gl-sprintf>
      </p>

      <p>
        <gl-sprintf
          :message="
            s__(
              'ClusterAgents|The GitLab Agent also requires %{linkStart}enabling the Agent Server%{linkEnd}',
            )
          "
        >
          <template #link="{ content }">
            <gl-link
              href="https://docs.gitlab.com/ee/user/clusters/agent/#install-the-agent-server"
              target="_blank"
            >
              {{ content }}
            </gl-link>
          </template>
        </gl-sprintf>
      </p>
    </template>

    <template #actions>
      <gl-button
        ref="install-agent"
        v-gl-modal-directive="$options.modalId"
        class="gl-mr-3"
        data-qa-selector="TODO"
        variant="success"
        category="primary"
        >{{ s__('ClusterAgents|Integrate with the GitLab Agent') }}
      </gl-button>
    </template>
  </gl-empty-state>
</template>
