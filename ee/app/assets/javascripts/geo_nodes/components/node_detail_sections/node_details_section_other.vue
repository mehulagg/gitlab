<script>
import { s__, __ } from '~/locale';
import { numberToHumanSize } from '~/lib/utils/number_utils';

import { VALUE_TYPE } from '../../constants';

import GeoNodeDetailItem from '../geo_node_detail_item.vue';
import SectionRevealButton from './section_reveal_button.vue';

export default {
  valueType: VALUE_TYPE,
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
    nodeTypePrimary: {
      type: Boolean,
      required: true,
    },
  },
  data() {
    return {
      showSectionItems: false,
    };
  },
  computed: {
    nodeDetailItems() {
      if (this.nodeTypePrimary) {
        // Return primary node detail items
        const primaryNodeDetailItems = [
          {
            itemTitle: s__('GeoNodes|Replication slots'),
            itemValue: this.nodeDetails.replicationSlots,
            itemValueType: VALUE_TYPE.GRAPH,
            successLabel: s__('GeoNodes|Used slots'),
            neutraLabel: s__('GeoNodes|Unused slots'),
          },
        ];

        if (this.nodeDetails.replicationSlots.totalCount) {
          primaryNodeDetailItems.push({
            itemTitle: s__('GeoNodes|Replication slot WAL'),
            itemValue: numberToHumanSize(this.nodeDetails.replicationSlotWAL),
            itemValueType: VALUE_TYPE.PLAIN,
            cssClass: 'font-weight-bold',
          });
        }

        if (this.node.internalUrl) {
          primaryNodeDetailItems.push({
            itemTitle: s__('GeoNodes|Internal URL'),
            itemValue: this.node.internalUrl,
            itemValueType: VALUE_TYPE.PLAIN,
            cssClass: 'font-weight-bold',
          });
        }

        return primaryNodeDetailItems;
      }

      // Return secondary node detail items
      return [
        {
          itemTitle: s__('GeoNodes|Storage config'),
          itemValue: this.storageShardsStatus,
          itemValueType: VALUE_TYPE.PLAIN,
          cssClass: this.storageShardsCssClass.join(' '),
        },
      ];
    },
    storageShardsStatus() {
      if (this.nodeDetails.storageShardsMatch == null) {
        return __('Unknown');
      }
      return this.nodeDetails.storageShardsMatch
        ? __('OK')
        : s__('GeoNodes|Does not match the primary storage configuration');
    },
    storageShardsCssClass() {
      return ['font-weight-bold', { 'text-danger-500': !this.nodeDetails.storageShardsMatch }];
    },
  },
  methods: {
    handleSectionToggle(toggleState) {
      this.showSectionItems = toggleState;
    },
  },
};
</script>

<template>
  <div class="row-fluid clearfix py-3 border-top border-color-default other-section">
    <div class="col-md-12">
      <section-reveal-button
        :button-title="__('Other information')"
        @toggleButton="handleSectionToggle"
      />
    </div>
    <div v-if="showSectionItems" class="col-md-6 ml-2 mt-2 section-items-container">
      <geo-node-detail-item
        v-for="(nodeDetailItem, index) in nodeDetailItems"
        :key="index"
        :css-class="nodeDetailItem.cssClass"
        :item-title="nodeDetailItem.itemTitle"
        :item-value="nodeDetailItem.itemValue"
        :item-value-type="nodeDetailItem.itemValueType"
      />
    </div>
  </div>
</template>
