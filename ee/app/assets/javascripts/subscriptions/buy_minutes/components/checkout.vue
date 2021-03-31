<script>
import gql from 'graphql-tag';
import ProgressBar from 'ee/registrations/components/progress_bar.vue';
import { STEPS, SUBSCRIPTON_FLOW_STEPS } from 'ee/registrations/constants';
import { s__ } from '~/locale';
import BillingAddress from './checkout/billing_address.vue';
import ConfirmOrder from './checkout/confirm_order.vue';
import PaymentMethod from './checkout/payment_method.vue';
import SubscriptionDetails from './checkout/subscription_details.vue';

const CHECKOUT_STATE_QUERY = gql`
  query getCheckoutState {
    state @client {
      isNewUser
      customer {
        country
        address1
        address2
        city
        state
        zipCode
        company
        paymentMethodId
      }
      subscription {
        planId
        paymentMethodId,
        products {
          main {
            quantity
          }
        }
        namespaceId
        namespaceName
      }
    }
  }
`;
const COUNTRIES_QUERY = gql`
query getCountries {
  countries @client {
    name
    alpha2
  }
}
`;

export default {
  name: 'Checkout',
  components: { ProgressBar, SubscriptionDetails, BillingAddress, PaymentMethod, ConfirmOrder },
  apollo: {
    state: {
      query: CHECKOUT_STATE_QUERY,
    },
    countries: {
      query: COUNTRIES_QUERY,
    },
  },
  data() {
    return {
      state: {},
    };
  },
  methods: {
    confirm() {

    }
  },
  currentStep: STEPS.checkout,
  steps: SUBSCRIPTON_FLOW_STEPS,
  i18n: {
    checkout: s__('Checkout|Checkout'),
  },
};
</script>

<template>
  <div class="checkout d-flex flex-column justify-content-between w-100">
    <div v-if="state.customer" class="full-width">
      <progress-bar v-if="state.isNewUser" :steps="$options.steps" :current-step="currentStep" />
      <div class="flash-container"></div>
      <h2 class="mt-4 mb-3 mb-lg-5">{{ $options.i18n.checkout }}</h2>
      <subscription-details
        :plans="state.plans"
        :namespaces="state.namespaces"
        :is-new-user="state.isNewUser"
        :is-setup-for-company="state.isSetupForCompany"
      />
      <billing-address
        :customer="state.customer"
        :countries="state.countries"
      />
      <payment-method :payment-method="state.customer.paymentMethod" />
    </div>
    <confirm-order :current-step="state.currentStep" @confirm="confirm" />
  </div>
</template>
