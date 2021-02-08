<script>
import { GlButton, GlModal, GlSprintf, GlModalDirective } from '@gitlab/ui';
import { sprintf, __ } from '~/locale';

export default {
  name: 'IssuableByEmail',
  components: {
    GlButton,
    GlModal,
    GlSprintf,
  },
  directives: {
    GlModalDirective,
  },
  inject: {
    email: {
      default: null,
    },
    issuableType: {
      default: '',
    },
    emailsHelpPagePath: {
      default: '',
    },
    quickActionsHelpPath: {
      default: '',
    },
    markdownHelpPath: {
      default: '',
    },
    resetPath: {
      default: '',
    },
  },
  data() {
    return {
      issuableName: this.issuableType === 'issue' ? 'issue' : 'merge request',
    };
  },
  computed: {
    modalTitle() {
      return sprintf(__('Create new %{name} by email'), {
        name: this.issuableName,
      });
    },
  },
  modalId: 'issuable-email-modal',
};
</script>

<template>
  <div>
    <div class="issuable-footer text-center">
      <gl-button
        v-gl-modal-directive="$options.modalId"
        class="issuable-email-modal-btn"
        variant="link"
        ><gl-sprintf :message="__('Email a new %{name} to this project')"
          ><template #name>{{ issuableName }}</template></gl-sprintf
        ></gl-button
      >
    </div>
    <gl-modal :modal-id="$options.modalId" :title="modalTitle"> </gl-modal>
  </div>
</template>
