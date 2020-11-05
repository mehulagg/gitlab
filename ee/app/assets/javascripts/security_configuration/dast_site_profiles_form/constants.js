import { s__ } from '~/locale';

export const DAST_SITE_VALIDATION_METHOD_TEXT_FILE = 'TEXT_FILE';
export const DAST_SITE_VALIDATION_METHOD_HTTP_HEADER = 'HTTP_HEADER';

export const DAST_SITE_VALIDATION_METHODS = {
  [DAST_SITE_VALIDATION_METHOD_TEXT_FILE]: {
    value: DAST_SITE_VALIDATION_METHOD_TEXT_FILE,
    text: s__('DastProfiles|Text file validation'),
    i18n: {
      locationStepLabel: s__('DastProfiles|Step 3 - Confirm text file location and validate'),
    },
  },
  [DAST_SITE_VALIDATION_METHOD_HTTP_HEADER]: {
    value: DAST_SITE_VALIDATION_METHOD_HTTP_HEADER,
    text: s__('DastProfiles|Header validation'),
    i18n: {
      locationStepLabel: s__('DastProfiles|Step 3 - Confirm header location and validate'),
    },
  },
};

export const DAST_SITE_VALIDATION_STATUS = {
  PENDING: 'PENDING_VALIDATION',
  INPROGRESS: 'INPROGRESS_VALIDATION',
  PASSED: 'PASSED_VALIDATION',
  FAILED: 'FAILED_VALIDATION',
};

export const DAST_SITE_VALIDATION_POLL_INTERVAL = 1000;
export const DAST_SITE_VALIDATION_HTTP_HEADER_KEY = 'Gitlab-On-Demand-DAST';
