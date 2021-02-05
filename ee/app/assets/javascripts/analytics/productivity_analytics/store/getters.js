export const getMetricTypes = (state) => (chartKey) =>
  state.metricTypes.filter((m) => m.charts.indexOf(chartKey) !== -1);
