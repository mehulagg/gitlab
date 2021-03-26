<script>
import { GlTooltipDirective } from '@gitlab/ui';
import { formatTime, calculateRemainingMilliseconds } from '~/lib/utils/datetime_utility';
import { s__, sprintf } from '~/locale';
import { isValidSlaDueAt } from './utils';

export default {
  i18n: {
    achievedSLAText: s__('IncidentManagement|Achieved SLA'),
    missedSLAText: s__('IncidentManagement|Missed SLA'),
    longTitle: s__('IncidentManagement|%{hours} hours, %{minutes} minutes remaining'),
    shortTitle: s__('IncidentManagement|%{minutes} minutes remaining'),
  },
  refreshIntervals: {
    // Refresh the timer display every 15 minutes.
    timer: 15 * 60 * 1000,
    // The missed::SLA label is applied via a cron-job that runs every 2 minutes.
    // Delay the final label fetch by this duration to ensure an accurate result.
    labels: 2 * 60 * 1000,
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
    labels: {
      type: Object,
      required: true,
      default: () => ({}),
    },
  },
  data() {
    return {
      clientRemainingTime: null,
    };
  },
  computed: {
    labelList() {
      return this.labels?.nodes?.map((label) => label.title) || [];
    },
    isMissedSLA() {
      return this.remainingTime === 0 && this.labelList.includes('missed::SLA');
    },
    isAchievedSLA() {
      return this.remainingTime === 0 && !this.labelList.includes('missed::SLA');
    },
    shouldShow() {
      return isValidSlaDueAt(this.slaDueAt);
    },
    remainingTime() {
      return this.clientRemainingTime ?? calculateRemainingMilliseconds(this.slaDueAt);
    },
    slaText() {
      console.log(this.remainingTime, this.labelList);
      if (this.isMissedSLA) {
        return this.$options.i18n.missedSLAText;
      }
      if (this.isAchievedSLA) {
        return this.$options.i18n.achievedSLAText;
      }

      const remainingDuration = formatTime(this.remainingTime);

      // remove the seconds portion of the string
      return remainingDuration.substring(0, remainingDuration.length - 3);
    },
    slaTitle() {
      if (this.isMissedSLA || this.isAchievedSLA) {
        return null;
      }

      const minutes = Math.floor(this.remainingTime / 1000 / 60) % 60;
      const hours = Math.floor(this.remainingTime / 1000 / 60 / 60);

      if (hours > 0) {
        return sprintf(this.$options.i18n.longTitle, { hours, minutes });
      }
      return sprintf(this.$options.i18n.shortTitle, { minutes });
    },
  },
  mounted() {
    this.timer = setInterval(this.refreshTime, this.$options.refreshIntervals.timer);
  },
  beforeDestroy() {
    clearTimeout(this.timer);
  },
  methods: {
    refreshTime() {
      if (this.remainingTime > this.$options.refreshIntervals.timer) {
        // This may introduce drift, but it will be minimal given the length of time
        // between updates.
        this.clientRemainingTime = this.remainingTime - this.$options.refreshIntervals.timer;
      } else {
        clearTimeout(this.timer);
        this.timer = this.setTimeout(this.refetchLabels, this.$options.refreshIntervals.labels);
      }
    },
    async refetchLabels() {
      await this.$emit('refetch-labels');
      this.clientRemainingTime = 0;
      clearTimeout(this.timer);
    },
  },
};
</script>
<template>
  <span v-if="shouldShow" v-gl-tooltip :title="slaTitle">
    {{ slaText }}
  </span>
</template>
