import stateFilterData from './state_filter';
import confidentialFilterData from './confidential_filter';

export const FILTER_TYPES = {
  STATE: 'state',
  CONFIDENTIAL: 'confidential',
};

export const FILTER_DATA_BY_TYPE = {
  [FILTER_TYPES.STATE]: stateFilterData,
  [FILTER_TYPES.CONFIDENTIAL]: confidentialFilterData,
};
