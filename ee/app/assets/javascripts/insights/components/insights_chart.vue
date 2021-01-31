<script>
import { GlColumnChart, GlLineChart, GlStackedColumnChart } from '@gitlab/ui/dist/charts';

import { getSvgIconPathContent } from '~/lib/utils/icon_utils';
import ResizableChartContainer from '~/vue_shared/components/resizable_chart/resizable_chart_container.vue';
import ChartSkeletonLoader from '~/vue_shared/components/resizable_chart/skeleton_loader.vue';

import { CHART_TYPES } from '../constants';
import InsightsChartError from './insights_chart_error.vue';

const CHART_HEIGHT = 300;

export default {
  components: {
    GlColumnChart,
    GlLineChart,
    GlStackedColumnChart,
    InsightsChartError,
    ResizableChartContainer,
    ChartSkeletonLoader,
  },
  props: {
    loaded: {
      type: Boolean,
      required: false,
      default: false,
    },
    type: {
      type: String,
      required: false,
      default: null,
    },
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
    data: {
      type: Object,
      required: false,
      default: null,
    },
    error: {
      type: String,
      required: false,
      default: '',
    },
  },
  data() {
    return {
      svgs: {},
    };
  },
  computed: {
    dataZoomConfig() {
      const handleIcon = this.svgs['scroll-handle'];

      return handleIcon ? { handleIcon } : {};
    },
    chartOptions() {
      let options = {
        yAxis: {
          minInterval: 1,
        },
      };

      if (this.type === this.$options.chartTypes.LINE) {
        options = {
          ...options,
          xAxis: {
            ...options.xAxis,
            name: this.data.xAxisTitle,
            type: 'category',
          },
          yAxis: {
            ...options.yAxis,
            name: this.data.yAxisTitle,
            type: 'value',
          },
        };
      }

      return { dataZoom: [this.dataZoomConfig], ...options };
    },
    isColumnChart() {
      return [this.$options.chartTypes.BAR, this.$options.chartTypes.PIE].includes(this.type);
    },
    isStackedColumnChart() {
      return this.type === this.$options.chartTypes.STACKED_BAR;
    },
    isLineChart() {
      return this.type === this.$options.chartTypes.LINE;
    },
  },
  methods: {
    setSvg(name) {
      return getSvgIconPathContent(name)
        .then((path) => {
          if (path) {
            this.$set(this.svgs, name, `path://${path}`);
          }
        })
        .catch((e) => {
          // eslint-disable-next-line no-console, @gitlab/require-i18n-strings
          console.error('SVG could not be rendered correctly: ', e);
        });
    },
    onChartCreated() {
      this.setSvg('scroll-handle');
    },
  },
  height: CHART_HEIGHT,
  chartTypes: CHART_TYPES,
};
</script>
<template>
  <div v-if="error" class="insights-chart">
    <insights-chart-error
      :chart-name="title"
      :title="__('This chart could not be displayed')"
      :summary="__('Please check the configuration file for this chart')"
      :error="error"
    />
  </div>
  <resizable-chart-container v-else class="insights-chart">
    <h5 class="text-center">{{ title }}</h5>
    <p v-if="description" class="text-center">{{ description }}</p>
    <gl-column-chart
      v-if="loaded && isColumnChart"
      v-bind="$attrs"
      :height="$options.height"
      :bars="data.datasets"
      x-axis-type="category"
      :x-axis-title="data.xAxisTitle"
      :y-axis-title="data.yAxisTitle"
      :option="chartOptions"
      @created="onChartCreated"
    />
    <gl-stacked-column-chart
      v-else-if="loaded && isStackedColumnChart"
      v-bind="$attrs"
      :height="$options.height"
      :bars="data.datasets"
      :group-by="data.labels"
      x-axis-type="category"
      :x-axis-title="data.xAxisTitle"
      :y-axis-title="data.yAxisTitle"
      :option="chartOptions"
      @created="onChartCreated"
    />
    <gl-line-chart
      v-else-if="loaded && isLineChart"
      v-bind="$attrs"
      :height="$options.height"
      :data="data.datasets"
      :option="chartOptions"
      @created="onChartCreated"
    />
    <chart-skeleton-loader v-else />
  </resizable-chart-container>
</template>
