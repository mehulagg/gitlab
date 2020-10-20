import { s__ } from '~/locale';

export const ALL = 'all';
export const STATE = {
  DETECTED: 'DETECTED',
  CONFIRMED: 'CONFIRMED',
};

export const BASE_FILTERS = {
  state: {
    name: s__('VulnerabilityStatusTypes|All'),
    id: ALL,
  },
  severity: {
    name: s__('ciReport|All severities'),
    id: ALL,
  },
  report_type: {
    name: s__('ciReport|All scanners'),
    id: ALL,
  },
  project_id: {
    name: s__('ciReport|All projects'),
    id: ALL,
  },
};
