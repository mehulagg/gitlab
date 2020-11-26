<script>
import { GlDropdownDivider, GlSegmentedControl, GlIcon } from '@gitlab/ui';
import { s__, sprintf } from '~/locale';
import { deprecatedCreateFlash as createFlash } from '~/flash';
import { removeFlash } from '../../utils';
import {
  TASKS_BY_TYPE_FILTERS,
  TASKS_BY_TYPE_SUBJECT_ISSUE,
  TASKS_BY_TYPE_SUBJECT_FILTER_OPTIONS,
  TASKS_BY_TYPE_MAX_LABELS,
} from '../../constants';
import LabelsSelector from '../labels_selector.vue';

export default {
  name: 'TasksByTypeFilters',
  components: {
    GlSegmentedControl,
    GlDropdownDivider,
    GlIcon,
    LabelsSelector,
  },
  props: {
    selectedLabelIds: {
      type: Array,
      required: true,
    },
    maxLabels: {
      type: Number,
      required: false,
      default: TASKS_BY_TYPE_MAX_LABELS,
    },
    subjectFilter: {
      type: String,
      required: true,
    },
    hasData: {
      type: Boolean,
      required: true,
    },
  },
  computed: {
    subjectFilterOptions() {
      return Object.entries(TASKS_BY_TYPE_SUBJECT_FILTER_OPTIONS).map(([value, text]) => ({
        text,
        value,
      }));
    },
    selectedFiltersText() {
      const { subjectFilter, selectedLabelIds } = this;
      const subjectFilterText = TASKS_BY_TYPE_SUBJECT_FILTER_OPTIONS[subjectFilter]
        ? TASKS_BY_TYPE_SUBJECT_FILTER_OPTIONS[subjectFilter]
        : TASKS_BY_TYPE_SUBJECT_FILTER_OPTIONS[TASKS_BY_TYPE_SUBJECT_ISSUE];
      return sprintf(
        s__('CycleAnalytics|Showing %{subjectFilterText} and %{selectedLabelsCount} labels'),
        {
          subjectFilterText,
          selectedLabelsCount: selectedLabelIds.length,
        },
      );
    },
    selectedLabelLimitText() {
      const { selectedLabelIds, maxLabels } = this;
      return sprintf(s__('CycleAnalytics|%{selectedLabelsCount} selected (%{maxLabels} max)'), {
        selectedLabelsCount: selectedLabelIds.length,
        maxLabels,
      });
    },
    maxLabelsSelected() {
      return this.selectedLabelIds.length >= this.maxLabels;
    },
  },
  methods: {
    canUpdateLabelFilters(value) {
      // we can always remove a filter
      return this.selectedLabelIds.includes(value) || !this.maxLabelsSelected;
    },
    handleLabelSelected(value) {
      removeFlash('notice');
      if (this.canUpdateLabelFilters(value)) {
        this.$emit('updateFilter', { filter: TASKS_BY_TYPE_FILTERS.LABEL, value });
      } else {
        const { maxLabels } = this;
        const message = sprintf(
          s__('CycleAnalytics|Only %{maxLabels} labels can be selected at this time'),
          { maxLabels },
        );
        createFlash(message, 'notice');
      }
    },
  },
  TASKS_BY_TYPE_FILTERS,
};
</script>
<template>
  <div
    class="js-tasks-by-type-chart-filters d-flex flex-row justify-content-between align-items-center"
  >
    <div class="flex-column">
      <h4>{{ s__('CycleAnalytics|Tasks by type') }}</h4>
      <p v-if="hasData">{{ selectedFiltersText }}</p>
    </div>
    <div class="flex-column">
      <labels-selector
        :default-selected-labels-ids="selectedLabelIds"
        :max-labels="maxLabels"
        :aria-label="__('CycleAnalytics|Display chart filters')"
        :selected-label-id="selectedLabelIds"
        aria-expanded="false"
        multiselect
        right
        @selectLabel="handleLabelSelected"
      >
        <template #label-dropdown-button>
          <gl-icon class="vertical-align-top" name="settings" />
          <gl-icon name="chevron-down" />
        </template>
        <template #label-dropdown-list-header>
          <div class="mb-3 px-3">
            <p class="font-weight-bold text-left mb-2">{{ s__('CycleAnalytics|Show') }}</p>
            <gl-segmented-control
              :checked="subjectFilter"
              :options="subjectFilterOptions"
              @input="
                value =>
                  $emit('updateFilter', { filter: $options.TASKS_BY_TYPE_FILTERS.SUBJECT, value })
              "
            />
          </div>
          <gl-dropdown-divider />
          <div class="mb-3 px-3">
            <p class="font-weight-bold text-left my-2">
              {{ s__('CycleAnalytics|Select labels') }}
              <br /><small>{{ selectedLabelLimitText }}</small>
            </p>
          </div>
        </template>
      </labels-selector>
    </div>
  </div>
</template>
