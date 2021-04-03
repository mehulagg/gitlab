<script>
import { GlPopover, GlLink, GlIcon, GlSprintf } from '@gitlab/ui';

import { sprintf, s__ } from '~/locale';

import { HELP_INFO_URL } from '../../constants';

import GeoNodeDetailItem from '../geo_node_detail_item.vue';
import SectionRevealButton from './section_reveal_button.vue';

export default {
  components: {
    GlIcon,
    GlPopover,
    GlLink,
    GlSprintf,
    GeoNodeDetailItem,
    SectionRevealButton,
  },
  props: {
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
      return this.nodeTypePrimary
        ? this.nodeDetails.checksumStatuses
        : this.nodeDetails.verificationStatuses;
    },
    nodeText() {
      return this.nodeTypePrimary ? s__('GeoNodes|secondary nodes') : s__('GeoNodes|primary node');
    },
  },
  methods: {
    handleSectionToggle(toggleState) {
      this.showSectionItems = toggleState;
    },
    itemValue(nodeDetailItem) {
      return {
        totalCount: this.nodeTypePrimary
          ? nodeDetailItem.itemValue.checksumTotalCount
          : nodeDetailItem.itemValue.verificationTotalCount,
        successCount: this.nodeTypePrimary
          ? nodeDetailItem.itemValue.checksumSuccessCount
          : nodeDetailItem.itemValue.verificationSuccessCount,
        failureCount: this.nodeTypePrimary
          ? nodeDetailItem.itemValue.checksumFailureCount
          : nodeDetailItem.itemValue.verificationFailureCount,
      };
    },
    itemTitle(nodeDetailItem) {
      return this.nodeTypePrimary
        ? sprintf(s__('Geo|%{itemTitle} checksum progress'), {
            itemTitle: nodeDetailItem.itemTitle,
          })
        : sprintf(s__('Geo|%{itemTitle} verification progress'), {
            itemTitle: nodeDetailItem.itemTitle,
          });
    },
  },
  HELP_INFO_URL,
};
</script>

<template>
  <div class="row-fluid clearfix py-3 border-top border-color-default verification-section">
    <div class="col-md-12 d-flex align-items-center">
      <section-reveal-button
        :button-title="__('Verification information')"
        @toggleButton="handleSectionToggle"
      />
      <gl-icon
        ref="verificationInfo"
        tabindex="0"
        name="question"
        class="text-primary-600 ml-1 cursor-pointer"
      />
      <gl-popover :target="() => $refs.verificationInfo.$el" placement="top">
        <p>
          <gl-sprintf
            :message="
              s__('GeoNodes|Replicated data is verified with the %{nodeText} using checksums')
            "
          >
            <template #nodeText>
              {{ nodeText }}
            </template>
          </gl-sprintf>
        </p>
        <gl-link class="mt-3" :href="$options.HELP_INFO_URL" target="_blank">{{
          __('More information')
        }}</gl-link>
      </gl-popover>
    </div>
    <template v-if="showSectionItems">
      <div class="col-md-6 ml-2 mt-2 section-items-container">
        <geo-node-detail-item
          v-for="(nodeDetailItem, index) in nodeDetailItems"
          :key="index"
          :item-title="itemTitle(nodeDetailItem)"
          :item-value="itemValue(nodeDetailItem)"
        />
      </div>
    </template>
  </div>
</template>
