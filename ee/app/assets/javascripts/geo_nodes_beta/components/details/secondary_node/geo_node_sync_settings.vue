<script>
import { timeIntervalInWords } from '~/lib/utils/datetime_utility';
import { sprintf, __, s__ } from '~/locale';

export default {
  name: 'GeoNodeSyncSettings',
  props: {
    node: {
      type: Object,
      required: true,
    },
  },

  computed: {
    syncType() {
      if (this.node.selectiveSyncType === null || this.node.selectiveSyncType === '') {
        return __('Full');
      }

      // Renaming namespaces to groups in the UI for Geo Selective Sync
      const syncLabel =
        this.node.selectiveSyncType === 'namespaces' ? __('groups') : this.node.selectiveSyncType;

      return sprintf(s__('Geo|Selective (%{syncLabel})'), { syncLabel });
    },
    eventTimestampEmpty() {
      return !this.node.lastEventTimestamp || !this.node.cursorLastEventTimestamp;
    },
    syncLagInSeconds() {
      const eventDateTime = new Date(this.node.lastEventTimestamp * 1000);
      const cursorDateTime = new Date(this.node.cursorLastEventTimestamp * 1000);

      return (cursorDateTime - eventDateTime) / 1000;
    },
    syncStatusEventInfo() {
      const timeAgoStr = timeIntervalInWords(this.syncLagInSeconds);
      const pendingEvents = this.node.lastEventId - this.node.cursorLastEventId;

      return sprintf(s__('Geo|%{timeAgoStr} (%{pendingEvents} events)'), {
        timeAgoStr,
        pendingEvents,
      });
    },
  },
};
</script>

<template>
  <div class="gl-display-flex gl-align-items-center">
    <span class="gl-font-weight-bold" data-testid="syncType">{{ syncType }}</span>
    <span
      v-if="!eventTimestampEmpty"
      class="gl-ml-3 gl-text-gray-500 gl-font-sm"
      data-testid="syncStatusEventInfo"
    >
      {{ syncStatusEventInfo }}
    </span>
  </div>
</template>
