<script>
import { GlAlert, GlLink, GlSprintf } from '@gitlab/ui';
import {
  manualSyncFailureText,
  manualSyncFailureTitle,
  manualSyncSuccessfulTitle,
} from '../constants';

export const notificationType = {
  SYNC_FAILURE: 'SYNC_FAILURE',
  SYNC_SUCCESS: 'SYNC_SUCCESS',
};

export const SUCCESS_ALERT_DISMISSED_EVENT = 'success-alert-dismissed';

const notificationTypeValidator = (value) =>
  !value || Object.values(notificationType).includes(value);

export default {
  name: 'SubscriptionSyncNotifications',
  i18n: {
    manualSyncSuccessfulTitle,
    manualSyncFailureText,
    manualSyncFailureTitle,
  },
  components: {
    GlAlert,
    GlLink,
    GlSprintf,
  },
  inject: ['connectivityHelpURL'],
  props: {
    notification: {
      type: String,
      required: false,
      default: '',
      validator: notificationTypeValidator,
    },
  },
  computed: {
    syncDidSuccess() {
      return this.notification === notificationType.SYNC_SUCCESS;
    },
    syncDidFail() {
      return this.notification === notificationType.SYNC_FAILURE;
    },
  },
  methods: {
    didDismissSuccessAlert() {
      this.$emit(SUCCESS_ALERT_DISMISSED_EVENT);
    },
  },
};
</script>

<template>
  <div>
    <gl-alert
      v-if="syncDidSuccess"
      variant="success"
      :title="$options.i18n.manualSyncSuccessfulTitle"
      data-testid="sync-success-alert"
      @dismiss="didDismissSuccessAlert"
    />
    <gl-alert
      v-else-if="syncDidFail"
      variant="danger"
      :dismissible="false"
      :title="$options.i18n.manualSyncFailureTitle"
      data-testid="sync-failure-alert"
    >
      <gl-sprintf :message="$options.i18n.manualSyncFailureText">
        <template #connectivityHelpLink="{ content }">
          <gl-link :href="connectivityHelpURL" target="_blank">{{ content }}</gl-link>
        </template>
      </gl-sprintf>
    </gl-alert>
  </div>
</template>
