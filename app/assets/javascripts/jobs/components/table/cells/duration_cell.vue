<script>
import { GlIcon, GlTooltipDirective } from '@gitlab/ui';
import timeagoMixin from '~/vue_shared/mixins/timeago';

export default {
  directives: {
    GlTooltip: GlTooltipDirective,
  },
  components: {
    GlIcon,
  },
  mixins: [timeagoMixin],
  props: {
    job: {
      type: Object,
      required: true,
    },
  },
  computed: {
    finishedTime() {
      return this.job?.finishedAt;
    },
    duration() {
      return this.job?.duration;
    },
  },
};
</script>

<template>
  <div>
    <div v-if="duration">
      <gl-icon name="timer" :size="12" />
      {{ durationTimeFormatted(duration) }}
    </div>
    <div v-if="finishedTime">
      <gl-icon name="calendar" :size="12" />
      <time
        v-gl-tooltip
        :title="tooltipTitle(finishedTime)"
        data-placement="top"
        data-container="body"
      >
        {{ timeFormatted(finishedTime) }}
      </time>
    </div>
  </div>
</template>
