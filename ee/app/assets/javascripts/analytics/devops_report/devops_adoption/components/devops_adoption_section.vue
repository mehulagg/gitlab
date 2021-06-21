<script>
import { GlLoadingIcon } from '@gitlab/ui';
import DevopsAdoptionAddDropdown from './devops_adoption_add_dropdown.vue';
import DevopsAdoptionEmptyState from './devops_adoption_empty_state.vue';
import DevopsAdoptionTable from './devops_adoption_table.vue';

export default {
  components: {
    DevopsAdoptionTable,
    GlLoadingIcon,
    DevopsAdoptionEmptyState,
    DevopsAdoptionAddDropdown,
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
    hasGroupData: {
      type: Boolean,
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
    disabledGroupNodes: {
      type: Array,
      required: true,
    },
    searchTerm: {
      type: String,
      required: true,
    },
    isLoadingGroups: {
      type: Boolean,
      required: true,
    },
    hasSubgroups: {
      type: Boolean,
      required: false,
      default: false,
    },
  },
};
</script>
<template>
  <gl-loading-icon v-if="isLoading" size="md" class="gl-my-5" />
  <div v-else-if="hasSegmentsData">
    <devops-adoption-add-dropdown
      class="gl-mt-4 gl-mb-5 gl-md-display-none"
      :search-term="searchTerm"
      :groups="disabledGroupNodes"
      :is-loading-groups="isLoadingGroups"
      :has-subgroups="hasSubgroups"
      @fetchGroups="$emit('fetchGroups', $event)"
      @segmentsAdded="$emit('segmentsAdded', $event)"
      @trackModalOpenState="$emit('trackModalOpenState', $event)"
    />
    <devops-adoption-table
      :cols="cols"
      :segments="segments.nodes"
      @segmentsRemoved="$emit('segmentsRemoved', $event)"
      @trackModalOpenState="$emit('trackModalOpenState', $event)"
    />
  </div>
  <devops-adoption-empty-state v-else :has-groups-data="hasGroupData" />
</template>
