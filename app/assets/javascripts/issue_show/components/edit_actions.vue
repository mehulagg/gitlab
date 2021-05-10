<script>
import { GlButton } from '@gitlab/ui';
import { __, sprintf } from '~/locale';
import eventHub from '../event_hub';
import updateMixin from '../mixins/update';

const issuableTypes = {
  issue: __('Issue'),
  epic: __('Epic'),
  incident: __('Incident'),
};

export default {
  components: {
    GlButton,
  },
  mixins: [updateMixin],
  props: {
    canDestroy: {
      type: Boolean,
      required: true,
    },
    formState: {
      type: Object,
      required: true,
    },
    showDeleteButton: {
      type: Boolean,
      required: false,
      default: true,
    },
    issuableType: {
      type: String,
      required: true,
    },
  },
  data() {
    return {
      deleteLoading: false,
      issueState: {},
    };
  },
  computed: {
    deleteIssuableButtonText() {
      return sprintf(__('Delete %{issuableType}'), {
        issuableType: this.typeToShow.toLowerCase(),
      });
    },
    isSubmitEnabled() {
      return this.formState.title.trim() !== '';
    },
    shouldShowDeleteButton() {
      return this.canDestroy && this.showDeleteButton;
    },
    typeToShow() {
      const { formState, issuableType } = this;
      if (formState.issue_type) {
        return issuableTypes[formState.issue_type];
      }

      return issuableTypes[issuableType];
    },
  },
  methods: {
    closeForm() {
      eventHub.$emit('close.form');
    },
    // TODO: This should be be refactored to a GlModal
    deleteIssuable() {
      const confirmMessage =
        this.issuableType === 'epic'
          ? __('Delete this epic and all descendants?')
          : sprintf(__('%{issuableType} will be removed! Are you sure?'), {
              issuableType: this.typeToShow,
            });
      // eslint-disable-next-line no-alert
      if (window.confirm(confirmMessage)) {
        this.deleteLoading = true;

        eventHub.$emit('delete.issuable', { destroy_confirm: true });
      }
    },
  },
};
</script>

<template>
  <div class="gl-mt-3 gl-mb-3 clearfix">
    <gl-button
      :loading="formState.updateLoading"
      :disabled="formState.updateLoading || !isSubmitEnabled"
      category="primary"
      variant="confirm"
      class="float-left qa-save-button gl-mr-3"
      data-testid="issuable-save-button"
      type="submit"
      @click.prevent="updateIssuable"
    >
      {{ __('Save changes') }}
    </gl-button>
    <gl-button data-testid="issuable-cancel-button" @click="closeForm">
      {{ __('Cancel') }}
    </gl-button>
    <gl-button
      v-if="shouldShowDeleteButton"
      :loading="deleteLoading"
      :disabled="deleteLoading"
      category="secondary"
      variant="danger"
      class="float-right qa-delete-button"
      data-testid="issuable-delete-button"
      @click="deleteIssuable"
    >
      {{ deleteIssuableButtonText }}
    </gl-button>
  </div>
</template>
