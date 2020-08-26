<script>
import {
  STEPS,
  SUBSCRIPTON_FLOW_STEPS,
  ONBOARDING_ISSUES_EXPERIMENT_AND_SUBSCRIPTION_FLOW_STEPS,
} from 'ee/registrations/constants';
import { mapState } from 'vuex';
import ProgressBar from 'ee/registrations/components/progress_bar.vue';
import { s__ } from '~/locale';
import SubscriptionDetails from './checkout/subscription_details.vue';
import BillingAddress from './checkout/billing_address.vue';
import PaymentMethod from './checkout/payment_method.vue';
import ConfirmOrder from './checkout/confirm_order.vue';

export default {
  components: { ProgressBar, SubscriptionDetails, BillingAddress, PaymentMethod, ConfirmOrder },
  currentStep: STEPS.checkout,
  computed: {
    ...mapState(['isOnboardingIssuesExperimentEnabled', 'isNewUser']),
    steps() {
      return this.isOnboardingIssuesExperimentEnabled
        ? ONBOARDING_ISSUES_EXPERIMENT_AND_SUBSCRIPTION_FLOW_STEPS
        : SUBSCRIPTON_FLOW_STEPS;
    },
  },
  i18n: {
    checkout: s__('Checkout|Checkout'),
  },

  emits: [],
};
</script>
<template>
  <div class="checkout d-flex flex-column justify-content-between w-100">
    <div class="full-width">
      <progress-bar v-if="isNewUser" :steps="steps" :current-step="$options.currentStep" />
      <div class="flash-container"></div>
      <h2 class="mt-4 mb-3 mb-lg-5">{{ $options.i18n.checkout }}</h2>
      <subscription-details />
      <billing-address />
      <payment-method />
    </div>
    <confirm-order />
  </div>
</template>
