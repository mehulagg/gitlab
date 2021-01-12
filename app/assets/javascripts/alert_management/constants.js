import { s__ } from '~/locale';

export const ALERTS_STATUS_TABS = [
  {
    title: s__('AlertManagement|Open'),
    status: 'OPEN',
    filters: ['TRIGGERED', 'ACKNOWLEDGED'],
  },
  {
    title: s__('AlertManagement|Triggered'),
    status: 'TRIGGERED',
    filters: 'TRIGGERED',
  },
  {
    title: s__('AlertManagement|Acknowledged'),
    status: 'ACKNOWLEDGED',
    filters: 'ACKNOWLEDGED',
  },
  {
    title: s__('AlertManagement|Resolved'),
    status: 'RESOLVED',
    filters: 'RESOLVED',
  },
  {
    title: s__('AlertManagement|All alerts'),
    status: 'ALL',
    filters: ['TRIGGERED', 'ACKNOWLEDGED', 'RESOLVED'],
  },
];

/* eslint-disable @gitlab/require-i18n-strings */

/**
 * Tracks snowplow event when user views alerts list
 */
export const trackAlertListViewsOptions = {
  category: 'Alert Management',
  action: 'view_alerts_list',
};
