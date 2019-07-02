import { __ } from '~/locale';

export const chartKeys = {
  main: 'main',
  timeBasedHistogram: 'timeBasedHistogram',
  commitBasedHistogram: 'commitBasedHistogram',
  scatterplot: 'scatterplot',
};

export const metricTypes = [
  {
    key: 'time_to_first_comment',
    label: __('Time from first commit until first comment'),
    chart: chartKeys.timeBasedHistogram,
  },
  {
    key: 'time_to_last_commit',
    label: __('Time from first comment to last commit'),
    chart: chartKeys.timeBasedHistogram,
  },
  {
    key: 'time_to_merge',
    label: __('Time from last commit to merge'),
    chart: chartKeys.timeBasedHistogram,
  },
  {
    key: 'commits_count',
    label: __('Number of commits per MR'),
    chart: chartKeys.commitBasedHistogram,
  },
  {
    key: 'loc_per_commit',
    label: __('Number of LOCs per commit'),
    chart: chartKeys.commitBasedHistogram,
  },
  {
    key: 'files_touched',
    label: __('Number of files touched'),
    chart: chartKeys.commitBasedHistogram,
  },
];

export const defaultMetricTypes = {
  [chartKeys.timeBasedHistogram]: 'time_to_first_comment',
  [chartKeys.commitBasedHistogram]: 'commits_count',
};
