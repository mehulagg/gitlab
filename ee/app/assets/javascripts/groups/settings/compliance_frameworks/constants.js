import { s__ } from '~/locale';

export const DEFAULT_FORM_DATA = {
  name: null,
  description: null,
  color: null,
};

export const FETCH_ERROR = s__(
  'ComplianceFrameworks|Error fetching compliance frameworks data. Please refresh the page',
);

export const SAVE_ERROR = s__(
  'ComplianceFrameworks|Unable to save this compliance framework. Please try again',
);
