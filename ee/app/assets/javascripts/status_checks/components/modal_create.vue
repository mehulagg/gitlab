<script>
import { GlButton, GlModal, GlModalDirective } from '@gitlab/ui';
import { mapActions, mapState } from 'vuex';
import { __, s__ } from '~/locale';
import { EMPTY_STATUS_CHECK } from '../constants';
import { modalPrimaryActionProps } from '../utils';
import StatusCheckForm from './form.vue';

export const i18n = {
  addButton: s__('StatusCheck|Add status check'),
  title: s__('StatusCheck|Add status check'),
  cancelButton: __('Cancel'),
};

export default {
  components: {
    GlButton,
    GlModal,
    StatusCheckForm,
  },
  directives: {
    GlModal: GlModalDirective,
  },
  data() {
    return {
      serverValidationErrors: [],
      showValidation: false,
      submitting: false,
    };
  },
  computed: {
    ...mapState({
      projectId: ({ settings }) => settings.projectId,
    }),
    primaryActionProps() {
      return modalPrimaryActionProps(i18n.title, this.submitting);
    },
    isFormValid() {
      return this.$refs.form.isValid;
    },
    getFormData() {
      return this.$refs.form.formData;
    },
  },
  methods: {
    ...mapActions(['postStatusCheck']),
    async submit() {
      this.showValidation = true;
      this.submitting = true;

      if (this.isFormValid) {
        const { branches: protectedBranchIds, name, url: externalUrl } = this.getFormData;

        try {
          await this.postStatusCheck({
            externalUrl,
            name,
            protectedBranchIds,
          });

          this.$refs.modal.hide();
        } catch (failureResponse) {
          this.serverValidationErrors = failureResponse?.response?.data?.message || [];
        }
      }

      this.submitting = false;
    },
  },
  modalId: 'status-checks-create-modal',
  cancelActionProps: {
    text: i18n.cancelButton,
  },
  emptyStatusCheck: EMPTY_STATUS_CHECK,
  i18n,
};
</script>

<template>
  <div>
    <gl-button
      v-gl-modal="$options.modalId"
      category="secondary"
      variant="confirm"
      size="small"
      :loading="submitting"
    >
      {{ $options.i18n.addButton }}
    </gl-button>
    <gl-modal
      ref="modal"
      :modal-id="$options.modalId"
      :title="$options.i18n.title"
      :action-primary="primaryActionProps"
      :action-cancel="$options.cancelActionProps"
      size="sm"
      @ok.prevent="submit"
    >
      <status-check-form
        ref="form"
        :project-id="projectId"
        :server-validation-errors="serverValidationErrors"
        :show-validation="showValidation"
        :status-check="$options.emptyStatusCheck"
      />
    </gl-modal>
  </div>
</template>
