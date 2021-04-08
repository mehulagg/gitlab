<script>
import { GlAlert, GlModal, GlModalDirective, GlFormInput, GlButton, GlSprintf } from '@gitlab/ui';
import { uniqueId } from 'lodash';
import { deprecatedCreateFlash as Flash } from '~/flash';
import axios from '~/lib/utils/axios_utils';
import csrf from '~/lib/utils/csrf';
import { __ } from '~/locale';

export default {
  components: {
    GlModal,
    GlFormInput,
    GlButton,
    GlSprintf,
    GlAlert,
  },
  directives: {
    GlModal: GlModalDirective,
  },
  props: {
    confirmPhrase: {
      type: String,
      required: true,
    },
    formPath: {
      type: String,
      required: true,
    },
  },
  data() {
    return {
      userInput: null,
      modalId: uniqueId('project-remove-fork-modal-'),
    };
  },
  computed: {
    confirmDisabled() {
      return this.userInput !== this.confirmPhrase;
    },
    csrfToken() {
      return csrf.token;
    },
    modalActionProps() {
      return {
        primary: {
          text: __('Yes, remove fork relationship'),
          attributes: [{ variant: 'danger' }, { disabled: this.confirmDisabled }],
        },
        cancel: {
          text: __('Cancel, keep fork relationship'),
        },
      };
    },
  },
  methods: {
    submitForm() {
      axios
        .delete(this.formPath)
        .then(() => {
          window.location.reload();
        })
        .catch(() => {
          Flash(
            __('Something went wrong while removing the fork relationship. Please try again.'),
            'alert',
          );
        });
    },
  },
  strings: {
    alertTitle: __('You are about to permanently remove the fork relationship from this project'),
    alertBody: __(
      'This action can lead to data loss. To prevent accidental actions we ask you to confirm your intention.',
    ),
    removeFork: __('Remove fork relationship'),
    title: __('Confirmation required'),
    confirmText: __('Please type the following to confirm:'),
  },
};
</script>

<template>
  <form ref="form" :action="formPath" method="post">
    <input type="hidden" name="_method" value="delete" />
    <input :value="csrfToken" type="hidden" name="authenticity_token" />

    <gl-button v-gl-modal="modalId" category="primary" variant="danger">{{
      $options.strings.removeFork
    }}</gl-button>

    <gl-modal
      ref="removeModal"
      :modal-id="modalId"
      size="sm"
      ok-variant="danger"
      footer-class="gl-bg-gray-10 gl-p-5"
      title-class="gl-text-red-500"
      :action-primary="modalActionProps.primary"
      :action-cancel="modalActionProps.cancel"
      @ok="submitForm"
    >
      <template #modal-title>{{ $options.strings.title }}</template>
      <div>
        <gl-alert
          class="gl-mb-5"
          variant="danger"
          :title="$options.strings.alertTitle"
          :dismissible="false"
        >
          <gl-sprintf :message="$options.strings.alertBody">
            <template #strong="{ content }">
              <strong>{{ content }}</strong>
            </template>
          </gl-sprintf>
        </gl-alert>
        <p class="gl-mb-1">{{ $options.strings.confirmText }}</p>
        <p>
          <code class="gl-white-space-pre-wrap">{{ confirmPhrase }}</code>
        </p>
        <gl-form-input
          id="confirm_name_input"
          v-model="userInput"
          name="confirm_name_input"
          type="text"
        />
        <slot name="modal-footer"></slot>
      </div>
    </gl-modal>
  </form>
</template>
