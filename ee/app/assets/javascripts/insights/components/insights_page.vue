<script>
import { mapActions, mapState } from 'vuex';

import _ from 'lodash-es';
import { GlLoadingIcon } from '@gitlab/ui';

import InsightsChartError from './insights_chart_error.vue';
import InsightsConfigWarning from './insights_config_warning.vue';

import Bar from './chart_js/bar.vue';
import LineChart from './chart_js/line.vue';
import Pie from './chart_js/pie.vue';
import StackedBar from './chart_js/stacked_bar.vue';

export default {
  components: {
    GlLoadingIcon,
    InsightsChartError,
    InsightsConfigWarning,
    Bar,
    LineChart,
    Pie,
    StackedBar,
  },
  props: {
    queryEndpoint: {
      type: String,
      required: true,
    },
    pageConfig: {
      type: Object,
      required: true,
    },
  },
  computed: {
    ...mapState('insights', ['chartData', 'pageLoading']),
    charts() {
      return this.pageConfig.charts;
    },
    chartKeys() {
      return this.charts.map(chart => chart.title);
    },
    storeKeys() {
      return Object.keys(this.chartData);
    },
    hasChartsConfigured() {
      return !_.isUndefined(this.charts) && this.charts.length > 0;
    },
  },
  watch: {
    pageConfig() {
      this.setPageLoading(true);
      this.fetchCharts();
    },
  },
  mounted() {
    this.fetchCharts();
  },
  methods: {
    ...mapActions('insights', ['fetchChartData', 'initChartData', 'setPageLoading']),
    chartType(type) {
      switch (type) {
        case 'line':
          // Apparently Line clashes with another component
          return 'line-chart';
        default:
          return type;
      }
    },
    fetchCharts() {
      if (this.hasChartsConfigured) {
        this.initChartData(this.chartKeys);

        const insightsRequests = this.charts.map(chart =>
          this.fetchChartData({ endpoint: this.queryEndpoint, chart }),
        );
        Promise.all(insightsRequests)
          .then(() => {
            this.setPageLoading(!this.storePopulated());
          })
          .catch(() => {
            this.setPageLoading(false);
          });
      }
    },
    storePopulated() {
      return this.chartKeys.filter(key => this.storeKeys.includes(key)).length > 0;
    },
  },
};
</script>
<template>
  <div class="insights-page" data-qa-selector="insights_page">
    <div v-if="hasChartsConfigured" class="js-insights-page-container">
      <h4 class="text-center">{{ pageConfig.title }}</h4>
      <div v-if="!pageLoading" class="insights-charts" data-qa-selector="insights_charts">
        <div v-for="(insights, key, index) in chartData" :key="index" class="insights-chart">
          <component
            :is="chartType(insights.type)"
            v-if="insights.loaded"
            :chart-title="key"
            :data="insights.data"
          />
          <insights-chart-error
            v-else
            :chart-name="key"
            :title="__('This chart could not be displayed')"
            :summary="__('Please check the configuration file for this chart')"
            :error="insights.error"
          />
        </div>
      </div>
      <div v-else class="insights-chart-loading text-center">
        <gl-loading-icon :inline="true" size="lg" />
      </div>
    </div>
    <insights-config-warning
      v-else
      :title="__('There are no charts configured for this page')"
      :summary="
        __(
          'Please check the configuration file to ensure that a collection of charts has been declared.',
        )
      "
      image="illustrations/monitoring/getting_started.svg"
    />
  </div>
</template>
