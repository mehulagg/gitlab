<script>
import {
  GlDropdown,
  GlDropdownItem,
  GlSearchBoxByType,
  GlLoadingIcon,
  GlIcon,
  GlSkeletonLoader,
  GlTooltipDirective,
} from '@gitlab/ui';

import { ANY } from '../constants';

export default {
  name: 'SearchableDropdown',
  components: {
    GlDropdown,
    GlDropdownItem,
    GlSearchBoxByType,
    GlLoadingIcon,
    GlIcon,
    GlSkeletonLoader,
  },
  directives: {
    GlTooltip: GlTooltipDirective,
  },
  props: {
    displayData: {
      type: Object,
      required: true,
    },
    isLoading: {
      type: Boolean,
      required: false,
      default: false,
    },
    selectedData: {
      type: Object,
      required: true,
    },
    results: {
      type: Array,
      required: false,
      default: () => [],
    },
  },
  data() {
    return {
      search: '',
    };
  },
  methods: {
    isSelected(selected) {
      return selected.id === this.selectedData.id;
    },
  },
  ANY,
};
</script>

<template>
  <gl-dropdown
    class="gl-w-full"
    menu-class="gl-w-full!"
    toggle-class="gl-text-truncate gl-reset-line-height!"
    :header-text="displayData.headerText"
    @show="$emit('fetch', search)"
  >
    <template #button-content>
      <span class="dropdown-toggle-text gl-flex-grow-1 gl-text-truncate">
        {{ selectedData[displayData.selectedDisplayValue] }}
      </span>
      <gl-loading-icon v-if="isLoading" inline class="mr-2" />
      <gl-icon
        v-if="!isSelected($options.ANY)"
        v-gl-tooltip
        name="clear"
        :title="__('Clear')"
        class="gl-text-gray-200! gl-hover-text-blue-800!"
        @click.stop="$emit('update', $options.ANY)"
      />
      <gl-icon name="chevron-down" />
    </template>
    <div class="gl-sticky gl-top-0 gl-z-index-1 gl-bg-white">
      <gl-search-box-by-type
        v-model="search"
        class="m-2"
        :debounce="500"
        @input="$emit('fetch', search)"
      />
      <gl-dropdown-item
        class="gl-border-b-solid gl-border-b-gray-100 gl-border-b-1 gl-pb-2! gl-mb-2"
        :is-check-item="true"
        :is-checked="isSelected($options.ANY)"
        @click="$emit('update', $options.ANY)"
      >
        {{ $options.ANY.name }}
      </gl-dropdown-item>
    </div>
    <div v-if="!isLoading">
      <gl-dropdown-item
        v-for="result in results"
        :key="result.id"
        :is-check-item="true"
        :is-checked="isSelected(result)"
        @click="$emit('update', result)"
      >
        {{ result[displayData.resultsDisplayValue] }}
      </gl-dropdown-item>
    </div>
    <div v-if="isLoading" class="mx-3 mt-2">
      <gl-skeleton-loader :height="100">
        <rect y="0" width="90%" height="20" rx="4" />
        <rect y="40" width="70%" height="20" rx="4" />
        <rect y="80" width="80%" height="20" rx="4" />
      </gl-skeleton-loader>
    </div>
  </gl-dropdown>
</template>
