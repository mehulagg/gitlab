<script>
import { GlAlert, GlLink, GlSprintf } from '@gitlab/ui';
import {
  manualSyncFailureText,
  connectivityIssue,
  manualSyncPendingTitle,
  subscriptionSyncStatus,
  manualSyncPendingText,
} from '../constants';

export const INFO_ALERT_DISMISSED_EVENT = 'info-alert-dismissed';

const subscriptionSyncStatusValidator = (value) =>
  !value || Object.values(subscriptionSyncStatus).includes(value);

export default {
  name: 'SubscriptionSyncNotifications',
  i18n: {
    manualSyncPendingText,
    manualSyncPendingTitle,
    manualSyncFailureText,
    connectivityIssue,
  },
  components: {
    GlAlert,
    GlLink,
    GlSprintf,
  },
  inject: ['connectivityHelpURL'],
  props: {
    syncStatus: {
      type: String,
      required: true,
      validator: subscriptionSyncStatusValidator,
    },
  },
  computed: {
    isSyncPending() {
      return this.syncStatus === subscriptionSyncStatus.SYNC_PENDING;
    },
    syncDidFail() {
      return this.syncStatus === subscriptionSyncStatus.SYNC_FAILURE;
    },
  },
  methods: {
    didDismissInfoAlert() {
      this.$emit(INFO_ALERT_DISMISSED_EVENT);
    },
  },
};
</script>

<template>
  <div>
    <gl-alert
      v-if="isSyncPending"
      variant="info"
      :title="$options.i18n.manualSyncPendingTitle"
      data-testid="sync-info-alert"
      @dismiss="didDismissInfoAlert"
      >{{ $options.i18n.manualSyncPendingText }}</gl-alert
    >
    <gl-alert
      v-else-if="syncDidFail"
      variant="danger"
      :dismissible="false"
      :title="$options.i18n.connectivityIssue"
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
