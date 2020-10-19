<script>
import { GlTooltipDirective } from '@gitlab/ui';
import { s__, sprintf } from '~/locale';
import { formatTime, calculateRemainingMilliseconds } from '~/lib/utils/datetime_utility';

export default {
  i18n: {
    longTitle: s__('IncidentManagement|%{hours} hours, %{minutes} minutes remaining'),
    shortTitle: s__('IncidentManagement|%{minutes} minutes remaining'),
    missedSla: s__('IncidentManagement|Missed SLA'),
  },
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
  computed: {
    shouldShow() {
      // Checks for a valid date string
      return Boolean(this.slaDueAt) && !Number.isNaN(Date.parse(this.slaDueAt));
    },
    remainingTime() {
      return calculateRemainingMilliseconds(this.slaDueAt);
    },
    slaText() {
      if (this.remainingTime === 0) {
        return this.$options.i18n.missedSla;
      }

      const remainingDuration = formatTime(this.remainingTime);

      // remove the seconds portion of the string
      return remainingDuration.substring(0, remainingDuration.length - 3);
    },
    slaTitle() {
      if (this.remainingTime === 0) {
        return null;
      }

      const minutes = Math.floor(this.remainingTime / 1000 / 60) % 60;
      const hours = Math.floor(this.remainingTime / 1000 / 60 / 60);

      if (hours > 0) {
        return sprintf(this.$options.i18n.longTitle, { hours, minutes });
      }
      return sprintf(this.$options.i18n.shortTitle, { hours, minutes });
    },
  },
  watch: {
    shouldShow(value) {
      this.$emit('update', value);
    },
  },
};
</script>
<template>
  <span v-if="shouldShow" v-gl-tooltip :title="slaTitle">
    {{ slaText }}
  </span>
</template>
