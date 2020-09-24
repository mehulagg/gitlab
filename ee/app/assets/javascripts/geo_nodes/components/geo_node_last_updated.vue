<script>
import { GlPopover, GlLink, GlIcon } from '@gitlab/ui';

import { sprintf, s__ } from '~/locale';
import timeAgoMixin from '~/vue_shared/mixins/timeago';

import {
  HELP_NODE_HEALTH_URL,
  GEO_TROUBLESHOOTING_URL,
  STATUS_DELAY_THRESHOLD_MS,
} from '../constants';

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
  <div class="d-flex align-items-center">
    <span data-testid="nodeLastUpdateMainText" class="text-secondary-700">{{
      syncTimeAgo.mainText
    }}</span>
    <gl-icon
      ref="lastUpdated"
      tabindex="0"
      name="question"
      class="text-primary-600 ml-1 cursor-pointer"
    />
    <gl-popover :target="() => $refs.lastUpdated.$el" placement="top" triggers="hover focus">
      <p>{{ syncTimeAgo.popoverText }}</p>
      <gl-link class="mt-3 gl-font-sm" :href="syncHelp.link" target="_blank">{{
        syncHelp.text
      }}</gl-link>
    </gl-popover>
  </div>
</template>
