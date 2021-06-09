<script>
import { GlLoadingIcon, GlTooltipDirective, GlButton, GlSprintf } from '@gitlab/ui';
import { TABLE_HEADER_TEXT, ADD_REMOVE_BUTTON_TOOLTIP } from '../constants';
import DevopsAdoptionEmptyState from './devops_adoption_empty_state.vue';
import DevopsAdoptionTable from './devops_adoption_table.vue';

export default {
  components: {
    DevopsAdoptionTable,
    GlLoadingIcon,
    GlButton,
    GlSprintf,
    DevopsAdoptionEmptyState,
  },
  i18n: {
    tableHeaderText: TABLE_HEADER_TEXT,
  },
  directives: {
    GlTooltip: GlTooltipDirective,
  },
  props: {
    isLoading: {
      type: Boolean,
      required: true,
    },
    hasSegmentsData: {
      type: Boolean,
      required: true,
    },
    timestamp: {
      type: String,
      required: true,
    },
    hasGroupData: {
      type: Boolean,
      required: true,
    },
    segmentLimitReached: {
      type: Boolean,
      required: true,
    },
    editGroupsButtonLabel: {
      type: String,
      required: true,
    },
    cols: {
      type: Array,
      required: true,
    },
    segments: {
      type: Object,
      required: false,
      default: () => {},
    },
  },
  computed: {
    addSegmentButtonTooltipText() {
      return this.segmentLimitReached ? ADD_REMOVE_BUTTON_TOOLTIP : false;
    },
  },
};
</script>
<template>
  <gl-loading-icon v-if="isLoading" size="md" class="gl-my-5" />
  <div v-else-if="hasSegmentsData" class="gl-mt-3">
    <div
      class="gl-display-flex gl-justify-content-space-between gl-align-items-center gl-my-3"
      data-testid="tableHeader"
    >
      <span class="gl-text-gray-400">
        <gl-sprintf :message="$options.i18n.tableHeaderText">
          <template #timestamp>{{ timestamp }}</template>
        </gl-sprintf>
      </span>
      <span
        v-if="hasGroupData"
        v-gl-tooltip.hover="addSegmentButtonTooltipText"
        data-testid="segmentButtonWrapper"
      >
        <gl-button :disabled="segmentLimitReached" @click="$emit('openAddRemoveModal')">{{
          editGroupsButtonLabel
        }}</gl-button></span
      >
    </div>
    <devops-adoption-table
      :cols="cols"
      :segments="segments.nodes"
      @segmentsRemoved="$emit('segmentsRemoved', $event)"
      @trackModalOpenState="$emit('trackModalOpenState', $event)"
    />
  </div>
  <devops-adoption-empty-state v-else :has-groups-data="hasGroupData" />
</template>
