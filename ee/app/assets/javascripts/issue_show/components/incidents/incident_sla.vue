<script>
import { GlIcon, GlLoadingIcon } from '@gitlab/ui';
import createFlash from '~/flash';
import { s__ } from '~/locale';
import { formatTime, calculateRemainingMilliseconds } from '~/lib/utils/datetime_utility';
import TimeAgoTooltip from '~/vue_shared/components/time_ago_tooltip.vue';
import getSlaDueAt from './graphql/queries/get_sla_due_at.graphql';

export default {
  components: { GlIcon, GlLoadingIcon, TimeAgoTooltip },
  inject: ['fullPath', 'iid', 'slaFeatureAvailable'],
  apollo: {
    slaDueAt: {
      query: getSlaDueAt,
      variables() {
        return {
          fullPath: this.fullPath,
          iid: this.iid,
        };
      },
      update(data) {
        return data?.project?.issue?.slaDueAt;
      },
      error() {
        createFlash({
          message: s__('Incident|There was an issue loading incident data. Please try again.'),
        });
      },
    },
  },
  data() {
    return {
      slaDueAt: null,
    };
  },
  computed: {
    displayValue() {
      const time = formatTime(calculateRemainingMilliseconds(this.slaDueAt));

      // remove the seconds portion of the string
      return time.substring(0, time.length - 3);
    },
    show() {
      return this.slaFeatureAvailable && this.slaDueAt !== null;
    },
  },
};
</script>

<template>
  <div v-if="slaFeatureAvailable">
    <span class="gl-font-weight-bold">{{ s__('HighlightBar|Time to SLA:') }}</span>
    <time-ago-tooltip v-if="slaDueAt" :time="slaDueAt">
      <gl-icon name="timer" />
      <span>{{ displayValue }}</span>
    </time-ago-tooltip>
    <gl-loading-icon v-else inline />
  </div>
</template>
