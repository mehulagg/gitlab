<script>
import { GlCard, GlSprintf } from '@gitlab/ui';
import { parseSeconds, stringifyTime } from '~/lib/utils/datetime_utility';
import { __, s__ } from '~/locale';
import TimeAgo from '~/vue_shared/components/time_ago_tooltip.vue';

export default {
  name: 'GeoNodeSecondaryOtherInfo',
  i18n: {
    otherInfo: __('Other information'),
    dbReplicationLag: s__('Geo|Data replication lag'),
    lastEventId: s__('Geo|Last event ID from primary'),
    lastEvent: s__('Geo|%{eventId} (%{timeAgo})'),
    lastCursorEventId: s__('Geo|Last event ID processed by cursor'),
    storageConfig: s__('Geo|Storage config'),
    shardsNotMatched: s__('Geo|Does not match the primary storage configuration'),
    unknown: __('Unknown'),
    ok: __('OK'),
  },
  components: {
    GlCard,
    GlSprintf,
    TimeAgo,
  },
  props: {
    node: {
      type: Object,
      required: true,
    },
  },
  computed: {
    storageShardsStatus() {
      if (this.node.storageShardsMatch == null) {
        return this.$options.i18n.unknown;
      }

      return this.node.storageShardsMatch
        ? this.$options.i18n.ok
        : this.$options.i18n.shardsNotMatched;
    },
    dbReplicationLag() {
      if (parseInt(this.node.dbReplicationLagSeconds, 10) >= 0) {
        const parsedTime = parseSeconds(this.node.dbReplicationLagSeconds, {
          hoursPerDay: 24,
          daysPerWeek: 7,
        });

        return stringifyTime(parsedTime);
      }

      return this.$options.i18n.unknown;
    },
    lastEventTimestamp() {
      const time = this.node.lastEventTimestamp * 1000;
      return new Date(time).toString();
    },
    lastCursorEventTimestamp() {
      const time = this.node.cursorLastEventTimestamp * 1000;
      return new Date(time).toString();
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
      <span class="gl-font-weight-bold gl-mt-2" data-testid="last-event">
        <gl-sprintf v-if="node.lastEventId" :message="$options.i18n.lastEvent">
          <template #eventId>
            {{ node.lastEventId }}
          </template>
          <template #timeAgo>
            <time-ago :time="lastEventTimestamp" />
          </template>
        </gl-sprintf>
        <span v-else>{{ $options.i18n.unknown }}</span>
      </span>
    </div>
    <div class="gl-display-flex gl-flex-direction-column gl-mb-5">
      <span>{{ $options.i18n.lastCursorEventId }}</span>
      <span class="gl-font-weight-bold gl-mt-2" data-testid="last-cursor-event">
        <gl-sprintf v-if="node.cursorLastEventId" :message="$options.i18n.lastEvent">
          <template #eventId>
            {{ node.cursorLastEventId }}
          </template>
          <template #timeAgo>
            <time-ago :time="lastCursorEventTimestamp" />
          </template>
        </gl-sprintf>
        <span v-else>{{ $options.i18n.unknown }}</span>
      </span>
    </div>
    <div class="gl-display-flex gl-flex-direction-column gl-mb-5">
      <span>{{ $options.i18n.storageConfig }}</span>
      <span class="gl-font-weight-bold gl-mt-2" data-testid="storage-shards">{{
        storageShardsStatus
      }}</span>
    </div>
  </gl-card>
</template>
