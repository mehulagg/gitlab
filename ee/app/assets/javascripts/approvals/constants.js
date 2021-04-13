import { __ } from '~/locale';

export const TYPE_USER = 'user';
export const TYPE_GROUP = 'group';
export const TYPE_HIDDEN_GROUPS = 'hidden_groups';

export const BRANCH_FETCH_DELAY = 250;
export const ANY_BRANCH = {
  id: null,
  name: __('Any branch'),
};

export const RULE_TYPE_FALLBACK = 'fallback';
export const RULE_TYPE_REGULAR = 'regular';
export const RULE_TYPE_REPORT_APPROVER = 'report_approver';
export const RULE_TYPE_CODE_OWNER = 'code_owner';
export const RULE_TYPE_ANY_APPROVER = 'any_approver';
export const RULE_TYPE_EXTERNAL_APPROVAL = 'external_approval';
export const RULE_NAME_ANY_APPROVER = 'All Members';

export const VULNERABILITY_CHECK_NAME = 'Vulnerability-Check';
export const LICENSE_CHECK_NAME = 'License-Check';

export const JOB_TYPES = {
  SAST: 'sast',
  DAST: 'dast',
  DEPENDENCY_SCANNING: 'dependency_scanning',
  SECRET_DETECTION: 'secret_detection',
  COVERAGE_FUZZING: 'coverage_fuzzing',
  LICENSE_SCANNING: 'license_scanning',
};

export const APPROVAL_RULE_CONFIGS = {
  [VULNERABILITY_CHECK_NAME]: {
    title: __('Vulnerability-Check'),
    popoverText: __(
      'A merge request approval is required when a security report contains a new vulnerability of high, critical, or unknown severity.',
    ),
    documentationText: __('Learn more about Vulnerability-Check'),
  },
  [LICENSE_CHECK_NAME]: {
    title: __('License-Check'),
    popoverText: __(
      'A merge request approval is required when the license compliance report contains a denied license.',
    ),
    documentationText: __('Learn more about License-Check'),
  },
};

export const APPROVALS_HELP_PATH = 'user/project/merge_requests/merge_request_approvals';
