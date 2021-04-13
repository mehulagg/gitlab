<script>
import { GlIcon, GlPopover, GlLink, GlSprintf } from '@gitlab/ui';
import { s__ } from '~/locale';

import { VALUE_TYPE, CUSTOM_TYPE, REPLICATION_HELP_URL } from '../constants';

import GeoNodeEventStatus from './geo_node_event_status.vue';
import GeoNodeSyncProgress from './geo_node_sync_progress.vue';
import GeoNodeSyncSettings from './geo_node_sync_settings.vue';

export default {
  components: {
    GeoNodeSyncSettings,
    GeoNodeEventStatus,
    GeoNodeSyncProgress,
    GlIcon,
    GlPopover,
    GlLink,
    GlSprintf,
  },
  props: {
    itemTitle: {
      type: String,
      required: true,
    },
    cssClass: {
      type: String,
      required: false,
      default: '',
    },
    itemEnabled: {
      type: Boolean,
      required: false,
      default: true,
    },
    itemValue: {
      type: [Object, String, Number],
      required: true,
    },
    itemValueType: {
      type: String,
      required: false,
      default: VALUE_TYPE.GRAPH,
    },
    customType: {
      type: String,
      required: false,
      default: '',
    },
    eventTypeLogStatus: {
      type: Boolean,
      required: false,
      default: false,
    },
    detailsPath: {
      type: String,
      required: false,
      default: '',
    },
  },
  computed: {
    hasHelpInfo() {
      return typeof this.helpInfo === 'object';
    },
    isValueTypePlain() {
      return this.itemValueType === VALUE_TYPE.PLAIN;
    },
    isValueTypeGraph() {
      return this.itemValueType === VALUE_TYPE.GRAPH;
    },
    isValueTypeCustom() {
      return this.itemValueType === VALUE_TYPE.CUSTOM;
    },
    isCustomTypeSync() {
      return this.customType === CUSTOM_TYPE.SYNC;
    },
  },
  replicationHelpUrl: REPLICATION_HELP_URL,
  disabledText: s__('Geo|Synchronization of %{itemTitle} is disabled.'),
};
</script>

<template>
  <div class="mt-2 ml-2 node-detail-item">
    <div class="d-flex align-items-center text-secondary-700">
      <span class="node-detail-title">{{ itemTitle }}</span>
    </div>
    <div v-if="itemEnabled">
      <div v-if="isValueTypePlain" :class="cssClass" class="mt-1 node-detail-value">
        {{ itemValue }}
      </div>
      <geo-node-sync-progress
        v-if="isValueTypeGraph"
        :item-enabled="itemEnabled"
        :item-title="itemTitle"
        :item-value="itemValue"
        :details-path="detailsPath"
        class="mt-1"
      />
      <template v-if="isValueTypeCustom">
        <geo-node-sync-settings v-if="isCustomTypeSync" v-bind="itemValue" />
        <geo-node-event-status
          v-else
          :event-id="itemValue.eventId"
          :event-time-stamp="itemValue.eventTimeStamp"
          :event-type-log-status="eventTypeLogStatus"
        />
      </template>
    </div>
    <div v-else class="mt-1">
      <div
        :id="`syncDisabled-${itemTitle}`"
        class="d-inline-flex align-items-center cursor-pointer"
      >
        <gl-icon name="canceled-circle" :size="14" class="mr-1 text-secondary-300" />
        <span ref="disabledText" class="text-secondary-600 gl-font-sm">{{
          __('Synchronization disabled')
        }}</span>
      </div>
      <gl-popover :target="`syncDisabled-${itemTitle}`" placement="right" :css-classes="['w-100']">
        <section>
          <gl-sprintf :message="$options.disabledText">
            <template #itemTitle>{{ itemTitle.toLowerCase() }}</template>
          </gl-sprintf>
          <div class="mt-3">
            <gl-link class="gl-font-sm" :href="$options.replicationHelpUrl" target="_blank">{{
              __('Learn how to enable synchronization')
            }}</gl-link>
          </div>
        </section>
      </gl-popover>
    </div>
  </div>
</template>
