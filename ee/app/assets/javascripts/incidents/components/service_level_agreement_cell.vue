<script>
import { GlTooltipDirective } from '@gitlab/ui';
import { s__, sprintf } from '~/locale';
import { formatTime, calculateRemainingMilliseconds } from '~/lib/utils/datetime_utility';

export default {
  i18n: {
    longText: s__('IncidentManagement|%{hours} hours, %{minutes} minutes remaining'),
    shortText: s__('IncidentManagement|%{minutes} minutes remaining'),
  },
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
  computed: {
    shouldShow() {
      // Checks for a valid date string
      return this.slaDueAt && !Number.isNaN(Date.parse(this.slaDueAt));
    },
    remainingTime() {
      return calculateRemainingMilliseconds(this.slaDueAt);
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
};
</script>
<template>
  <span v-if="shouldShow" v-gl-tooltip :title="slaTitle">
    {{ slaText }}
  </span>
</template>
