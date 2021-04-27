<script>
import { GlPopover, GlLink, GlIcon } from '@gitlab/ui';
import {
  HELP_NODE_HEALTH_URL,
  GEO_TROUBLESHOOTING_URL,
  STATUS_DELAY_THRESHOLD_MS,
} from 'ee/geo_nodes_beta/constants';
import { s__, __ } from '~/locale';
import TimeAgo from '~/vue_shared/components/time_ago_tooltip.vue';

export default {
  name: 'GeoNodeLastUpdated',
  i18n: {
    troubleshootText: s__('Geo|Consult Geo troubleshooting information'),
    learnMoreText: s__('Geo|Learn more about Geo node statuses'),
    timeAgoMainText: __('Updated'),
    timeAgoPopoverText: s__(`Geo|Node's status was updated`),
  },
  components: {
    GlPopover,
    GlLink,
    GlIcon,
    TimeAgo,
  },
  props: {
    statusCheckTimestamp: {
      type: Number,
      required: true,
    },
  },
  computed: {
    isSyncStale() {
      const elapsedMilliseconds = Math.abs(this.statusCheckTimestamp - Date.now());
      return elapsedMilliseconds > STATUS_DELAY_THRESHOLD_MS;
    },
    syncHelp() {
      if (this.isSyncStale) {
        return {
          text: this.$options.i18n.troubleshootText,
          link: GEO_TROUBLESHOOTING_URL,
        };
      }

      return {
        text: this.$options.i18n.learnMoreText,
        link: HELP_NODE_HEALTH_URL,
      };
    },
    timeAgo() {
      const time = this.statusCheckTimestamp;
      return new Date(time).toString();
    },
  },
};
</script>

<template>
  <div class="gl-display-flex gl-align-items-center">
    <span class="gl-text-gray-500" data-testid="last-updated-main-text"
      >{{ $options.i18n.timeAgoMainText }} <time-ago :time="timeAgo"
    /></span>
    <gl-icon
      ref="lastUpdated"
      tabindex="0"
      name="question"
      class="gl-text-blue-500 gl-cursor-pointer gl-ml-2"
    />
    <gl-popover :target="() => $refs.lastUpdated.$el" placement="top">
      <p>{{ $options.i18n.timeAgoPopoverText }} <time-ago :time="timeAgo" /></p>
      <gl-link :href="syncHelp.link" target="_blank">{{ syncHelp.text }}</gl-link>
    </gl-popover>
  </div>
</template>
