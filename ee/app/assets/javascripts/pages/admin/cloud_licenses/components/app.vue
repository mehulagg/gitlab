<script>
import CloudLicenseSubscriptionActivationForm from './subscription_activation_form.vue';

export default {
  name: 'CloudLicenseApp',
  components: {
    CloudLicenseSubscriptionActivationForm,
  },
  props: {
    subscription: {
      required: false,
      type: Object,
      default: null,
    },
  },
  data() {
    return {
      subscriptionData: this.subscription,
    };
  },
};
</script>

<template>
  <div class="gl-display-flex gl-justify-content-center gl-flex-direction-column">
    <h3>{{ s__('CloudLicense|Your Subscription') }}</h3>
    <hr />
    <div class="row">
      <div class="col-12 col-lg-8 offset-lg-2">
        <h3 class="gl-mb-7 gl-mt-6 gl-text-center">
          {{ s__('CloudLicense|This instance is currently using the Core plan.') }}
        </h3>
        <cloud-license-subscription-activation-form v-if="!subscriptionData" />
      </div>
    </div>
  </div>
</template>
