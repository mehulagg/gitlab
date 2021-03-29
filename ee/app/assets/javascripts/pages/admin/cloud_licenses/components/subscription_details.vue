<script>
import { GlButton, GlCard } from '@gitlab/ui';
import { s__ } from '~/locale';

export default {
  name: 'SubscriptionBreakdownView',
  i18n: {
    cardHeaderText: s__('CloudLicense|Subscription details'),
    syncSubscriptionButtonText: s__('CloudLicense|Sync Subscription details'),
    manageSubscriptionButtonText: s__('CloudLicense|Manage'),
  },
  components: {
    GlButton,
    GlCard,
  },
};
</script>

<template>
  <gl-card title="">
    <template #header>{{ $options.i18n.cardHeaderText }}</template>
    <template #footer>
      <gl-button category="primary" variant="confirm">
        {{ $options.i18n.syncSubscriptionButtonText }}
      </gl-button>
      <gl-button>
        {{ $options.i18n.manageSubscriptionButtonText }}
      </gl-button>
    </template>
  </gl-card>
</template>
