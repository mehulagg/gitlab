<script>
import _ from 'lodash-es';
import { s__ } from '~/locale';
import { GlDropdown, GlDropdownItem, GlLoadingIcon } from '@gitlab/ui';
import Icon from '~/vue_shared/components/icon.vue';

export default {
  name: 'MetricChart',
  components: {
    GlDropdown,
    GlDropdownItem,
    GlLoadingIcon,
    Icon,
  },
  props: {
    title: {
      type: String,
      required: false,
      default: '',
    },
    description: {
      type: String,
      required: false,
      default: '',
    },
    isLoading: {
      type: Boolean,
      required: false,
      default: false,
    },
    metricTypes: {
      type: Array,
      required: false,
      default: () => [],
    },
    selectedMetric: {
      type: String,
      required: false,
      default: '',
    },
    chartData: {
      type: [Object, Array],
      required: false,
      default: () => {},
    },
  },
  computed: {
    hasMetricTypes() {
      return this.metricTypes.length;
    },
    metricDropdownLabel() {
      const foundMetric = this.metricTypes.find(m => m.key === this.selectedMetric);
      return foundMetric ? foundMetric.label : s__('MetricChart|Please select a metric');
    },
    hasChartData() {
      return !_.isEmpty(this.chartData);
    },
  },
  methods: {
    isSelectedMetric(key) {
      return this.selectedMetric === key;
    },
  },
};
</script>
<template>
  <div>
    <h5 v-if="title">{{ title }}</h5>
    <gl-loading-icon v-if="isLoading" size="md" class="my-4 py-4" />
    <template v-else>
      <div v-if="!hasChartData" ref="noData" class="bs-callout bs-callout-info">
        {{ __('There is no data available. Please change your selection.') }}
      </div>
      <template v-else>
        <gl-dropdown
          v-if="hasMetricTypes"
          class="mb-4 metric-dropdown"
          toggle-class="dropdown-menu-toggle w-100"
          menu-class="w-100 mw-100"
          :text="metricDropdownLabel"
        >
          <gl-dropdown-item
            v-for="metric in metricTypes"
            :key="metric.key"
            active-class="is-active"
            class="w-100"
            @click="$emit('metricTypeChange', metric.key)"
          >
            <span class="d-flex">
              <icon
                :title="s__('MetricChart|Selected')"
                class="flex-shrink-0 append-right-4"
                :class="{
                  invisible: !isSelectedMetric(metric.key),
                }"
                name="mobile-issue-close"
                :aria-label="s__('MetricChart|Selected')"
              />
              {{ metric.label }}
            </span>
          </gl-dropdown-item>
        </gl-dropdown>
        <p v-if="description" class="text-muted">{{ description }}</p>
        <div ref="chart">
          <slot v-if="hasChartData"></slot>
        </div>
      </template>
    </template>
  </div>
</template>
