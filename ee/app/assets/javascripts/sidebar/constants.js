import { __ } from '~/locale';

export const healthStatus = {
  ON_TRACK: 'onTrack',
  NEEDS_ATTENTION: 'needsAttention',
  AT_RISK: 'atRisk',
};

export const healthStatusTextMap = {
  [healthStatus.ON_TRACK]: __('On track'),
  [healthStatus.NEEDS_ATTENTION]: __('Needs attention'),
  [healthStatus.AT_RISK]: __('At risk'),
};

export const iterationSelectTextMap = {
  iteration: __('Iteration'),
  noIteration: __('No iteration'),
  noIterationItem: [{ title: __('No iteration'), id: null }],
  iterationSelectFail: __('Failed to set iteration on this issue. Please try again.'),
};

export const iterationDisplayState = 'opened';

export const healthStatusForRestApi = {
  NO_STATUS: '0',
  [healthStatus.ON_TRACK]: 'on_track',
  [healthStatus.NEEDS_ATTENTION]: 'needs_attention',
  [healthStatus.AT_RISK]: 'at_risk',
};

export const MAX_DISPLAY_WEIGHT = 99999;
