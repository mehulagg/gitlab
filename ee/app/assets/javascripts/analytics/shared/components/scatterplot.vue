<script>
import dateFormat from 'dateformat';
import { GlDiscreteScatterChart } from '@gitlab/ui/dist/charts';
import { scatterChartLineProps, dateFormats } from '../constants';

export default {
  components: {
    GlDiscreteScatterChart,
  },
  props: {
    xAxisTitle: {
      type: String,
      required: true,
    },
    yAxisTitle: {
      type: String,
      required: true,
    },
    scatterData: {
      type: Array,
      required: true,
    },
    medianLineData: {
      type: Array,
      required: false,
      default: () => [],
    },
    tooltipDateFormat: {
      type: String,
      required: false,
      default: dateFormats.defaultDateTime,
    },
  },
  data() {
    return {
      tooltipTitle: '',
      tooltipContent: '',
      chartOption: {
        xAxis: {
          type: 'time',
          axisLabel: {
            formatter: date => dateFormat(date, dateFormats.defaultDate),
          },
        },
        dataZoom: [
          {
            type: 'slider',
            bottom: 10,
            start: 0,
          },
        ],
      },
    };
  },
  computed: {
    chartData() {
      const result = [
        {
          type: 'scatter',
          data: this.scatterData,
        },
      ];

      if (this.medianLineData.length) {
        result.push({
          data: this.medianLineData,
          ...scatterChartLineProps.default,
        });
      }

      return result;
    },
  },
  methods: {
    renderTooltip({ data }) {
      const [, metric, dateTime] = data;
      this.tooltipTitle = dateFormat(dateTime, this.tooltipDateFormat);
      this.tooltipContent = metric;
    },
  },
};
</script>

<template>
  <gl-discrete-scatter-chart
    :data="chartData"
    :option="chartOption"
    :y-axis-title="yAxisTitle"
    :x-axis-title="xAxisTitle"
    :format-tooltip-text="renderTooltip"
  >
    <div slot="tooltipTitle">{{ tooltipTitle }} ({{ xAxisTitle }})</div>
    <div slot="tooltipContent" class="d-flex">
      <div class="flex-grow-1">{{ yAxisTitle }}:&nbsp;</div>
      <div class="font-weight-bold">{{ tooltipContent }}</div>
    </div>
  </gl-discrete-scatter-chart>
</template>
