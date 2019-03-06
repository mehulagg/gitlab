import { s__ } from '~/locale';

export const SEVERITY_LEVELS = {
  critical: 'Critical',
  high: 'High',
  medium: 'Medium',
  low: 'Low',
  unknown: 'Unknown',
  info: 'Info',
  undefined: 'Undefined',
};

export const CONFIDENCE_LEVELS = {
  confirmed: 'Confirmed',
  high: 'High',
  medium: 'Medium',
  low: 'Low',
  unknown: 'Unknown',
  ignore: 'Ignore',
  experimental: 'Experimental',
  undefined: 'Undefined',
};

export const REPORT_TYPES = {
  container_scanning: s__('ciReport|Container Scanning'),
  dependency_scanning: s__('ciReport|Dependency Scanning'),
  sast: s__('ciReport|SAST'),
};
