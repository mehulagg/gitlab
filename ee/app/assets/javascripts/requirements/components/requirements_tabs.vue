<script>
import { GlLink, GlBadge, GlButton, GlTabs, GlTab } from '@gitlab/ui';

import { FilterState } from '../constants';

export default {
  FilterState,
  components: {
    GlLink,
    GlBadge,
    GlButton,
    GlTabs,
    GlTab,
  },
  props: {
    filterBy: {
      type: String,
      required: true,
    },
    requirementsCount: {
      type: Object,
      required: true,
    },
    showCreateForm: {
      type: Boolean,
      required: true,
    },
    canCreateRequirement: {
      type: Boolean,
      required: false,
    },
  },
  computed: {
    isOpenTab() {
      return this.filterBy === FilterState.opened;
    },
    isArchivedTab() {
      return this.filterBy === FilterState.archived;
    },
    isAllTab() {
      return this.filterBy === FilterState.all;
    },
  },
};
</script>

<template>
  <gl-tabs>
    <gl-tab @click.prevent="changeTab('all')">
      <template slot="title">
        <span>Open</span>
        <gl-badge size="sm" class="gl-tab-counter-badge">{{ requirementsCount.OPENED }}</gl-badge>
      </template>
    </gl-tab>
    <gl-tab @click.prevent="changeTab('selected')">
      <template slot="title">
        <span>Archived</span>
        <gl-badge size="sm" class="gl-tab-counter-badge">{{ requirementsCount.ARCHIVED }}</gl-badge>
      </template>
    </gl-tab>
    <gl-tab @click.prevent="changeTab('selected')">
      <template slot="title">
        <span>All</span>
        <gl-badge size="sm" class="gl-tab-counter-badge">{{ requirementsCount.ALL }}</gl-badge>
      </template>
    </gl-tab>
  </gl-tabs>
  <div v-else-if="isOpenTab && canCreateRequirement" class="nav-controls">
    <gl-button
      category="primary"
      variant="success"
      class="js-new-requirement qa-new-requirement-button"
      :disabled="showCreateForm"
      @click="$emit('clickNewRequirement')"
      >{{ __('New requirement') }}</gl-button
    >
  </div>
</template>
