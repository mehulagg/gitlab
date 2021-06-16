<script>
import { GlButton, GlCard } from '@gitlab/ui';
import { trialCard } from '../constants';

export default {
  i18n: {
    title: trialCard.title,
    startTrial: trialCard.startTrial,
    description: trialCard.description,
  },
  name: 'SubscriptionTrialCard',
  components: {
    GlCard,
    GlButton,
  },
  inject: ['freeTrialPath'],
};
</script>

<template>
  <gl-card>
    <template #header>
      <h5 class="gl-my-0 gl-font-weight-bold">{{ $options.i18n.title }}</h5>
    </template>
    <p>
      {{ $options.i18n.description }}
    </p>
    <gl-button
      category="secondary"
      class="gl-mt-6"
      data-testid="free-trial-button"
      variant="confirm"
      :href="freeTrialPath"
    >
      {{ $options.i18n.startTrial }}
    </gl-button>
  </gl-card>
</template>
