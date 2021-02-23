import { s__ } from '~/locale';

export const DANGER = 'danger';
export const INFO = 'info';

export const FETCH_ERROR = s__(
  'ComplianceFrameworks|Error fetching compliance frameworks data. Please refresh the page',
);

export const SAVE_ERROR = s__(
  'ComplianceFrameworks|Unable to save this compliance framework. Please try again',
);

// Check that it matches the format [FILE].y(a)ml@[GROUP]/[PROJECT]
export const PIPELINE_CONFIGURATION_PATH_FORMAT = /^([^@]*\.ya?ml)@([^/]*)\/(.*)$/;
