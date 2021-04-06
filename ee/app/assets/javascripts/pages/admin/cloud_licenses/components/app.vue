<script>
import { s__, sprintf } from '~/locale';
import CloudLicenseSubscriptionActivationForm from './subscription_activation_form.vue';

export default {
  name: 'CloudLicenseApp',
  components: {
    CloudLicenseSubscriptionActivationForm,
  },
  i18n: {
    mainTitle: s__(`CloudLicense|This instance is currently using the %{planName} plan.`),
  },
  inject: ['planName'],
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
  computed: {
    mainTitle() {
      return sprintf(this.$options.i18n.mainTitle, {
        planName: this.planName,
      });
    },
  },
};
</script>

<template>
  <div class="gl-display-flex gl-justify-content-center gl-flex-direction-column">
    <h3 class="gl-mb-7 gl-mt-6 gl-text-center">{{ mainTitle }}</h3>
    <cloud-license-subscription-activation-form v-if="!subscriptionData" />
  </div>
</template>
