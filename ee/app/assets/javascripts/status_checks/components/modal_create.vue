<script>
import { GlButton, GlModal, GlModalDirective } from '@gitlab/ui';
import { mapActions } from 'vuex';
import { isSafeURL } from '~/lib/utils/url_utility';
import { __, s__ } from '~/locale';
import StatusCheckForm from './form.vue';

const i18n = {
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
    return this.getInitialData();
  },
  computed: {
    primaryActionProps() {
      return {
        text: i18n.title,
        attributes: [{ variant: 'confirm', loading: this.submitting }],
      };
    },
    isInvalid() {
      return (
        this.serverValidationErrors.length > 0 ||
        this.name === '' ||
        this.branches.some((id) => typeof id !== 'number') ||
        this.url === '' ||
        !isSafeURL(this.url)
      );
    },
  },
  methods: {
    ...mapActions(['postStatusCheck']),
    getInitialData() {
      return {
        branches: [],
        name: '',
        serverValidationErrors: [],
        showValidation: false,
        submitting: false,
        url: '',
      };
    },
    async submit() {
      let submission;

      this.serverValidationErrors = [];
      this.showValidation = true;
      this.submitting = true;

      if (this.isInvalid) {
        submission = Promise.resolve;
      } else {
        submission = this.postStatusCheck;
      }

      const data = {
        externalUrl: this.url,
        name: this.name,
        protectedBranchIds: this.branches,
      };

      try {
        await submission(data);

        this.$refs.modal.hide();
        this.resetModal();
      } catch (failureResponse) {
        this.serverValidationErrors = failureResponse?.response?.data?.message || [];
        this.submitting = false;
      }
    },
    resetModal() {
      const {
        branches,
        name,
        serverValidationErrors,
        showValidation,
        submitting,
        url,
      } = this.getInitialData();

      this.branches = branches;
      this.name = name;
      this.serverValidationErrors = serverValidationErrors;
      this.showValidation = showValidation;
      this.submitting = submitting;
      this.url = url;
    },
  },
  modalId: 'status-checks-add-modal',
  cancelActionProps: {
    text: i18n.cancelButton,
  },
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
        :name.sync="name"
        :url.sync="url"
        :branches.sync="branches"
        :server-validation-errors.sync="serverValidationErrors"
        :show-validation.sync="showValidation"
      />
    </gl-modal>
  </div>
</template>
