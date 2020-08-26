<script>
import { merge } from 'lodash';
import { GlLineChart } from '@gitlab/ui/dist/charts';
import dateFormat from 'dateformat';
import ResizableChartContainer from '~/vue_shared/components/resizable_chart/resizable_chart_container.vue';
import { __, sprintf } from '~/locale';
import commonChartOptions from './common_chart_options';

export default {
  components: {
    GlLineChart,
    ResizableChartContainer,
  },
  props: {
    startDate: {
      type: String,
      required: true,
    },
    dueDate: {
      type: String,
      required: true,
    },
    scope: {
      type: Array,
      required: false,
      default: () => [],
    },
  },
  data() {
    return {
      tooltip: {
        title: '',
        content: '',
      },
    };
  },
  computed: {
    dataSeries() {
      const series = [
        {
          name: __('Total'),
          data: this.scope,
        },
      ];

      return series;
    },
    options() {
      return merge({}, commonChartOptions, {
        xAxis: {
          min: this.startDate,
          max: this.dueDate,
        },
        yAxis: {
          name: __('Total issues'),
        },
      });
    },
  },
  methods: {
    formatTooltipText(params) {
      const [seriesData] = params.seriesData;
      this.tooltip.title = dateFormat(params.value, 'dd mmm yyyy');

      const text = __('%{total} open issues');

      this.tooltip.content = sprintf(text, {
        total: seriesData.value[1],
      });
    },
  },

  emits: [],
};
</script>

<template>
  <div data-qa-selector="burnup_chart">
    <div class="burndown-header d-flex align-items-center">
      <h3>{{ __('Burnup chart') }}</h3>
    </div>
    <resizable-chart-container class="js-burnup-chart">
      <gl-line-chart
        :data="dataSeries"
        :option="options"
        :format-tooltip-text="formatTooltipText"
        :include-legend-avg-max="false"
      >
        <template slot="tooltipTitle">{{ tooltip.title }}</template>
        <template slot="tooltipContent">{{ tooltip.content }}</template>
      </gl-line-chart>
    </resizable-chart-container>
  </div>
</template>
