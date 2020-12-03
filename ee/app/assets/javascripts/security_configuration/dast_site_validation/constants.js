import { s__ } from '~/locale';

export const DAST_SITE_VALIDATION_METHOD_TEXT_FILE = 'TEXT_FILE';
export const DAST_SITE_VALIDATION_METHOD_HTTP_HEADER = 'HEADER';

export const DAST_SITE_VALIDATION_METHODS = {
  [DAST_SITE_VALIDATION_METHOD_TEXT_FILE]: {
    value: DAST_SITE_VALIDATION_METHOD_TEXT_FILE,
    text: s__('DastSiteValidation|Text file validation'),
    i18n: {
      locationStepLabel: s__('DastSiteValidation|Step 3 - Confirm text file location and validate'),
    },
  },
  [DAST_SITE_VALIDATION_METHOD_HTTP_HEADER]: {
    value: DAST_SITE_VALIDATION_METHOD_HTTP_HEADER,
    text: s__('DastSiteValidation|Header validation'),
    i18n: {
      locationStepLabel: s__('DastSiteValidation|Step 3 - Confirm header location and validate'),
    },
  },
};

export const DAST_SITE_VALIDATION_STATUS = {
  PENDING: 'PENDING_VALIDATION',
  INPROGRESS: 'INPROGRESS_VALIDATION',
  PASSED: 'PASSED_VALIDATION',
  FAILED: 'FAILED_VALIDATION',
};

export const DAST_SITE_VALIDATION_STATUS_PROPS = {
  [DAST_SITE_VALIDATION_STATUS.INPROGRESS]: {
    label: s__('DastSiteValidation|Validating...'),
    cssClass: 'gl-text-blue-300',
    tooltipText: s__('DastSiteValidation|The validation is in progress. Please wait...'),
  },
  [DAST_SITE_VALIDATION_STATUS.PASSED]: {
    label: s__('DastSiteValidation|Validated'),
    cssClass: 'gl-text-green-500',
    tooltipText: s__(
      'DastSiteValidation|Validation succeeded. Both active and passive scans can be run against the target site.',
    ),
  },
  [DAST_SITE_VALIDATION_STATUS.FAILED]: {
    label: s__('DastSiteValidation|Validation failed'),
    cssClass: 'gl-text-red-500',
    tooltipText: s__('DastSiteValidation|The validation has failed. Please try again.'),
  },
};

export const DAST_SITE_VALIDATION_HTTP_HEADER_KEY = 'Gitlab-On-Demand-DAST';

export const DAST_SITE_VALIDATION_MODAL_ID = 'dast-site-validation-modal';
