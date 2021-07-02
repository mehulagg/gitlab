<script>
import {
  GlModal,
  GlForm,
  GlFormGroup,
  GlFormInput,
  GlFormTextarea,
  GlToggle,
  GlButton,
  GlAlert,
} from '@gitlab/ui';
import createFlash from '~/flash';
import { visitUrl } from '~/lib/utils/url_utility';
import { __ } from '~/locale';
import { BV_HIDE_MODAL } from '~/lib/utils/constants';
import {
  SECONDARY_OPTIONS_TEXT,
  COMMIT_LABEL,
  TARGET_BRANCH_LABEL,
  TOGGLE_CREATE_MR_LABEL,
  NEW_BRANCH_IN_FORK,
} from '../constants';
import deleteBlobMutation from '../mutations/delete_blob.mutation.graphql';

export default {
  components: {
    GlModal,
    GlForm,
    GlFormGroup,
    GlFormInput,
    GlFormTextarea,
    GlToggle,
    GlButton,
    GlAlert,
  },
  i18n: {
    primaryOptionsText: __('Delete file'),
    SECONDARY_OPTIONS_TEXT,
    COMMIT_LABEL,
    TARGET_BRANCH_LABEL,
    TOGGLE_CREATE_MR_LABEL,
    NEW_BRANCH_IN_FORK,
  },
  props: {
    modalId: {
      type: String,
      required: true,
    },
    modalTitle: {
      type: String,
      required: true,
    },
    commitMessage: {
      type: String,
      required: true,
    },
    targetBranch: {
      type: String,
      required: true,
    },
    originalBranch: {
      type: String,
      required: true,
    },
    canPushCode: {
      type: Boolean,
      required: true,
    },
    path: {
      type: String,
      required: true,
    },
    deletePath: {
      // SAM: delete this
      type: String,
      required: true,
    },
    projectPath: {
      type: String,
      required: true,
    },
  },
  data() {
    return {
      loading: false,
      commit: this.commitMessage,
      target: this.targetBranch,
      createNewMr: true,
      error: '',
    };
  },
  computed: {
    primaryOptions() {
      return {
        text: this.$options.i18n.primaryOptionsText,
        attributes: [
          {
            variant: 'danger',
            loading: this.loading,
            disabled: !this.formCompleted || this.loading,
          },
        ],
      };
    },
    cancelOptions() {
      return {
        text: this.$options.i18n.SECONDARY_OPTIONS_TEXT,
        attributes: [
          {
            disabled: this.loading,
          },
        ],
      };
    },
    showCreateNewMrToggle() {
      return this.canPushCode && this.target !== this.originalBranch;
    },
    formCompleted() {
      return this.commit && this.target;
    },
  },
  methods: {
    formData() {
      const formData = new FormData();
      formData.append('commit_message', this.commit);
      formData.append('branch_name', this.target);
      formData.append('create_merge_request', this.createNewMr);

      return formData;
    },
    submitForm() {
      const {
        projectPath: project,
        target: branch,
        originalBranch: startBranch,
        commit: message,
        path: file,
      } = this;

      // console.log('>>>', {
      //   project,
      //   branch,
      //   startBranch,
      //   message,
      //   file,
      // });

      this.$apollo
        .mutate({
          mutation: deleteBlobMutation,
          variables: { project, branch, startBranch, message, file },
        })
        .then((resp) => {
          console.log('resp', resp);
          // TODO - redirect to repository list
          // TODO - redirect to new merge request
        })
        .catch((error) => {
          this.$root.$emit(BV_HIDE_MODAL, this.modalId);
          createFlash({ message: error });
        });
    },
  },
};
</script>

<template>
  <gl-modal
    :modal-id="modalId"
    :title="modalTitle"
    :action-primary="primaryOptions"
    :action-cancel="cancelOptions"
    @primary="submitForm"
  >
    <gl-form-group :label="$options.i18n.COMMIT_LABEL" label-for="commit_message">
      <gl-form-textarea v-model="commit" name="commit_message" :disabled="loading" />
    </gl-form-group>
    <gl-form-group
      v-if="canPushCode"
      :label="$options.i18n.TARGET_BRANCH_LABEL"
      label-for="branch_name"
    >
      <gl-form-input v-model="target" :disabled="loading" name="branch_name" />
    </gl-form-group>
    <gl-toggle
      v-if="showCreateNewMrToggle"
      v-model="createNewMr"
      :disabled="loading"
      :label="$options.i18n.TOGGLE_CREATE_MR_LABEL"
    />
    <gl-alert v-if="!canPushCode" variant="info" :dismissible="false" class="gl-mt-3">
      {{ $options.i18n.NEW_BRANCH_IN_FORK }}
    </gl-alert>
  </gl-modal>
</template>
