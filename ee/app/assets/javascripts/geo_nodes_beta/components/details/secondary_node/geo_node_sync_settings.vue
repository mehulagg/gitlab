<script>
import { timeIntervalInWords } from '~/lib/utils/datetime_utility';
import { sprintf, __, s__ } from '~/locale';

export default {
  name: 'GeoNodeSyncSettings',
  i18n: {
    full: __('Full'),
    groups: __('groups'),
    syncLabel: s__('Geo|Selective (%{syncLabel})'),
    pendingEvents: s__('Geo|%{timeAgoStr} (%{pendingEvents} events)'),
  },
  props: {
    node: {
      type: Object,
      required: true,
    },
  },

  computed: {
    syncType() {
      if (this.node.selectiveSyncType === null || this.node.selectiveSyncType === '') {
        return this.$options.i18n.full;
      }

      // Renaming namespaces to groups in the UI for Geo Selective Sync
      const syncLabel =
        this.node.selectiveSyncType === 'namespaces'
          ? this.$options.i18n.groups
          : this.node.selectiveSyncType;

      return sprintf(this.$options.i18n.syncLabel, { syncLabel });
    },
    eventTimestampEmpty() {
      return !this.node.lastEventTimestamp || !this.node.cursorLastEventTimestamp;
    },
    syncLagInSeconds() {
      return this.node.cursorLastEventTimestamp - this.node.lastEventTimestamp;
    },
    syncStatusEventInfo() {
      const timeAgoStr = timeIntervalInWords(this.syncLagInSeconds);
      const pendingEvents = this.node.lastEventId - this.node.cursorLastEventId;

      return sprintf(this.$options.i18n.pendingEvents, {
        timeAgoStr,
        pendingEvents,
      });
    },
  },
};
</script>

<template>
  <div class="gl-display-flex gl-align-items-center">
    <span class="gl-font-weight-bold" data-testid="sync-type">{{ syncType }}</span>
    <span
      v-if="!eventTimestampEmpty"
      class="gl-ml-3 gl-text-gray-500 gl-font-sm"
      data-testid="sync-status-event-info"
    >
      {{ syncStatusEventInfo }}
    </span>
  </div>
</template>
