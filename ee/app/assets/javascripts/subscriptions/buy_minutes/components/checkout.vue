<script>
import ProgressBar from 'ee/registrations/components/progress_bar.vue';
import { STEPS, SUBSCRIPTON_FLOW_STEPS } from 'ee/registrations/constants';
import STATE_QUERY from 'ee/subscriptions/graphql/queries/state.query.graphql';
import { s__ } from '~/locale';
import SubscriptionDetails from './checkout/subscription_details.vue';

export default {
  components: { ProgressBar, SubscriptionDetails },
  props: {
    plans: {
      type: Array,
      required: true,
    },
  },
  apollo: {
    state: {
      query: STATE_QUERY,
    },
  },
  computed: {
    isNewUser() {
      return this.state.isNewUser;
    },
  },
  currentStep: STEPS.checkout,
  steps: SUBSCRIPTON_FLOW_STEPS,
  i18n: {
    checkout: s__('Checkout|Checkout'),
  },
};
</script>
<template>
  <div class="checkout gl-flex gl-flex-column gl-justify-content-between w-100">
    <div class="full-width">
      <progress-bar v-if="isNewUser" :steps="$options.steps" :current-step="$options.currentStep" />
      <div class="flash-container"></div>
      <h2 class="gl-mt-4 gl-mb-3 gl-mb-lg-5">{{ $options.i18n.checkout }}</h2>
      <subscription-details :plans="plans" />
    </div>
  </div>
</template>
