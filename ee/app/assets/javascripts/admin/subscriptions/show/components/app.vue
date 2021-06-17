<script>
import { GlAlert } from '@gitlab/ui';
import {
  activateSubscription,
  noActiveSubscription,
  subscriptionActivationNotificationText,
  subscriptionHistoryQueries,
  subscriptionMainTitle,
  subscriptionQueries,
} from '../constants';
import SubscriptionActivationCard from './subscription_activation_card.vue';
import SubscriptionBreakdown from './subscription_breakdown.vue';
import SubscriptionPurchaseCard from './subscription_purchase_card.vue';
import SubscriptionTrialCard from './subscription_trial_card.vue';

export default {
  name: 'CloudLicenseApp',
  components: {
    GlAlert,
    SubscriptionActivationCard,
    SubscriptionBreakdown,
    SubscriptionPurchaseCard,
    SubscriptionTrialCard,
  },
  i18n: {
    activateSubscription,
    noActiveSubscription,
    subscriptionActivationNotificationText,
    subscriptionMainTitle,
  },
  props: {
    hasActiveLicense: {
      type: Boolean,
      required: false,
      default: false,
    },
  },
  apollo: {
    currentSubscription: {
      query: subscriptionQueries.query,
      update({ currentLicense }) {
        return currentLicense || {};
      },
      result({ data }) {
        this.hasNewLicense = data?.currentLicense && !this.hasActiveLicense;
      },
    },
    subscriptionHistory: {
      query: subscriptionHistoryQueries.query,
      update({ licenseHistoryEntries }) {
        return licenseHistoryEntries.nodes || [];
      },
    },
  },
  data() {
    return {
      currentSubscription: {},
      hasDismissedNotification: false,
      hasNewLicense: false,
      subscriptionHistory: [],
      notification: null,
    };
  },
  computed: {
    hasValidSubscriptionData() {
      return Boolean(Object.keys(this.currentSubscription).length);
    },
    canShowSubscriptionDetails() {
      return this.hasActiveLicense || this.hasValidSubscriptionData;
    },
    shouldShowActivationNotification() {
      return !this.hasDismissedNotification && this.hasNewLicense && this.hasValidSubscriptionData;
    },
  },
  methods: {
    dismissSuccessAlert() {
      this.hasDismissedNotification = true;
    },
  },
};
</script>

<template>
  <div class="gl-display-flex gl-justify-content-center gl-flex-direction-column">
    <h4 data-testid="subscription-main-title">{{ $options.i18n.subscriptionMainTitle }}</h4>
    <hr />
    <gl-alert
      v-if="shouldShowActivationNotification"
      variant="success"
      :title="$options.i18n.subscriptionActivationNotificationText"
      class="mb-4"
      data-testid="subscription-activation-success-alert"
      @dismiss="dismissSuccessAlert"
    />
    <subscription-breakdown
      v-if="canShowSubscriptionDetails"
      :subscription="currentSubscription"
      :subscription-list="subscriptionHistory"
    />
    <div v-else class="row">
      <div class="col-12 col-lg-8 offset-lg-2">
        <h3 class="gl-mb-7 gl-mt-6 gl-text-center" data-testid="subscription-activation-title">
          {{ $options.i18n.noActiveSubscription }}
        </h3>
        <subscription-activation-card />
        <div class="row gl-mt-7">
          <div class="col-lg-6">
            <subscription-trial-card />
          </div>
          <div class="col-lg-6">
            <subscription-purchase-card />
          </div>
        </div>
      </div>
    </div>
  </div>
</template>
