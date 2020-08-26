<script>
import { GlTooltipDirective } from '@gitlab/ui';
import { EVENTS_LIST_ITEM_LIMIT } from '../constants';

export default {
  directives: {
    GlTooltip: GlTooltipDirective,
  },
  props: {
    count: {
      type: Number,
      required: true,
    },
  },
  data() {
    return { EVENTS_LIST_ITEM_LIMIT };
  },

  emits: [],
};
</script>
<template>
  <!-- TODO: im not sure why this is rendered only for exactly 50 items, why not >= 50? -->
  <span v-if="count >= EVENTS_LIST_ITEM_LIMIT" class="events-info float-right">
    <i
      v-gl-tooltip
      :title="
        n__(
          'Limited to showing %d event at most',
          'Limited to showing %d events at most',
          EVENTS_LIST_ITEM_LIMIT,
        )
      "
      class="fa fa-warning"
      aria-hidden="true"
    >
    </i>
    {{ n__('Showing %d event', 'Showing %d events', EVENTS_LIST_ITEM_LIMIT) }}
  </span>
</template>
