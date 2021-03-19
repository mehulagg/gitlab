<script>
import { GlButton, GlModal, GlModalDirective, GlSprintf } from '@gitlab/ui';

export default {
  components: {
    GlModal,
    GlSprintf,
    GlButton,
  },
  directives: {
    GlModal: GlModalDirective,
  },
  inject: ['token', 'revokePath', 'buttonClass'],
  computed: {
    modalId() {
      return `revoke-modal-${this.token.id}`;
    },
  },
  methods: {
    cancelHandler() {
      this.$refs.modal.hide();
    },
  },
};
</script>

<template>
  <div>
    <gl-button
      v-gl-modal="modalId"
      :class="buttonClass"
      category="primary"
      variant="danger"
      class="float-right"
      >{{ s__('DeployTokens|Revoke') }}</gl-button
    >
    <gl-modal ref="modal" :modal-id="modalId">
      <template #modal-title>
        <gl-sprintf :message="s__(`DeployTokens|Revoke %{boldStart}${token.name}%{boldEnd}?`)">
          <template #bold="{ content }"
            ><b>{{ content }}</b></template
          >
        </gl-sprintf>
      </template>
      <template>
        <gl-sprintf
          :message="
            s__(`DeployTokens|You are about to revoke %{boldStart}${token.name}%{boldEnd}.`)
          "
        >
          <template #bold="{ content }">
            <b>{{ content }}</b>
          </template>
        </gl-sprintf>
        {{ s__('DeployTokens|This action cannot be undone.') }}
      </template>
      <template #modal-footer>
        <gl-button category="secondary" @click="cancelHandler">{{ s__('Cancel') }}</gl-button>
        <gl-button
          category="primary"
          variant="danger"
          :href="revokePath"
          data-method="put"
          class="text-truncate"
        >
          <gl-sprintf :message="s__('DeployTokens|Revoke %{name}')">
            <template #name>{{ token.name }}</template>
          </gl-sprintf>
        </gl-button>
      </template>
    </gl-modal>
  </div>
</template>
