export const LOADING = 'LOADING';
export const ERROR = 'ERROR';
export const SUCCESS = 'SUCCESS';

/**
 * Tracks snowplow event when user views report details
 */
export const trackMrSecurityReportDetails = {
  category: 'Vulnerability_Management',
  action: 'mr_report_inline_details',
};
