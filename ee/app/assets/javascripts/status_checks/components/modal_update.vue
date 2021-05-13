<script>
import { GlModal, GlModalDirective } from '@gitlab/ui';
import { mapActions, mapState } from 'vuex';
import { __, s__ } from '~/locale';
import { modalPrimaryActionProps } from '../utils';
import StatusCheckForm from './form.vue';

export const i18n = {
  title: s__('StatusCheck|Update status check'),
  cancelButton: __('Cancel'),
};

export default {
  components: {
    GlModal,
    StatusCheckForm,
  },
  directives: {
    GlModal: GlModalDirective,
  },
  props: {
    statusCheck: {
      type: Object,
      required: true,
    },
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
    ...mapActions(['putStatusCheck']),
    async submit() {
      this.showValidation = true;
      this.submitting = true;

      if (this.isFormValid) {
        const { branches: protectedBranchIds, name, url: externalUrl } = this.getFormData;

        try {
          await this.putStatusCheck({
            externalUrl,
            id: this.statusCheck.id,
            name,
            protectedBranchIds,
          });

          this.serverValidationErrors = [];
          this.$refs.modal.hide();
        } catch (failureResponse) {
          this.serverValidationErrors = failureResponse?.response?.data?.message || [];
        }
      }

      this.submitting = false;
    },
    show() {
      this.$refs.modal.show();
    },
  },
  modalId: 'status-checks-update-modal',
  cancelActionProps: {
    text: i18n.cancelButton,
  },
  i18n,
};
</script>

<template>
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
      :status-check="statusCheck"
      :server-validation-errors="serverValidationErrors"
      :show-validation="showValidation"
    />
  </gl-modal>
</template>
