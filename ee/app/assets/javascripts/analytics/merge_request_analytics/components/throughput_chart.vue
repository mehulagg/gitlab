<script>
import { GlAreaChart } from '@gitlab/ui/dist/charts';
import { GlAlert } from '@gitlab/ui';
import ChartSkeletonLoader from '~/vue_shared/components/resizable_chart/skeleton_loader.vue';
import throughputChartQueryBuilder from '../graphql/throughput_chart_query_builder';
import { THROUGHPUT_CHART_STRINGS } from '../constants';

export default {
  name: 'ThroughputChart',
  components: {
    GlAreaChart,
    GlAlert,
    ChartSkeletonLoader,
  },
  inject: ['fullPath'],
  props: {
    startDate: {
      type: Date,
      required: true,
    },
    endDate: {
      type: Date,
      required: true,
    },
  },
  data() {
    return {
      throughputChartData: [],
      hasError: false,
    };
  },
  apollo: {
    throughputChartData: {
      query() {
        return throughputChartQueryBuilder(this.startDate, this.endDate);
      },
      variables() {
        return {
          fullPath: this.fullPath,
        };
      },
      error() {
        this.hasError = true;
      },
      context: {
        isSingleRequest: true,
      },
    },
  },
  computed: {
    chartOptions() {
      return {
        xAxis: {
          name: THROUGHPUT_CHART_STRINGS.X_AXIS_TITLE,
          type: 'category',
          axisLabel: {
            formatter: value => {
              return value.split('_')[0]; // Aug_2020 => Aug
            },
          },
        },
        yAxis: {
          name: THROUGHPUT_CHART_STRINGS.Y_AXIS_TITLE,
        },
      };
    },
    formattedThroughputChartData() {
      if (!this.throughputChartData) return [];

      const data = Object.keys(this.throughputChartData)
        .slice(0, -1) // Remove the __typeName key
        .map(value => [value, this.throughputChartData[value].count]);

      return [
        {
          name: THROUGHPUT_CHART_STRINGS.Y_AXIS_TITLE,
          data,
        },
      ];
    },
    chartDataLoading() {
      return !this.hasError && this.$apollo.queries.throughputChartData.loading;
    },
    chartDataAvailable() {
      return this.formattedThroughputChartData[0]?.data.length;
    },
    alertDetails() {
      return {
        class: this.hasError ? 'danger' : 'info',
        message: this.hasError
          ? THROUGHPUT_CHART_STRINGS.ERROR_FETCHING_DATA
          : THROUGHPUT_CHART_STRINGS.NO_DATA,
      };
    },
  },
  strings: {
    chartTitle: THROUGHPUT_CHART_STRINGS.CHART_TITLE,
    chartDescription: THROUGHPUT_CHART_STRINGS.CHART_DESCRIPTION,
  },

  emits: [],
};
</script>
<template>
  <div>
    <h4 data-testid="chartTitle">{{ $options.strings.chartTitle }}</h4>
    <div class="gl-text-gray-500" data-testid="chartDescription">
      {{ $options.strings.chartDescription }}
    </div>
    <chart-skeleton-loader v-if="chartDataLoading" />
    <gl-area-chart
      v-else-if="chartDataAvailable"
      :data="formattedThroughputChartData"
      :option="chartOptions"
    />
    <gl-alert v-else :variant="alertDetails.class" :dismissible="false" class="gl-mt-4">{{
      alertDetails.message
    }}</gl-alert>
  </div>
</template>
