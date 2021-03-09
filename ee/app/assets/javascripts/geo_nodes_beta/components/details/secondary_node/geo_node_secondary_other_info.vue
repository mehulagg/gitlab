<script>
import { GlCard } from '@gitlab/ui';
import { parseSeconds, stringifyTime } from '~/lib/utils/datetime_utility';
import { __, s__ } from '~/locale';
import timeAgoMixin from '~/vue_shared/mixins/timeago';

export default {
  name: 'GeoNodeSecondaryOtherInfo',
  i18n: {
    otherInfo: __('Other information'),
    dbReplicationLag: s__('Geo|Data replication lag'),
    lastEventId: s__('Geo|Last event ID from primary'),
    lastCursorEventId: s__('Geo|Last event ID processed by cursor'),
    storageConfig: s__('Geo|Storage config'),
  },
  components: {
    GlCard,
  },
  mixins: [timeAgoMixin],
  props: {
    node: {
      type: Object,
      required: true,
    },
  },
  computed: {
    storageShardsStatus() {
      if (this.node.storageShardsMatch == null) {
        return __('Unknown');
      }

      return this.node.storageShardsMatch
        ? __('OK')
        : s__('Geo|Does not match the primary storage configuration');
    },
    dbReplicationLag() {
      // Replication lag can be nil if the secondary isn't actually streaming
      if (this.node.dbReplicationLagSeconds !== null && this.node.dbReplicationLagSeconds >= 0) {
        const parsedTime = parseSeconds(this.node.dbReplicationLagSeconds, {
          hoursPerDay: 24,
          daysPerWeek: 7,
        });

        return stringifyTime(parsedTime);
      }

      return __('Unknown');
    },
  },
};
</script>

<template>
  <gl-card>
    <template #header>
      <h5 class="gl-my-3">{{ $options.i18n.otherInfo }}</h5>
    </template>
    <div class="gl-display-flex gl-flex-direction-column gl-mb-5">
      <span>{{ $options.i18n.dbReplicationLag }}</span>
      <span class="gl-font-weight-bold gl-mt-2" data-testid="replication-lag">{{
        dbReplicationLag
      }}</span>
    </div>
    <div class="gl-display-flex gl-flex-direction-column gl-mb-5">
      <span>{{ $options.i18n.lastEventId }}</span>
      <span class="gl-font-weight-bold gl-mt-2" data-testid="last-event"
        >{{ node.lastEventId || 0 }} ({{ timeFormatted(node.lastEventTimestamp * 1000) }})</span
      >
    </div>
    <div class="gl-display-flex gl-flex-direction-column gl-mb-5">
      <span>{{ $options.i18n.lastCursorEventId }}</span>
      <span class="gl-font-weight-bold gl-mt-2" data-testid="last-cursor-event"
        >{{ node.cursorLastEventId || 0 }} ({{
          timeFormatted(node.cursorLastEventTimestamp * 1000)
        }})</span
      >
    </div>
    <div class="gl-display-flex gl-flex-direction-column gl-mb-5">
      <span>{{ $options.i18n.storageConfig }}</span>
      <span
        :class="{ 'gl-text-red-500': !node.storageShardsMatch }"
        class="gl-font-weight-bold gl-mt-2"
        data-testid="storage-shards"
        >{{ storageShardsStatus }}</span
      >
    </div>
  </gl-card>
</template>
