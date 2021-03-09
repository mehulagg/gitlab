<script>
import { timeIntervalInWords } from '~/lib/utils/datetime_utility';
import { sprintf, __ } from '~/locale';

export default {
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

      return sprintf(__('Selective (%{syncLabel})'), { syncLabel });
    },
    eventTimestampEmpty() {
      return this.node.lastEventTimestamp === 0 || this.node.cursorLastEventTimestamp === 0;
    },
    syncLagInSeconds() {
      return this.lagInSeconds(this.node.lastEventTimestamp, this.node.cursorLastEventTimestamp);
    },
    syncStatusEventInfo() {
      return this.statusEventInfo(
        this.node.lastEventId,
        this.node.cursorLastEventId,
        this.syncLagInSeconds,
      );
    },
  },
  methods: {
    lagInSeconds(lastEventTimeStamp, cursorLastEventTimeStamp) {
      let eventDateTime;
      let cursorDateTime;

      if (lastEventTimeStamp && lastEventTimeStamp > 0) {
        eventDateTime = new Date(lastEventTimeStamp * 1000);
      }

      if (cursorLastEventTimeStamp && cursorLastEventTimeStamp > 0) {
        cursorDateTime = new Date(cursorLastEventTimeStamp * 1000);
      }

      return (cursorDateTime - eventDateTime) / 1000;
    },
    statusEventInfo(lastEventId, cursorLastEventId, lagInSeconds) {
      const timeAgoStr = timeIntervalInWords(lagInSeconds);
      const pendingEvents = lastEventId - cursorLastEventId;
      return sprintf(__('%{timeAgoStr} (%{pendingEvents} events)'), {
        timeAgoStr,
        pendingEvents,
      });
    },
  },
};
</script>

<template>
  <div class="gl-display-flex gl-align-items-center">
    <span class="gl-font-weight-bold">{{ syncType }}</span>
    <span v-if="!eventTimestampEmpty" class="gl-ml-3 gl-text-gray-500 gl-font-sm">
      {{ syncStatusEventInfo }}
    </span>
  </div>
</template>
