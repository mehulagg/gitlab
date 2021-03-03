import { chartKeys, tableSortOrder, daysToMergeMetric } from '../../../constants';

export const sortIcon = (state) => tableSortOrder[state.sortOrder].icon;

export const sortTooltipTitle = (state) => tableSortOrder[state.sortOrder].title;

export const sortFieldDropdownLabel = (state, _, rootState) =>
  rootState.metricTypes.find((metric) => metric.key === state.sortField).label;

export const tableSortOptions = (_state, _getters, _rootState, rootGetters) => [
  daysToMergeMetric,
  ...rootGetters.getMetricTypes(chartKeys.timeBasedHistogram),
];

export const columnMetricLabel = (state, _getters, _rootState, rootGetters) =>
  rootGetters
    .getMetricTypes(chartKeys.timeBasedHistogram)
    .find((metric) => metric.key === state.columnMetric).label;

export const isSelectedSortField = (state) => (sortField) => state.sortField === sortField;
