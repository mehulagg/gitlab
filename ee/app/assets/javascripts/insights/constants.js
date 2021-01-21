import { __ } from '~/locale';

export const CHART_TYPES = {
  BAR: 'bar',
  LINE: 'line',
  STACKED_BAR: 'stacked-bar',
  // Only used to convert to bar
  PIE: 'pie',
};

export const EMPTY_STATE_TITLE = __('Invalid Insights config file detected');
export const EMPTY_STATE_DESCRIPTION = __(
  'Please check the configuration file to ensure that it is available and the YAML is valid',
);
export const EMPTY_STATE_SVG_PATH = '/assets/illustrations/monitoring/getting_started.svg';
