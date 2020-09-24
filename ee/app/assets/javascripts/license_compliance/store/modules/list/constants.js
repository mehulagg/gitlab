import { s__ } from '~/locale';

export const REPORT_STATUS = {
  ok: 'ok',
  jobNotSetUp: 'job_not_set_up',
  jobFailed: 'job_failed',
  noLicenses: 'no_licenses',
  incomplete: 'no_license_files',
};

export const FETCH_ERROR_MESSAGE = s__(
  'Licenses|Error fetching the license list. Please check your network connection and try again.',
);

export const SORT_BY = {
  CLASSIFICATION: 'classification',
};

export const SORT_ORDER = {
  DESC: 'desc',
};
