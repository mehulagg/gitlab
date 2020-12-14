<script>
import { GlTooltipDirective } from '@gitlab/ui';
import { s__, sprintf } from '~/locale';
import { formatTime, calculateRemainingMilliseconds } from '~/lib/utils/datetime_utility';

export default {
  i18n: {
    longText: s__('IncidentManagement|%{hours} hours, %{minutes} minutes remaining'),
    shortText: s__('IncidentManagement|%{minutes} minutes remaining'),
  },
  FIFTEEN_MINUTES: 15 * 60 * 1000, // in milliseconds
  directives: {
    GlTooltip: GlTooltipDirective,
  },
  props: {
    slaDueAt: {
      type: String,
      required: false,
      default: null,
    },
  },
  data() {
    return {
      clientRemainingTime: null,
    };
  },
  computed: {
    shouldShow() {
      // Checks for a valid date string
      return this.slaDueAt && !Number.isNaN(Date.parse(this.slaDueAt));
    },
    remainingTime() {
      return this.clientRemainingTime ?? calculateRemainingMilliseconds(this.slaDueAt);
    },
    slaText() {
      const remainingDuration = formatTime(this.remainingTime);

      // remove the seconds portion of the string
      return remainingDuration.substring(0, remainingDuration.length - 3);
    },
    slaTitle() {
      const minutes = Math.floor(this.remainingTime / 1000 / 60) % 60;
      const hours = Math.floor(this.remainingTime / 1000 / 60 / 60);

      if (hours > 0) {
        return sprintf(this.$options.i18n.longText, { hours, minutes });
      }
      return sprintf(this.$options.i18n.shortText, { hours, minutes });
    },
  },
  mounted() {
    this.timer = setInterval(() => this.refreshTime(), this.$options.FIFTEEN_MINUTES);
  },
  beforeDestroy() {
    clearTimeout(this.timer);
  },
  methods: {
    refreshTime() {
      if (this.remainingTime > this.$options.FIFTEEN_MINUTES) {
        // This may introduce drift, but it will be minimal given the length of time
        // between updates.
        this.clientRemainingTime = this.remainingTime - this.$options.FIFTEEN_MINUTES;
      } else {
        this.clientRemainingTime = 0;
        clearTimeout(this.timer);
      }
    },
  },
};
</script>
<template>
  <span v-if="shouldShow" v-gl-tooltip :title="slaTitle">
    {{ slaText }}
  </span>
</template>
