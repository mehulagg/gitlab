import { __, s__ } from '~/locale';

export const subscriptionDetailsHeaderText = s__('CloudLicense|Subscription details');
export const licensedToHeaderText = s__('CloudLicense|Licensed to');
export const manageSubscriptionButtonText = s__('CloudLicense|Manage');
export const syncSubscriptionButtonText = s__('CloudLicense|Sync Subscription details');
export const copySubscriptionIdButtonText = __('Copy');
export const detailsLabels = {
  address: __('Address'),
  id: s__('CloudLicense|ID'),
  company: __('Company'),
  email: __('Email'),
  lastSync: s__('CloudLicense|Last Sync'),
  name: __('Name'),
  plan: s__('CloudLicense|Plan'),
  startsAt: s__('CloudLicense|Started'),
  renews: s__('CloudLicense|Renews'),
};

export const billableUsersTitle = s__('CloudLicense|Billable users');
export const maximumUsersTitle = s__('CloudLicense|Maximum users');
export const usersInSubscriptionTitle = s__('CloudLicense|Users in subscription');
export const usersOverSubscriptionTitle = s__('CloudLicense|Users over subscription');
export const billableUsersText = s__(
  'CloudLicense|This is the number of %{billableUsersLinkStart}billable users%{billableUsersLinkEnd} on your installation, and this is the minimum number you need to purchase when you renew your license.',
);
export const maximumUsersText = s__(
  'CloudLicense|This is the highest peak of users on your installation since the license started.',
);
export const usersInSubscriptionText = s__(
  `CloudLicense|Users with a Guest role or those who don't belong to a Project or Group will not use a seat from your license.`,
);
export const usersOverSubscriptionText = s__(
  `CloudLicense|You'll be charged for %{trueUpLinkStart}users over license%{trueUpLinkEnd} on a quarterly or annual basis, depending on the terms of your agreement.`,
);
