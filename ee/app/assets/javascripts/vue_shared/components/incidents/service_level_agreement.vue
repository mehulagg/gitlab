<script>
import { GlTooltipDirective } from '@gitlab/ui';
import { formatTime, calculateRemainingMilliseconds } from '~/lib/utils/datetime_utility';
import { s__, sprintf } from '~/locale';
import { isValidSlaDueAt } from './utils';

export default {
  i18n: {
    longTitle: s__('IncidentManagement|%{hours} hours, %{minutes} minutes remaining'),
    shortTitle: s__('IncidentManagement|%{minutes} minutes remaining'),
  },
  FIFTEEN_MINUTES: 15 * 60 * 1000, // in milliseconds
  directives: {
    GlTooltip: GlTooltipDirective,
  },
  props: {
    slaDueAt: {
      type: String, // ISODateString
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
      return isValidSlaDueAt(this.slaDueAt);
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
        return sprintf(this.$options.i18n.longTitle, { hours, minutes });
      }
      return sprintf(this.$options.i18n.shortTitle, { minutes });
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
