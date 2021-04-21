<script>
import {
  subscriptionActivationTitle,
  subscriptionHistoryQueries,
  subscriptionMainTitle,
  subscriptionQueries,
} from '../constants';
import CloudLicenseSubscriptionActivationForm from './subscription_activation_form.vue';
import SubscriptionBreakdown from './subscription_breakdown.vue';

export default {
  name: 'CloudLicenseApp',
  components: {
    SubscriptionBreakdown,
    CloudLicenseSubscriptionActivationForm,
  },
  i18n: {
    subscriptionActivationTitle,
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
        return currentLicense;
      },
      skip() {
        return !this.canShowSubscriptionDetails;
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
      subscriptionHistory: [],
      canShowSubscriptionDetails: this.hasActiveLicense,
    };
  },
  methods: {
    handleActivation(hasLicense) {
      this.canShowSubscriptionDetails = hasLicense;
    },
  },
};
</script>

<template>
  <div class="gl-display-flex gl-justify-content-center gl-flex-direction-column">
    <h4 data-testid="subscription-main-title">{{ $options.i18n.subscriptionMainTitle }}</h4>
    <hr />
    <subscription-breakdown
      v-if="canShowSubscriptionDetails"
      :subscription="currentSubscription"
      :subscription-list="subscriptionHistory"
    />
    <div v-else class="row">
      <div class="col-12 col-lg-8 offset-lg-2">
        <h3 class="gl-mb-7 gl-mt-6 gl-text-center" data-testid="subscription-activation-title">
          {{ $options.i18n.subscriptionActivationTitle }}
        </h3>
        <cloud-license-subscription-activation-form @subscription-activation="handleActivation" />
      </div>
    </div>
  </div>
</template>
