<script>
import { GlAlert, GlSprintf } from '@gitlab/ui';
import { __ } from '~/locale';
import SharedDeleteButton from './shared/delete_button.vue';

export default {
  components: {
    GlSprintf,
    GlAlert,
    SharedDeleteButton,
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
  strings: {
    modalTriggerTitle: __('Remove fork relationship'),
    modalTitle: __('Confirmation required'),
    alertTitle: __(
      'You are going to remove the fork relationship from this project. Are you ABSOLUTELY sure?',
    ),
    alertBody: __(
      'This action can %{strongStart}lead to data loss%{strongEnd}. To prevent accidental actions we ask you to confirm your intention.',
    ),
    modalBody: __('This action cannot be undone.'),
  },
};
</script>

<template>
  <shared-delete-button
    v-bind="{
      confirmPhrase,
      formPath,
      modalTriggerTitle: $options.strings.modalTriggerTitle,
      modalTitle: $options.strings.modalTitle,
    }"
  >
    <template #modal-body>
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
      <p>{{ $options.strings.modalBody }}</p>
    </template>
  </shared-delete-button>
</template>
