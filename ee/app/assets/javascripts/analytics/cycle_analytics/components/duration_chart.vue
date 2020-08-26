<script>
import { mapActions, mapState, mapGetters } from 'vuex';
import { GlLoadingIcon } from '@gitlab/ui';
import { dateFormats } from '../../shared/constants';
import Scatterplot from '../../shared/components/scatterplot.vue';
import StageDropdownFilter from './stage_dropdown_filter.vue';

export default {
  name: 'DurationChart',
  components: {
    GlLoadingIcon,
    Scatterplot,
    StageDropdownFilter,
  },
  props: {
    stages: {
      type: Array,
      required: true,
    },
  },
  computed: {
    ...mapState('durationChart', ['isLoading']),
    ...mapGetters('durationChart', ['durationChartPlottableData', 'durationChartMedianData']),
    hasData() {
      return Boolean(this.durationChartPlottableData.length);
    },
  },
  methods: {
    ...mapActions('durationChart', ['updateSelectedDurationChartStages']),
    onDurationStageSelect(stages) {
      this.updateSelectedDurationChartStages(stages);
    },
  },

  durationChartTooltipDateFormat: dateFormats.defaultDate,
  emits: [],
};
</script>

<template>
  <gl-loading-icon v-if="isLoading" size="md" class="my-4 py-4" />
  <div v-else>
    <div class="d-flex">
      <h4 class="mt-0">{{ s__('CycleAnalytics|Days to completion') }}</h4>
      <stage-dropdown-filter
        v-if="stages.length"
        class="ml-auto"
        :stages="stages"
        @selected="onDurationStageSelect"
      />
    </div>
    <scatterplot
      v-if="hasData"
      :x-axis-title="s__('CycleAnalytics|Date')"
      :y-axis-title="s__('CycleAnalytics|Total days to completion')"
      :tooltip-date-format="$options.durationChartTooltipDateFormat"
      :scatter-data="durationChartPlottableData"
      :median-line-data="durationChartMedianData"
    />
    <div v-else ref="duration-chart-no-data" class="bs-callout bs-callout-info">
      {{ __('There is no data available. Please change your selection.') }}
    </div>
  </div>
</template>
