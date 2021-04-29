<script>
import { GlAlert, GlCard } from '@gitlab/ui';
import { fetchPolicies } from '~/lib/graphql';
import {
  subscriptionActivationForm,
  subscriptionActivationNotificationText,
  subscriptionActivationTitle,
  subscriptionHistoryQueries,
  subscriptionMainTitle,
  subscriptionQueries,
} from '../constants';
import SubscriptionActivationForm from './subscription_activation_form.vue';
import SubscriptionBreakdown from './subscription_breakdown.vue';
import SubscriptionPurchaseCard from './subscription_purchase_card.vue';
import SubscriptionTrialCard from './subscription_trial_card.vue';

export default {
  name: 'CloudLicenseApp',
  components: {
    GlAlert,
    GlCard,
    SubscriptionActivationForm,
    SubscriptionBreakdown,
    SubscriptionPurchaseCard,
    SubscriptionTrialCard,
  },
  i18n: {
    subscriptionActivationFormTitle: subscriptionActivationForm.title,
    subscriptionActivationNotificationText,
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
      fetchPolicy: fetchPolicies.CACHE_AND_NETWORK,
      query: subscriptionQueries.query,
      update({ currentLicense }) {
        return currentLicense || {};
      },
      result({ data }) {
        // it assumes that receiving a successful response with
        // no previous active license means a license has been activated
        if (data?.currentLicense && !this.hasActiveLicense) {
          this.showActivationNotification = true;
        }
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
      showActivationNotification: false,
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
      return this.showActivationNotification && this.hasValidSubscriptionData;
    },
  },
  methods: {
    dismissSuccessAlert() {
      this.showActivationNotification = false;
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
          {{ $options.i18n.subscriptionActivationTitle }}
        </h3>
        <gl-card>
          <template #header>
            <h5 class="gl-my-0 gl-font-weight-bold">
              {{ $options.i18n.subscriptionActivationFormTitle }}
            </h5>
          </template>
          <cloud-license-subscription-activation-form />
        </gl-card>
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
