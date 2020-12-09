import { CHART_TYPES } from 'ee/insights/constants';
import { __ } from '~/locale';

const getAxisTitle = label => {
  switch (label) {
    case 'day':
      return __('Days');
    case 'week':
      return __('Weeks');
    case 'month':
      return __('Months');
    case 'issue':
      return __('Issues');
    case 'merge_request':
      return __('Merge requests');
    default:
      return '';
  }
};

export const transformChartDataForGlCharts = (
  { type, query: { group_by, issuable_type } },
  { labels, datasets },
) => {
  const formattedData = {
    xAxisTitle: getAxisTitle(group_by),
    yAxisTitle: getAxisTitle(issuable_type),
    labels,
    datasets: [],
    seriesNames: [],
  };

  switch (type) {
    case CHART_TYPES.BAR:
      formattedData.datasets = [
        {
          name: 'all',
          data: labels.map((label, i) => [label, datasets[0].data[i]]),
        },
      ];
      break;
    case CHART_TYPES.STACKED_BAR:
      formattedData.datasets.push(
        ...datasets.map(dataset => ({
          name: dataset.label,
          data: dataset.data,
        })),
      );
      break;
    case CHART_TYPES.LINE:
      formattedData.datasets.push(
        ...datasets.map(dataset => ({
          name: dataset.label,
          data: labels.map((label, i) => [label, dataset.data[i]]),
        })),
      );

      break;
    default:
      formattedData.datasets = { all: labels.map((label, i) => [label, datasets[0].data[i]]) };
  }
  return formattedData;
};

export default {
  transformChartDataForGlCharts,
};
