export * from '~/vue_shared/security_reports/store/constants';

/**
 * Tracks snowplow event when user views report details
 */
export const trackMrSecurityReportDetails = {
  category: 'Vulnerability_Management',
  action: 'mr_report_inline_details',
};
