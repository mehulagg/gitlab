<script>
import { GlButton, GlModal, GlModalDirective } from '@gitlab/ui';
import { s__, __, sprintf } from '~/locale';
import { DELETE_MODAL_CONFIG } from './constants';

export default {
  i18n: {
    createMergeRequest: __('Create merge request'),
    DELETE_MODAL_CONFIG,
  },
  components: {
    GlButton,
    GlModal,
  },
  directives: { GlModal: GlModalDirective },
  inject: {
    threatMonitoringPath: {
      type: String,
      default: '',
    },
  },
  props: {
    isCreatingMergeRequest: {
      type: Boolean,
      required: false,
      default: false,
    },
    isEditing: {
      type: Boolean,
      required: false,
      default: false,
    },
    isUpdatingPolicy: {
      type: Boolean,
      required: false,
      default: false,
    },
    policyName: {
      type: String,
      required: false,
      default: '',
    },
    shouldShowMergeRequestButton: {
      type: Boolean,
      required: false,
      default: false,
    },
  },
  computed: {
    deleteModalTitle() {
      return sprintf(s__('NetworkPolicies|Delete policy: %{policy}'), { policy: this.policyName });
    },
    saveButtonText() {
      // TODO verify
      return this.isEditing
        ? s__('NetworkPolicies|Save changes')
        : s__('NetworkPolicies|Create policy');
    },
  },
  methods: {
    createMergeRequest() {
      // TODO emit here
    },
    removePolicy() {
      // TODO emit here
    },
    savePolicy() {
      // TODO emit here
    },
  },
};
</script>

<template>
  <div>
    <gl-button
      v-if="shouldShowMergeRequestButton"
      type="submit"
      variant="success"
      data-testid="create-merge-request"
      :loading="isCreatingMergeRequest"
      @click="createMergeRequest"
      >{{ $options.i18n.createMergeRequest }}</gl-button
    >
    <gl-button
      v-else
      type="submit"
      variant="success"
      data-testid="save-policy"
      :loading="isUpdatingPolicy"
      @click="savePolicy"
      >{{ saveButtonText }}</gl-button
    >
    <gl-button
      v-if="isEditing"
      v-gl-modal="'delete-modal'"
      category="secondary"
      variant="danger"
      data-testid="delete-policy"
      :loading="isRemovingPolicy"
      >{{ s__('NetworkPolicies|Delete policy') }}</gl-button
    >
    <gl-button category="secondary" :href="threatMonitoringPath">{{ __('Cancel') }}</gl-button>
    <gl-modal
      modal-id="delete-modal"
      :title="deleteModalTitle"
      :action-secondary="$options.i18n.DELETE_MODAL_CONFIG.secondary"
      :action-cancel="$options.i18n.DELETE_MODAL_CONFIG.cancel"
      @secondary="removePolicy"
    >
      {{
        s__(
          'NetworkPolicies|Are you sure you want to delete this policy? This action cannot be undone.',
        )
      }}
    </gl-modal>
  </div>
</template>
