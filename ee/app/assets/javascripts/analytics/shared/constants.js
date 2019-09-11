export const defaultDateFormat = 'mmm d, yyyy';
export const defaultDateTimeFormat = 'mmm d, yyyy h:MMtt';

/**
 * #1f78d1 --> $blue-500 (see variables.scss)
 */
export const scatterChartLineColor = '#1f78d1';

export const scatterChartLineProps = {
  default: {
    type: 'line',
    showSymbol: false,
    lineStyle: { color: scatterChartLineColor },
  },
};
