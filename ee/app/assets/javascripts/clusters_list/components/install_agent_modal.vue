<script>
import {
  GlAlert,
  GlButton,
  GlFormGroup,
  GlFormInputGroup,
  GlLink,
  GlModal,
  GlSprintf,
} from '@gitlab/ui';
import ClipboardButton from '~/vue_shared/components/clipboard_button.vue';
import CodeBlock from '~/vue_shared/components/code_block.vue';
import { AGENT_HELP_URLS, INSTALL_AGENT_MODAL_ID, I18N_INSTALL_AGENT_MODAL } from '../constants';
import createAgent from '../graphql/mutations/create_agent.mutation.graphql';
import createAgentToken from '../graphql/mutations/create_agent_token.mutation.graphql';
import AvailableAgentsDropdown from './available_agents_dropdown.vue';

export default {
  modalId: INSTALL_AGENT_MODAL_ID,
  i18n: I18N_INSTALL_AGENT_MODAL,
  helpUrls: AGENT_HELP_URLS,
  components: {
    AvailableAgentsDropdown,
    ClipboardButton,
    CodeBlock,
    GlAlert,
    GlButton,
    GlFormGroup,
    GlFormInputGroup,
    GlLink,
    GlModal,
    GlSprintf,
  },
  inject: ['projectPath', 'kasAddress'],
  data() {
    return {
      projectId: null,
      agent: {
        registered: false,
        registering: false,
        name: null,
        token: null,
        error: null,
      },
    };
  },
  computed: {
    actionButtonText() {
      return this.agent.registered ? this.$options.i18n.done : this.$options.i18n.next;
    },
    actionButtonDisabled() {
      return !this.agent.registering && this.agent.name !== null;
    },
    canCancel() {
      return !this.agent.registered && !this.agent.registering;
    },
    agentRegistrationCommand() {
      return `docker run --pull=always --rm \\
      registry.gitlab.com/gitlab-org/cluster-integration/gitlab-agent/cli:stable generate \\
      --agent-token=${this.agent.token} \\
      --kas-address=${this.kasAddress} \\
      --agent-version stable \\
      --namespace gitlab-kubernetes-agent | kubectl apply -f -`;
    },
  },
  methods: {
    setAgentName(name) {
      this.updateAgent({ name });
    },
    updateAgent(attrs) {
      this.agent = { ...this.agent, ...attrs };
    },
    submit() {
      if (!this.agent.registered) {
        this.registerAgent();
      } else {
        this.$emit('agentRegistered');
        this.hideModal();
      }
    },
    resetModal() {
      this.updateAgent({
        registered: false,
        registering: false,
        name: null,
        token: null,
        error: null,
      });
    },
    hideModal() {
      this.$refs.modal.hide();
    },
    async registerAgent() {
      this.updateAgent({ registering: true, error: null });

      try {
        const {
          data: {
            createClusterAgent: { errors, clusterAgent },
          },
        } = await this.$apollo.mutate({
          mutation: createAgent,
          variables: {
            input: {
              name: this.agent.name,
              projectPath: this.projectPath,
            },
          },
        });

        if (errors?.length > 0) {
          this.updateAgent({ registering: false, error: errors[0] });
        } else {
          this.generateToken(clusterAgent.id);
        }
      } catch {
        this.updateAgent({ registering: false, error: this.$options.i18n.unknownError });
      }
    },
    async generateToken(agendId) {
      try {
        const {
          data: {
            clusterAgentTokenCreate: { errors, secret },
          },
        } = await this.$apollo.mutate({
          mutation: createAgentToken,
          variables: {
            input: {
              clusterAgentId: agendId,
              name: this.agent.name,
            },
          },
        });

        if (errors?.length > 0) {
          this.updateAgent({ registering: false, error: errors[0] });
        } else {
          this.updateAgent({ registered: true, registering: false, token: secret });
        }
      } catch {
        this.updateAgent({ registering: false, error: this.$options.i18n.unknownError });
      }
    },
  },
};
</script>

<template>
  <gl-modal
    ref="modal"
    :modal-id="$options.modalId"
    :title="$options.i18n.modalTitle"
    static
    lazy
    @hidden="resetModal"
  >
    <template v-if="!agent.registered">
      <p>
        <strong>{{ $options.i18n.selectAgentTitle }}</strong>
      </p>

      <p>
        <gl-sprintf :message="$options.i18n.selectAgentBody">
          <template #link="{ content }">
            <gl-link :href="$options.helpUrls.basicInstallUrl" target="_blank">
              {{ content }}</gl-link
            >
          </template>
        </gl-sprintf>
      </p>

      <form>
        <gl-form-group label-for="agent-name">
          <available-agents-dropdown
            class="w-75"
            :is-registering="agent.registering"
            @agentSelected="setAgentName"
          />
        </gl-form-group>
      </form>

      <p v-if="agent.error">
        <gl-alert
          :title="$options.i18n.registrationErrorTitle"
          variant="danger"
          :dismissible="false"
        >
          {{ agent.error }}
        </gl-alert>
      </p>
    </template>

    <template v-else>
      <p>
        <strong>{{ $options.i18n.tokenTitle }}</strong>
      </p>

      <p>
        <gl-sprintf :message="$options.i18n.tokenBody">
          <template #link="{ content }">
            <gl-link :href="$options.helpUrls.basicInstallUrl" target="_blank">
              {{ content }}</gl-link
            >
          </template>
        </gl-sprintf>
      </p>

      <p>
        <gl-alert
          :title="$options.i18n.tokenSingleUseWarningTitle"
          variant="warning"
          :dismissible="false"
        >
          {{ $options.i18n.tokenSingleUseWarningBody }}
        </gl-alert>
      </p>

      <p>
        <gl-form-input-group readonly :value="agent.token" :select-on-click="true">
          <template #append>
            <clipboard-button
              :text="agent.token"
              :title="$options.i18n.copyToken"
              class="btn-clipboard"
            />
          </template>
        </gl-form-input-group>
      </p>

      <p>
        <strong>{{ $options.i18n.basicInstallTitle }}</strong>
      </p>

      <p>
        {{ $options.i18n.basicInstallBody }}
      </p>

      <p>
        <code-block :code="agentRegistrationCommand" />
      </p>

      <p>
        <strong>{{ $options.i18n.advancedInstallTitle }}</strong>
      </p>

      <p>
        <gl-sprintf :message="$options.i18n.advancedInstallBody">
          <template #link="{ content }">
            <gl-link :href="$options.helpUrls.advancedInstallUrl" target="_blank">
              {{ content }}</gl-link
            >
          </template>
        </gl-sprintf>
      </p>
    </template>

    <template #modal-footer>
      <gl-button v-if="canCancel" @click="hideModal">{{ $options.i18n.cancel }} </gl-button>

      <gl-button
        ref="submit"
        :disabled="!actionButtonDisabled"
        variant="confirm"
        category="primary"
        @click="submit"
        >{{ actionButtonText }}
      </gl-button>
    </template>
  </gl-modal>
</template>
