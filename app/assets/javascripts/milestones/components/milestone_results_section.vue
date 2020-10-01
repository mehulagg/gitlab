<script>
import {
  GlDropdownSectionHeader,
  GlDropdownDivider,
  GlDropdownItem,
  GlBadge,
  GlIcon,
} from '@gitlab/ui';
import { s__ } from '~/locale';

export default {
  name: 'MilestoneResultsSection',
  components: {
    GlDropdownSectionHeader,
    GlDropdownDivider,
    GlDropdownItem,
    GlBadge,
    GlIcon,
  },
  props: {
    sectionTitle: {
      type: String,
      required: true,
    },
    totalCount: {
      type: Number,
      required: true,
    },
    items: {
      type: Array,
      required: true,
    },
    selectedMilestones: {
      type: Array,
      required: false,
      default: () => [],
    },
  },
  computed: {
    totalCountText() {
      return this.totalCount > 999 ? s__('TotalMilestonesIndicator|1000+') : `${this.totalCount}`;
    },
  },
  methods: {
    isSelectedMilestone(item) {
      console.log(this.selectedMilestones, item);
      return this.selectedMilestones.includes(item);
    },
  },
};
</script>

<template>
  <div>
    <gl-dropdown-section-header>
      <div class="gl-display-flex align-items-center pl-4" data-testid="section-header">
        <span class="gl-mr-2 gl-mb-1">{{ sectionTitle }}</span>
        <gl-badge variant="neutral">{{ totalCountText }}</gl-badge>
      </div>
    </gl-dropdown-section-header>
    <gl-dropdown-item
      v-for="item in items"
      :key="item"
      role="milestone option"
      @click="$emit('selected', item)"
    >
      <span class="pl-4" :class="{ 'selected-item': isSelectedMilestone(item) }">
        {{ item }}
      </span>
    </gl-dropdown-item>
    <gl-dropdown-divider />
  </div>
</template>
