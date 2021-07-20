export const COLLAPSE_SECURITY_REPORTS_SUMMARY_LOCAL_STORAGE_KEY =
  'hide_pipelines_security_reports_summary_details';

export const SURVEY_BANNER_LOCAL_STORAGE_KEY = 'vulnerability_management_survey_request';
// NOTE: This string needs to parse to an invalid date. Do not put any characters in between the
// word 'survey' and the number, or else it will parse to a valid date.
export const SURVEY_BANNER_CURRENT_ID = 'survey1';

export const DEFAULT_SCANNER = 'GitLab';
export const SCANNER_ID_PREFIX = 'gid://gitlab/Vulnerabilities::Scanner/';
