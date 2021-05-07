<script>
import { GlButton, GlCard } from '@gitlab/ui';
import { buySubscriptionCard } from '../constants';

export default {
  i18n: {
    title: buySubscriptionCard.title,
    description: buySubscriptionCard.description,
    buttonLabel: buySubscriptionCard.buttonLabel,
  },
  name: 'SubscriptionPurchaseCard',
  components: { GlCard, GlButton },
  inject: ['buySubscriptionPath'],
};
</script>
<template>
  <gl-card>
    <template #header>
      <h5 class="gl-my-0 gl-font-weight-bold">{{ $options.i18n.title }}</h5>
    </template>
    <p>{{ $options.i18n.description }}</p>
    <gl-button
      category="secondary"
      class="gl-mt-6"
      data-testid="buy-subscription-button"
      variant="confirm"
      :href="buySubscriptionPath"
    >
      {{ $options.i18n.buttonLabel }}
    </gl-button>
  </gl-card>
</template>
