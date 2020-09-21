import { s__ } from '~/locale';

export const DAST_SITE_VALIDATION_METHOD_TEXT_FILE = 'TEXT_FILE';
// @TODO - check with backend about the naming of this: ee/app/models/dast_site_validation.rb
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
      // @TODO - confirm the copy with design
      locationStepLabel: s__('DastProfiles|Step 3 - Confirm header location and validate'),
    },
  },
};

export const DAST_SITE_VALIDATION_STATUS = {
  VALID: 'PASSED_VALIDATION',
  INVALID: 'FAILED_VALIDATION',
};
