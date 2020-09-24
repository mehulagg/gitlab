import { __, s__ } from '~/locale';

export const severityLevels = {
  CRITICAL: 'critical',
  HIGH: 'high',
  UNKNOWN: 'unknown',
  MEDIUM: 'medium',
  LOW: 'low',
  NONE: 'none',
};

export const severityLevelsTranslations = {
  [severityLevels.CRITICAL]: s__('severity|Critical'),
  [severityLevels.HIGH]: s__('severity|High'),
  [severityLevels.UNKNOWN]: s__('severity|Unknown'),
  [severityLevels.MEDIUM]: s__('severity|Medium'),
  [severityLevels.LOW]: s__('severity|Low'),
  [severityLevels.NONE]: s__('severity|None'),
};

export const SEVERITY_LEVELS_ORDERED_BY_SEVERITY = [
  severityLevels.CRITICAL,
  severityLevels.HIGH,
  severityLevels.UNKNOWN,
  severityLevels.MEDIUM,
  severityLevels.LOW,
  severityLevels.NONE,
];

export const severityGroupTypes = {
  F: 'F',
  D: 'D',
  C: 'C',
  B: 'B',
  A: 'A',
};

export const SEVERITY_GROUPS = [
  {
    type: severityGroupTypes.F,
    description: __('Projects with critical vulnerabilities'),
    warning: __('Critical vulnerabilities present'),
    severityLevels: [severityLevels.CRITICAL],
  },
  {
    type: severityGroupTypes.D,
    description: __('Projects with high or unknown vulnerabilities'),
    warning: __('High or unknown vulnerabilities present'),
    severityLevels: [severityLevels.HIGH, severityLevels.UNKNOWN],
  },
  {
    type: severityGroupTypes.C,
    description: __('Projects with medium vulnerabilities'),
    warning: __('Medium vulnerabilities present'),
    severityLevels: [severityLevels.MEDIUM],
  },
  {
    type: severityGroupTypes.B,
    description: __('Projects with low vulnerabilities'),
    warning: __('Low vulnerabilities present'),
    severityLevels: [severityLevels.LOW],
  },
  {
    type: severityGroupTypes.A,
    description: __('Projects with no vulnerabilities and security scanning enabled'),
    warning: __('No vulnerabilities present'),
    severityLevels: [severityLevels.NONE],
  },
];
