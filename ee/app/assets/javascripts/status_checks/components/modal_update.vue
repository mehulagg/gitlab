<script>
import { GlButton, GlModal, GlModalDirective } from '@gitlab/ui';
import { mapActions } from 'vuex';
import { isSafeURL } from '~/lib/utils/url_utility';
import { __, s__ } from '~/locale';
import StatusCheckForm from './form.vue';

const i18n = {
  editButton: __('Edit'),
  title: s__('StatusCheck|Update status check'),
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
  props: {
    statusCheck: {
      type: Object,
      required: true,
    },
  },
  data() {
    const { protectedBranches: branches, name, externalUrl: url } = this.statusCheck;

    return {
      branches,
      name,
      serverValidationErrors: [],
      showValidation: false,
      submitting: false,
      url,
    };
  },
  computed: {
    modalId() {
      return `status-checks-edit-modal-${this.statusCheck.id}`;
    },
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
    ...mapActions(['putStatusCheck']),
    async submit() {
      let submission;

      this.serverValidationErrors = [];
      this.showValidation = true;
      this.submitting = true;

      if (this.isInvalid) {
        submission = Promise.resolve;
      } else {
        submission = this.putStatusCheck;
      }

      const data = {
        externalUrl: this.url,
        id: this.statusCheck.id,
        name: this.name,
        protectedBranchIds: this.branches,
      };

      try {
        await submission(data);

        this.$refs.modal.hide();
        this.submitting = false;
      } catch (failureResponse) {
        this.serverValidationErrors = failureResponse?.response?.data?.message || [];
        this.submitting = false;
      }
    },
  },
  cancelActionProps: {
    text: i18n.cancelButton,
  },
  i18n,
};
</script>

<template>
  <div>
    <gl-button v-gl-modal="modalId" data-testid="edit-btn" :loading="submitting">
      {{ $options.i18n.editButton }}
    </gl-button>
    <gl-modal
      ref="modal"
      :modal-id="modalId"
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
