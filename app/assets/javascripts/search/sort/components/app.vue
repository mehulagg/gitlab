<script>
import { mapState, mapActions } from 'vuex';
import {
  GlButtonGroup,
  GlButton,
  GlDropdown,
  GlDropdownItem,
  GlTooltipDirective,
} from '@gitlab/ui';
import { SORT_OPTIONS, MOST_RELEVANT, SORT_DIRECTION_UI } from '../constants';

export default {
  name: 'GlobalSearchSort',
  components: {
    GlButtonGroup,
    GlButton,
    GlDropdown,
    GlDropdownItem,
  },
  directives: {
    GlTooltip: GlTooltipDirective,
  },
  computed: {
    ...mapState(['query']),
    selectedSortOption: {
      get() {
        if (!this.query || !this.query.sort) {
          return MOST_RELEVANT;
        }

        const sortOption = SORT_OPTIONS.find((option) => {
          if (!option.sortable) {
            return option.sortParam === this.query.sort;
          }

          return (
            option.sortParam.asc === this.query.sort || option.sortParam.desc === this.query.sort
          );
        });

        // Handle invalid sort param
        return sortOption || MOST_RELEVANT;
      },
      set(value) {
        this.setQuery({ key: 'sort', value });
        this.applyQuery();
      },
    },
    sortDirectionData() {
      if (!this.selectedSortOption.sortable) {
        return SORT_DIRECTION_UI.disabled;
      }

      return this.query.sort.includes('desc') ? SORT_DIRECTION_UI.desc : SORT_DIRECTION_UI.asc;
    },
  },
  methods: {
    ...mapActions(['applyQuery', 'setQuery']),
    handleSortChange(option) {
      if (!option.sortable) {
        this.selectedSortOption = option.sortParam;
      } else {
        // Default new sort options to desc
        this.selectedSortOption = option.sortParam.desc;
      }
    },
    handleSortDirectionChange() {
      this.selectedSortOption =
        this.sortDirectionData.direction === 'desc'
          ? this.selectedSortOption.sortParam.asc
          : this.selectedSortOption.sortParam.desc;
    },
  },
  SORT_OPTIONS,
};
</script>

<template>
  <gl-button-group>
    <gl-dropdown :text="selectedSortOption.title" class="w-100">
      <gl-dropdown-item
        v-for="sortOption in $options.SORT_OPTIONS"
        :key="sortOption.id"
        :is-check-item="true"
        :is-checked="sortOption.id === selectedSortOption.id"
        @click="handleSortChange(sortOption)"
        >{{ sortOption.title }}</gl-dropdown-item
      >
    </gl-dropdown>
    <gl-button
      v-gl-tooltip
      :disabled="!selectedSortOption.sortable"
      :title="sortDirectionData.tooltip"
      :icon="sortDirectionData.icon"
      @click="handleSortDirectionChange"
    />
  </gl-button-group>
</template>
