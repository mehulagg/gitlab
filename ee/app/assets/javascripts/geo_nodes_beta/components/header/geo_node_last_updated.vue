<script>
import { GlPopover, GlLink, GlIcon } from '@gitlab/ui';
import {
  HELP_NODE_HEALTH_URL,
  GEO_TROUBLESHOOTING_URL,
  STATUS_DELAY_THRESHOLD_MS,
} from 'ee/geo_nodes_beta/constants';
import { sprintf, s__ } from '~/locale';
import timeAgoMixin from '~/vue_shared/mixins/timeago';

export default {
  name: 'GeoNodeLastUpdated',
  components: {
    GlPopover,
    GlLink,
    GlIcon,
  },
  mixins: [timeAgoMixin],
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
          text: s__('GeoNodes|Consult Geo troubleshooting information'),
          link: GEO_TROUBLESHOOTING_URL,
        };
      }

      return {
        text: s__('GeoNodes|Learn more about Geo node statuses'),
        link: HELP_NODE_HEALTH_URL,
      };
    },
    syncTimeAgo() {
      const timeAgo = this.timeFormatted(this.statusCheckTimestamp);

      return {
        mainText: sprintf(s__('GeoNodes|Updated %{timeAgo}'), { timeAgo }),
        popoverText: sprintf(s__("GeoNodes|Node's status was updated %{timeAgo}."), { timeAgo }),
      };
    },
  },
};
</script>

<template>
  <div class="gl-display-flex gl-align-items-center">
    <span class="gl-text-gray-500" data-testid="last-updated-main-text">{{
      syncTimeAgo.mainText
    }}</span>
    <gl-icon
      ref="lastUpdated"
      tabindex="0"
      name="question"
      class="gl-text-blue-500 gl-cursor-pointer gl-ml-2"
    />
    <gl-popover :target="() => $refs.lastUpdated.$el" placement="top">
      <p>{{ syncTimeAgo.popoverText }}</p>
      <gl-link :href="syncHelp.link" target="_blank">{{ syncHelp.text }}</gl-link>
    </gl-popover>
  </div>
</template>
