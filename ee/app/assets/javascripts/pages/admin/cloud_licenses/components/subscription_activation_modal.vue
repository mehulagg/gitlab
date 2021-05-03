<script>
import { GlModal } from '@gitlab/ui';
import { __ } from '~/locale';
import {
  activateLabel,
  activateSubscription,
  subscriptionActivationInsertCode,
} from '../constants';
import SubscriptionActivationForm from './subscription_activation_form.vue';

export default {
  actionCancel: { text: __('Cancel') },
  actionPrimary: {
    text: activateLabel,
  },
  bodyText: subscriptionActivationInsertCode,
  title: activateSubscription,
  name: 'SubscriptionActivationModal',
  components: {
    GlModal,
    SubscriptionActivationForm,
  },
  props: {
    modalId: {
      type: String,
      required: true,
    },
  },
};
</script>

<template>
  <gl-modal
    :modal-id="modalId"
    :title="$options.title"
    :action-cancel="$options.actionCancel"
    :action-primary="$options.actionPrimary"
  >
    <p>{{ $options.bodyText }}</p>
    <subscription-activation-form />
  </gl-modal>
</template>
