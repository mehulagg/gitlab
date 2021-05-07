<script>
import { GlButton } from '@gitlab/ui';
import { pick, some } from 'lodash';
import axios from '~/lib/utils/axios_utils';
import {
  licensedToHeaderText,
  manageSubscriptionButtonText,
  subscriptionDetailsHeaderText,
  subscriptionType,
  syncSubscriptionButtonText,
  notificationType,
} from '../constants';
import SubscriptionDetailsCard from './subscription_details_card.vue';
import SubscriptionDetailsHistory from './subscription_details_history.vue';
import SubscriptionDetailsUserInfo from './subscription_details_user_info.vue';

export const subscriptionDetailsFields = ['id', 'plan', 'expiresAt', 'lastSync', 'startsAt'];
export const licensedToFields = ['name', 'email', 'company'];

export default {
  i18n: {
    licensedToHeaderText,
    manageSubscriptionButtonText,
    subscriptionDetailsHeaderText,
    syncSubscriptionButtonText,
  },
  name: 'SubscriptionBreakdown',
  components: {
    GlButton,
    SubscriptionDetailsCard,
    SubscriptionDetailsHistory,
    SubscriptionDetailsUserInfo,
    SubscriptionSyncNotifications: () => import('./subscription_sync_notifications.vue'),
  },
  inject: ['subscriptionSyncPath'],
  props: {
    subscription: {
      type: Object,
      required: true,
    },
    subscriptionList: {
      type: Array,
      required: true,
    },
  },
  data() {
    return {
      hasAsyncActivity: false,
      licensedToFields,
      notification: null,
      subscriptionDetailsFields,
    };
  },
  computed: {
    canSyncSubscription() {
      return this.subscriptionSyncPath && this.subscription.type === subscriptionType.CLOUD;
    },
    canMangeSubscription() {
      return false;
    },
    hasSubscription() {
      return Boolean(Object.keys(this.subscription).length);
    },
    hasSubscriptionHistory() {
      return Boolean(this.subscriptionList.length);
    },
    shouldShowFooter() {
      return some(pick(this, ['canSyncSubscription', 'canMangeSubscription']), Boolean);
    },
    subscriptionHistory() {
      return this.hasSubscriptionHistory ? this.subscriptionList : [this.subscription];
    },
  },
  methods: {
    didDismissSuccessAlert() {
      this.notification = null;
    },
    syncSubscription() {
      this.hasAsyncActivity = true;
      this.notification = null;
      axios
        .post(this.subscriptionSyncPath)
        .then(() => {
          this.notification = notificationType.SYNC_SUCCESS;
        })
        .catch(() => {
          this.notification = notificationType.SYNC_FAILURE;
        })
        .finally(() => {
          this.hasAsyncActivity = false;
        });
    },
  },
};
</script>

<template>
  <div>
    <subscription-sync-notifications
      v-if="notification"
      class="mb-4"
      :notification="notification"
      @success-alert-dismissed="didDismissSuccessAlert"
    />
    <section class="row gl-mb-5">
      <div class="col-md-6 gl-mb-5">
        <subscription-details-card
          :details-fields="subscriptionDetailsFields"
          :header-text="$options.i18n.subscriptionDetailsHeaderText"
          :subscription="subscription"
        >
          <template v-if="shouldShowFooter" #footer>
            <gl-button
              v-if="canSyncSubscription"
              category="primary"
              :loading="hasAsyncActivity"
              variant="confirm"
              data-testid="subscription-sync-action"
              @click="syncSubscription"
            >
              {{ $options.i18n.syncSubscriptionButtonText }}
            </gl-button>
            <gl-button v-if="canMangeSubscription">
              {{ $options.i18n.manageSubscriptionButtonText }}
            </gl-button>
          </template>
        </subscription-details-card>
      </div>

      <div class="col-md-6 gl-mb-5">
        <subscription-details-card
          :details-fields="licensedToFields"
          :header-text="$options.i18n.licensedToHeaderText"
          :subscription="subscription"
        />
      </div>
    </section>
    <subscription-details-user-info v-if="hasSubscription" :subscription="subscription" />
    <subscription-details-history
      v-if="hasSubscription"
      :current-subscription-id="subscription.id"
      :subscription-list="subscriptionHistory"
    />
  </div>
</template>
