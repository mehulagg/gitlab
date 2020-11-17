import { s__ } from '~/locale';

export const SEVERITY_CLASS_NAME_MAP = {
  critical: 'text-danger-800',
  high: 'text-danger-600',
  medium: 'text-warning-400',
  low: 'text-warning-200',
  info: 'text-primary-400',
  unknown: 'text-secondary-400',
};

export const SEVERITY_TOOLTIP_TITLE_MAP = {
  unknown: s__(
    `SecurityReports|The rating "unknown" indicates that the underlying scanner doesn’t contain or provide a severity rating.`,
  ),
};
