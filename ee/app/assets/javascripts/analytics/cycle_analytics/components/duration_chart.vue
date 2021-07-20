<script>
import { GlAlert } from '@gitlab/ui';
import { mapActions, mapState, mapGetters } from 'vuex';
import { dateFormats } from '~/analytics/shared/constants';
import { __ } from '~/locale';
import ChartSkeletonLoader from '~/vue_shared/components/resizable_chart/skeleton_loader.vue';
import Scatterplot from '../../shared/components/scatterplot.vue';
import StageDropdownFilter from './stage_dropdown_filter.vue';

export default {
  name: 'DurationChart',
  components: {
    GlAlert,
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
  <div v-else class="gl-display-flex gl-flex-direction-column" data-testid="vsa-duration-chart">
    <h4 class="gl-mt-0">{{ s__('CycleAnalytics|Days to completion') }}</h4>
    <p>
      {{
        s__(
          'CycleAnalytics|The average time spent in the selected stage for the items that were completed on each date. Data limited to the last 500 items.',
        )
      }}
    </p>
    <stage-dropdown-filter
      v-if="stages.length"
      class="gl-ml-auto"
      :stages="stages"
      @selected="onDurationStageSelect"
    />
    <scatterplot
      v-if="hasData"
      :x-axis-title="s__('CycleAnalytics|Date')"
      :y-axis-title="s__('CycleAnalytics|Average days to completion')"
      :tooltip-date-format="$options.durationChartTooltipDateFormat"
      :scatter-data="durationChartPlottableData"
    />
    <gl-alert v-else variant="info" :dismissible="false" class="gl-mt-3">
      {{ error }}
    </gl-alert>
  </div>
</template>
