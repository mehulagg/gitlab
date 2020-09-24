<script>
import { n__ } from '~/locale';
import { GlIcon } from '@gitlab/ui';
import { GlTooltipDirective } from '@gitlab/ui';
import { EVENTS_LIST_ITEM_LIMIT } from '../constants';

export default {
  components: {
    GlIcon,
  },
  directives: {
    GlTooltip: GlTooltipDirective,
  },
  props: {
    count: {
      type: Number,
      required: true,
    },
  },
  eventsListItemLimit: EVENTS_LIST_ITEM_LIMIT,
  tooltipTitle: n__(
    'Limited to showing %d event at most',
    'Limited to showing %d events at most',
    EVENTS_LIST_ITEM_LIMIT,
  ),
};
</script>
<template>
  <!-- TODO: im not sure why this is rendered only for exactly 50 items, why not >= 50? -->
  <span v-if="count >= EVENTS_LIST_ITEM_LIMIT" class="events-info float-right">
    <gl-icon v-gl-tooltip="{ title: $options.tooltipTitle }" name="warning" aria-hidden="true" />
    {{ n__('Showing %d event', 'Showing %d events', $options.eventsListItemLimit) }}
  </span>
</template>
