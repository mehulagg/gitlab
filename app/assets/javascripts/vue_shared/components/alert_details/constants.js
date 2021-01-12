/* eslint-disable @gitlab/require-i18n-strings */

/**
 * Tracks snowplow event when user views alert details
 */
export const trackAlertsDetailsViewsOptions = {
  category: 'Alert Management',
  action: 'view_alert_details',
};

/**
 * Tracks snowplow event when alert status is updated
 */
export const trackAlertStatusUpdateOptions = {
  category: 'Alert Management',
  action: 'update_alert_status',
  label: 'Status',
};
