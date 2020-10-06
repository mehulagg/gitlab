<script>
import { GlIcon } from '@gitlab/ui';
import createFlash from '~/flash';
import { s__ } from '~/locale';
import getSlaDueAt from './graphql/queries/get_sla_due_at.graphql';
import TimeAgoTooltip from '~/vue_shared/components/time_ago_tooltip.vue';

export default {
  components: { GlIcon, TimeAgoTooltip },
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
      const hoursInMilliseconds = 60 * 60 * 1000;
      const difference = new Date(this.slaDueAt) - Date.now();

      if (difference < 0) {
        return '00:00';
      }

      const rawHours = difference / hoursInMilliseconds;
      const hours = Math.floor(rawHours);
      const minutes = Math.floor((rawHours * 60) % 60);

      return `${hours}:${minutes}`;
    },
    show() {
      return this.slaFeatureAvailable && this.slaDueAt !== null;
    },
  },
};
</script>

<template>
  <div v-if="show">
    <!-- TODO: add loading state -->
    <span class="gl-font-weight-bold">{{ s__('HighlightBar|Time to SLA:') }}</span>
    <time-ago-tooltip :time="slaDueAt">
      <gl-icon name="timer" />
      <span>{{ displayValue }}</span>
    </time-ago-tooltip>
  </div>
</template>
