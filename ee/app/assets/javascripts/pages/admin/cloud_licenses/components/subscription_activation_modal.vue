<script>
import { GlModal } from '@gitlab/ui';
import SubscriptionActivationForm from './subscription_activation_form.vue';

export default {
  name: 'SubscriptionActivationModal',
  components: {
    GlModal,
    SubscriptionActivationForm,
  },
};
</script>

<template>
  <gl-modal>
    <subscription-activation-form />
  </gl-modal>
</template>
