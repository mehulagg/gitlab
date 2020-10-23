<script>
import { GlIcon, GlTooltipDirective } from '@gitlab/ui';
import { sprintf, s__, __ } from '~/locale';
import { timeIntervalInWords } from '~/lib/utils/datetime_utility';
import { TIME_DIFF } from '../constants';

export default {
  directives: {
    GlTooltip: GlTooltipDirective,
  },
  components: {
    GlIcon,
  },
  props: {
    syncStatusUnavailable: {
      type: Boolean,
      required: false,
      default: false,
    },
    selectiveSyncType: {
      type: String,
      required: false,
      default: null,
    },
    lastEvent: {
      type: Object,
      required: true,
    },
    cursorLastEvent: {
      type: Object,
      required: true,
    },
  },

  computed: {
    syncType() {
      if (this.selectiveSyncType === null || this.selectiveSyncType === '') {
        return s__('GeoNodes|Full');
      }

      // Renaming namespaces to groups in the UI for Geo Selective Sync
      const syncLabel =
        this.selectiveSyncType === 'namespaces' ? __('groups') : this.selectiveSyncType;

      return sprintf(s__('GeoNodes|Selective (%{syncLabel})'), { syncLabel });
    },
    eventTimestampEmpty() {
      return this.lastEvent.timeStamp === 0 || this.cursorLastEvent.timeStamp === 0;
    },
    syncLagInSeconds() {
      return this.lagInSeconds(this.lastEvent.timeStamp, this.cursorLastEvent.timeStamp);
    },
    syncStatusIcon() {
      return this.statusIcon(this.syncLagInSeconds);
    },
    syncStatusEventInfo() {
      return this.statusEventInfo(
        this.lastEvent.id,
        this.cursorLastEvent.id,
        this.syncLagInSeconds,
      );
    },
    syncStatusTooltip() {
      return this.statusTooltip(this.syncLagInSeconds);
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
    statusIcon(syncLag) {
      if (syncLag <= TIME_DIFF.FIVE_MINS) {
        return 'retry';
      } else if (syncLag > TIME_DIFF.FIVE_MINS && syncLag <= TIME_DIFF.HOUR) {
        return 'warning';
      }
      return 'status_failed';
    },
    statusEventInfo(lastEventId, cursorLastEventId, lagInSeconds) {
      const timeAgoStr = timeIntervalInWords(lagInSeconds);
      const pendingEvents = lastEventId - cursorLastEventId;
      return sprintf(s__('GeoNodeStatusEvent|%{timeAgoStr} (%{pendingEvents} events)'), {
        timeAgoStr,
        pendingEvents,
      });
    },
    statusTooltip(lagInSeconds) {
      if (this.eventTimestampEmpty || lagInSeconds <= TIME_DIFF.FIVE_MINS) {
        return '';
      } else if (lagInSeconds > TIME_DIFF.FIVE_MINS && lagInSeconds <= TIME_DIFF.HOUR) {
        return s__(
          'GeoNodeSyncStatus|Node is slow, overloaded, or it just recovered after an outage.',
        );
      }
      return s__('GeoNodeSyncStatus|Node is failing or broken.');
    },
  },
};
</script>

<template>
  <div class="mt-1 node-sync-settings">
    <strong v-if="syncStatusUnavailable"> {{ __('Unknown') }} </strong>
    <span
      v-else
      v-gl-tooltip
      :title="syncStatusTooltip"
      class="d-inline-block gl-align-items-center"
    >
      <strong data-testid="syncType">{{ syncType }}</strong>
      <gl-icon name="retry" class="ml-2" />
      <span v-if="!eventTimestampEmpty" class="ml-2">
        {{ syncStatusEventInfo }}
      </span>
    </span>
  </div>
</template>
