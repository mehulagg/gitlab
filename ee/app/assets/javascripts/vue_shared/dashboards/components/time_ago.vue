<script>
import { GlTooltip, GlIcon } from '@gitlab/ui';
import timeagoMixin from '~/vue_shared/mixins/timeago';

export default {
  components: {
    GlTooltip,
    GlIcon,
  },

  mixins: [timeagoMixin],

  props: {
    time: {
      type: String,
      required: true,
    },
    tooltipText: {
      type: String,
      required: true,
    },
  },
  computed: {
    timeTitle() {
      return this.tooltipTitle(this.time);
    },
    formattedTime() {
      return this.timeFormatted(this.time);
    },
  },
};
</script>
<template>
  <div class="text-secondary">
    <gl-icon
      name="clock"
      class="dashboard-card-icon align-text-bottom js-dashboard-project-clock-icon"
    />

    <time ref="timeAgo" class="js-dashboard-project-time-ago">
      {{ formattedTime }}
    </time>
    <gl-tooltip :target="() => $refs.timeAgo">
      <div class="bold">{{ tooltipText }}</div>
      <div>{{ timeTitle }}</div>
    </gl-tooltip>
  </div>
</template>
