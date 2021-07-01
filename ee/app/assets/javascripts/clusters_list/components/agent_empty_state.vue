<script>
import { GlButton, GlEmptyState, GlLink, GlSprintf, GlAlert } from '@gitlab/ui';

export default {
  components: {
    GlButton,
    GlEmptyState,
    GlLink,
    GlSprintf,
    GlAlert,
  },
  props: {
    image: {
      type: String,
      required: true,
    },
    projectPath: {
      type: String,
      required: true,
    },
    hasConfigurations: {
      type: Boolean,
      required: true,
    },
  },
  methods: {
    getProjectPath() {
      return `/${this.projectPath}`;
    },
  },
};
</script>

<template>
  <gl-empty-state
    :svg-path="image"
    :title="s__('ClusterAgents|Integrate Kubernetes with a GitLab Agent')"
    class="empty-state--agent"
  >
    <template #description>
      <p class="mw-460 gl-mx-auto">
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

      <p class="mw-460 gl-mx-auto">
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

      <gl-alert
        v-if="!hasConfigurations"
        variant="warning"
        class="gl-mb-5 text-left"
        :dismissible="false"
      >
        {{
          s__(
            'ClusterAgents|To install an Agent you should create an agent directory in the Repository first. We recommend that you add the Agent configuration to the directory before you start the installation process.',
          )
        }}

        <template #actions>
          <gl-button
            category="primary"
            variant="info"
            href="https://docs.gitlab.com/ee/user/clusters/agent/#define-a-configuration-repository"
            target="_blank"
          >
            {{ s__('ClusterAgents|Read more about getting started') }}
          </gl-button>
          <gl-button category="secondary" variant="info" :href="getProjectPath()">
            {{ s__('ClusterAgents|Go to the repository') }}
          </gl-button>
        </template>
      </gl-alert>
    </template>

    <template #actions>
      <gl-button
        :disabled="!hasConfigurations"
        data-testid="integration-primary-button"
        category="primary"
        variant="success"
        href="https://docs.gitlab.com/ee/user/clusters/agent/#get-started-with-gitops-and-the-gitlab-agent"
        target="_blank"
      >
        {{ s__('ClusterAgents|Integrate with the GitLab Agent') }}
      </gl-button>
    </template>
  </gl-empty-state>
</template>
