<script>
import { mapActions, mapState, mapGetters } from 'vuex';
import { __ } from '~/locale';
import ChartSkeletonLoader from '~/vue_shared/components/resizable_chart/skeleton_loader.vue';
import { dateFormats } from '../../shared/constants';
import Scatterplot from '../../shared/components/scatterplot.vue';
import StageDropdownFilter from './stage_dropdown_filter.vue';

export default {
  name: 'DurationChart',
  components: {
    Scatterplot,
    StageDropdownFilter,
    ChartSkeletonLoader,
  },
  props: {
    stages: {
      type: Array,
      required: true,
    },
  },
  computed: {
    ...mapState('durationChart', ['isLoading', 'errorMessage']),
    ...mapGetters('durationChart', ['durationChartPlottableData']),
    hasData() {
      return Boolean(!this.isLoading && this.durationChartPlottableData.length);
    },
    error() {
      return this.errorMessage
        ? this.errorMessage
        : __('There is no data available. Please change your selection.');
    },
  },
  methods: {
    ...mapActions('durationChart', ['updateSelectedDurationChartStages']),
    onDurationStageSelect(stages) {
      this.updateSelectedDurationChartStages(stages);
    },
  },
  durationChartTooltipDateFormat: dateFormats.defaultDate,
};
</script>

<template>
  <chart-skeleton-loader v-if="isLoading" size="md" class="gl-my-4 gl-py-4" />
  <div v-else class="gl-display-flex gl-flex-direction-column">
    <h4 class="gl-mt-0">{{ s__('CycleAnalytics|Days to completion') }}</h4>
    <stage-dropdown-filter
      v-if="stages.length"
      class="gl-ml-auto"
      :stages="stages"
      @selected="onDurationStageSelect"
    />
    <scatterplot
      v-if="hasData"
      :x-axis-title="s__('CycleAnalytics|Date')"
      :y-axis-title="s__('CycleAnalytics|Total days to completion')"
      :tooltip-date-format="$options.durationChartTooltipDateFormat"
      :scatter-data="durationChartPlottableData"
    />
    <div v-else ref="duration-chart-no-data" class="bs-callout bs-callout-info">
      {{ error }}
    </div>
  </div>
</template>
