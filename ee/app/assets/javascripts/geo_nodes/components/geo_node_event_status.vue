<script>
import { GlTooltipDirective } from '@gitlab/ui';
import { formatDate } from '~/lib/utils/datetime_utility';
import timeAgoMixin from '~/vue_shared/mixins/timeago';

export default {
  directives: {
    GlTooltip: GlTooltipDirective,
  },
  mixins: [timeAgoMixin],
  props: {
    eventId: {
      type: Number,
      required: true,
    },
    eventTimeStamp: {
      type: Number,
      required: true,
      default: 0,
    },
    eventTypeLogStatus: {
      type: Boolean,
      required: false,
      default: false,
    },
  },
  computed: {
    timeStamp() {
      return new Date(this.eventTimeStamp * 1000);
    },
    timeStampString() {
      return formatDate(this.timeStamp);
    },
    eventString() {
      return this.eventId;
    },
  },
};
</script>

<template>
  <div class="mt-1 node-detail-value">
    <template v-if="eventTimeStamp">
      <strong> {{ eventString }} </strong>
      <span
        v-if="eventTimeStamp"
        v-gl-tooltip
        :title="timeStampString"
        class="event-status-timestamp"
      >
        ({{ timeFormatted(timeStamp) }})
      </span>
    </template>
    <strong v-else> {{ __('Not available') }} </strong>
  </div>
</template>
