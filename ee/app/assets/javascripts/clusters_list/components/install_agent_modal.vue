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
import glFeatureFlagsMixin from '~/vue_shared/mixins/gl_feature_flags_mixin';
import { AGENT_HELP_URLS, INSTALL_AGENT_MODAL_ID, I18N_INSTALL_AGENT_MODAL } from '../constants';
import AvailableAgentsDropdown from './available_agents_dropdown.vue';
import createAgent from '../graphql/mutations/create_agent.mutation.graphql';
import createAgentToken from '../graphql/mutations/create_agent_token.mutation.graphql';
import ClipboardButton from '~/vue_shared/components/clipboard_button.vue';
import CodeBlock from '~/vue_shared/components/code_block.vue';

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
  mixins: [glFeatureFlagsMixin()],
  props: {
    projectPath: {
      required: true,
      type: String,
    },
    kasAddress: {
      required: true,
      type: String,
    },
  },
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
      return !this.agent.registered;
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
      this.agent.name = name;
    },
    submit() {
      if (!this.agent.registered) {
        this.registerAgent();
      } else {
        this.hideModal();
      }
    },
    resetModal() {
      this.agent = {
        registered: false,
        registering: false,
        name: null,
        token: null,
        error: null,
      };
    },
    hideModal() {
      this.$refs.modal.hide();
    },
    registerAgent() {
      this.agent.error = null;
      this.agent.registering = true;

      return this.$apollo
        .mutate({
          mutation: createAgent,
          variables: {
            input: {
              name: this.agent.name,
              projectPath: this.projectPath,
            },
          },
        })
        .then(({ data }) => {
          const { errors, clusterAgent } = data.createClusterAgent;
          if (errors?.length > 0) {
            this.agent.error = errors[0];
            this.agent.registering = false;
            return;
          }

          this.generateToken(clusterAgent.id);
        })
        .catch((err) => {
          this.agent.registering = false;
          this.agent.error = this.$options.i18n.unknownError;
        });
    },
    generateToken(agendId) {
      return this.$apollo
        .mutate({
          mutation: createAgentToken,
          variables: {
            input: {
              clusterAgentId: agendId,
              name: `${this.agent.name}-token`,
            },
          },
        })
        .then(({ data }) => {
          const { errors, secret } = data.clusterAgentTokenCreate;
          this.agent.registering = false;

          if (errors?.length > 0) {
            this.agent.error = errors[0];
            return;
          }

          this.agent.registered = true;
          this.agent.token = secret;
        })
        .catch((err) => {
          this.agent.registering = false;
          this.agent.error = this.$options.i18n.unknownError;
        });
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
            :projectPath="projectPath"
            :registeringAgent="agent.registering"
            @agentSelected="setAgentName"
          />
        </gl-form-group>
      </form>

      <p v-if="this.agent.error">
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
        <gl-form-input-group readonly :value="agent.token">
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
      <gl-button @click="hideModal" v-if="canCancel">{{ $options.i18n.cancel }} </gl-button>

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
