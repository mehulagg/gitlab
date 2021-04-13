<script>
import { subscriptionActivationTitle } from '../constants';
import getCurrentLicense from '../graphql/queirs/get_current_license.query.graphql';
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
  },
  inject: ['planName'],
  props: {
    hasLicense: {
      type: Boolean,
      required: false,
      default: true,
    },
  },
  apollo: {
    currentSubscription: {
      query: getCurrentLicense,
      update(data) {
        const { currentLicense } = data;
        return currentLicense;
      },
      skip() {
        return !this.hasCurrentLicense;
      },
    },
  },
  data() {
    return {
      currentSubscription: {},
      subscriptionHistory: [],
      hasCurrentLicense: this.hasLicense,
    };
  },
};
</script>

<template>
  <div class="gl-display-flex gl-justify-content-center gl-flex-direction-column">
    <h4>{{ s__('CloudLicense|Your subscription') }}</h4>
    <hr />
    <div v-if="!hasCurrentLicense" class="row">
      <div class="col-12 col-lg-8 offset-lg-2">
        <h3 class="gl-mb-7 gl-mt-6 gl-text-center">
          {{ $options.i18n.subscriptionActivationTitle }}
        </h3>
        <cloud-license-subscription-activation-form />
      </div>
    </div>
    <subscription-breakdown
      v-else
      :subscription="currentSubscription"
      :subscription-list="subscriptionHistory"
    />
  </div>
</template>
