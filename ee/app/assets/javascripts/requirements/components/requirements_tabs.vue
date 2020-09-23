<script>
import { GlLink, GlDeprecatedBadge as GlBadge, GlButton } from '@gitlab/ui';

import { FilterState } from '../constants';

export default {
  FilterState,
  components: {
    GlLink,
    GlBadge,
    GlButton,
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
  <div class="top-area">
    <ul class="nav-links mobile-separator requirements-state-filters js-requirements-state-filters">
      <li :class="{ active: isOpenTab }">
        <gl-link
          id="state-opened"
          data-state="opened"
          :title="__('Filter by requirements that are currently opened.')"
          @click="$emit('clickTab', { filterBy: $options.FilterState.opened })"
        >
          {{ __('Open') }}
          <gl-badge class="badge-pill">{{ requirementsCount.OPENED }}</gl-badge>
        </gl-link>
      </li>
      <li :class="{ active: isArchivedTab }">
        <gl-link
          id="state-archived"
          data-state="archived"
          :title="__('Filter by requirements that are currently archived.')"
          @click="$emit('clickTab', { filterBy: $options.FilterState.archived })"
        >
          {{ __('Archived') }}
          <gl-badge class="badge-pill">{{ requirementsCount.ARCHIVED }}</gl-badge>
        </gl-link>
      </li>
      <li :class="{ active: isAllTab }">
        <gl-link
          id="state-all"
          data-state="all"
          :title="__('Show all requirements.')"
          @click="$emit('clickTab', { filterBy: $options.FilterState.all })"
        >
          {{ __('All') }}
          <gl-badge class="badge-pill">{{ requirementsCount.ALL }}</gl-badge>
        </gl-link>
      </li>
    </ul>
    <div v-if="isOpenTab && canCreateRequirement" class="nav-controls">
      <gl-button
        category="primary"
        variant="success"
        class="js-new-requirement qa-new-requirement-button"
        :disabled="showCreateForm"
        @click="$emit('clickNewRequirement')"
        >{{ __('New requirement') }}</gl-button
      >
    </div>
  </div>
</template>
