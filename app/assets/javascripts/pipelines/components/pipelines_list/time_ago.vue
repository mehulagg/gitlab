<script>
import { GlIcon, GlTooltipDirective } from '@gitlab/ui';
import timeagoMixin from '~/vue_shared/mixins/timeago';

export default {
  directives: {
    GlTooltip: GlTooltipDirective,
  },
  components: { GlIcon },
  mixins: [timeagoMixin],
  props: {
    pipeline: {
      type: Object,
      required: true,
    },
  },
  computed: {
    duration() {
      return this.pipeline?.details?.duration;
    },
    finishedTime() {
      return this.pipeline?.details?.finished_at;
    },
    hasDuration() {
      return this.duration > 0;
    },
    hasFinishedTime() {
      return this.finishedTime !== '';
    },
    durationFormatted() {
      const date = new Date(this.duration * 1000);

      let hh = date.getUTCHours();
      let mm = date.getUTCMinutes();
      let ss = date.getSeconds();

      // left pad
      if (hh < 10) {
        hh = `0${hh}`;
      }
      if (mm < 10) {
        mm = `0${mm}`;
      }
      if (ss < 10) {
        ss = `0${ss}`;
      }

      return `${hh}:${mm}:${ss}`;
    },
  },
};
</script>
<template>
  <div>
    <p v-if="hasDuration" class="duration gl-mb-0">
      <gl-icon name="timer" class="gl-vertical-align-baseline!" :size="12" />
      {{ durationFormatted }}
    </p>

    <p v-if="hasFinishedTime" class="finished-at d-none d-md-block gl-mb-0">
      <gl-icon name="calendar" class="gl-vertical-align-baseline!" :size="12" />

      <time
        v-gl-tooltip
        :title="tooltipTitle(finishedTime)"
        data-placement="top"
        data-container="body"
      >
        {{ timeFormatted(finishedTime) }}
      </time>
    </p>
  </div>
</template>
