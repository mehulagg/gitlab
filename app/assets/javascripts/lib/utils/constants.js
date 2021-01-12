import { s__ } from '~/locale';

export const BYTES_IN_KIB = 1024;
export const HIDDEN_CLASS = 'hidden';
export const TRUNCATE_WIDTH_DEFAULT_WIDTH = 80;
export const TRUNCATE_WIDTH_DEFAULT_FONT_SIZE = 12;

export const DATETIME_RANGE_TYPES = {
  fixed: 'fixed',
  anchored: 'anchored',
  rolling: 'rolling',
  open: 'open',
  invalid: 'invalid',
};

export const SEVERITY_LEVELS = {
  CRITICAL: s__('severity|Critical'),
  HIGH: s__('severity|High'),
  MEDIUM: s__('severity|Medium'),
  LOW: s__('severity|Low'),
  INFO: s__('severity|Info'),
  UNKNOWN: s__('severity|Unknown'),
};
