<script>
import { s__, __ } from '~/locale';
import { parseSeconds, stringifyTime } from '~/lib/utils/datetime_utility';

import { VALUE_TYPE, CUSTOM_TYPE } from '../../constants';

import GeoNodeDetailItem from '../geo_node_detail_item.vue';
import SectionRevealButton from './section_reveal_button.vue';

export default {
  components: {
    SectionRevealButton,
    GeoNodeDetailItem,
  },
  props: {
    node: {
      type: Object,
      required: true,
    },
    nodeDetails: {
      type: Object,
      required: true,
    },
  },
  data() {
    return {
      showSectionItems: false,
      nodeDetailItems: [
        {
          itemTitle: s__('GeoNodes|Sync settings'),
          itemValue: this.syncSettings(),
          itemValueType: VALUE_TYPE.CUSTOM,
          customType: CUSTOM_TYPE.SYNC,
        },
        ...this.nodeDetails.syncStatuses,
        {
          itemTitle: s__('GeoNodes|Data replication lag'),
          itemValue: this.dbReplicationLag(),
          itemValueType: VALUE_TYPE.PLAIN,
        },
        {
          itemTitle: s__('GeoNodes|Last event ID seen from primary'),
          itemValue: this.lastEventStatus(),
          itemValueType: VALUE_TYPE.CUSTOM,
          customType: CUSTOM_TYPE.EVENT,
        },
        {
          itemTitle: s__('GeoNodes|Last event ID processed by cursor'),
          itemValue: this.cursorLastEventStatus(),
          itemValueType: VALUE_TYPE.CUSTOM,
          customType: CUSTOM_TYPE.EVENT,
          eventTypeLogStatus: true,
        },
      ],
    };
  },
  methods: {
    syncSettings() {
      return {
        syncStatusUnavailable: this.nodeDetails.syncStatusUnavailable,
        selectiveSyncType: this.nodeDetails.selectiveSyncType,
        lastEvent: this.nodeDetails.lastEvent,
        cursorLastEvent: this.nodeDetails.cursorLastEvent,
      };
    },
    dbReplicationLag() {
      // Replication lag can be nil if the secondary isn't actually streaming
      if (this.nodeDetails.dbReplicationLag !== null && this.nodeDetails.dbReplicationLag >= 0) {
        const parsedTime = parseSeconds(this.nodeDetails.dbReplicationLag, {
          hoursPerDay: 24,
          daysPerWeek: 7,
        });

        return stringifyTime(parsedTime);
      }

      return __('Unknown');
    },
    lastEventStatus() {
      return {
        eventId: this.nodeDetails.lastEvent.id,
        eventTimeStamp: this.nodeDetails.lastEvent.timeStamp,
      };
    },
    cursorLastEventStatus() {
      return {
        eventId: this.nodeDetails.cursorLastEvent.id,
        eventTimeStamp: this.nodeDetails.cursorLastEvent.timeStamp,
      };
    },
    handleSectionToggle(toggleState) {
      this.showSectionItems = toggleState;
    },
    detailsPath(nodeDetailItem) {
      if (!nodeDetailItem.secondaryView) {
        return '';
      }

      // This is due to some legacy coding patterns on the GeoNodeStatus API.
      // This will be fixed as part of https://gitlab.com/gitlab-org/gitlab/-/issues/228718

      if (nodeDetailItem.itemName === 'repositories') {
        return `${this.node.url}admin/geo/replication/projects`;
      } else if (nodeDetailItem.itemName === 'attachments') {
        return `${this.node.url}admin/geo/replication/uploads`;
      }

      return `${this.node.url}admin/geo/replication/${nodeDetailItem.itemName}`;
    },
  },
};
</script>

<template>
  <div class="row-fluid clearfix py-3 border-top border-color-default sync-section">
    <div class="col-md-12">
      <section-reveal-button
        :button-title="__('Sync information')"
        @toggleButton="handleSectionToggle"
      />
    </div>
    <div v-if="showSectionItems" class="col-md-6 ml-2 mt-2 section-items-container">
      <geo-node-detail-item
        v-for="(nodeDetailItem, index) in nodeDetailItems"
        :key="index"
        :css-class="nodeDetailItem.cssClass"
        :item-enabled="nodeDetailItem.itemEnabled"
        :item-title="nodeDetailItem.itemTitle"
        :item-value="nodeDetailItem.itemValue"
        :item-value-type="nodeDetailItem.itemValueType"
        :custom-type="nodeDetailItem.customType"
        :event-type-log-status="nodeDetailItem.eventTypeLogStatus"
        :details-path="detailsPath(nodeDetailItem)"
      />
    </div>
  </div>
</template>
