import { s__ } from '~/locale';

const allVendor = 'All';

export const ALL = 'all';
export const STATE = {
  DETECTED: 'DETECTED',
  CONFIRMED: 'CONFIRMED',
};

export const BASE_FILTERS = {
  severity: {
    name: s__('ciReport|All severities'),
    id: ALL,
  },
  report_type: {
    name: s__('ciReport|All scanners'),
    id: ALL,
    vendor: allVendor,
  },
  project_id: {
    name: s__('ciReport|All projects'),
    id: ALL,
  },
};
