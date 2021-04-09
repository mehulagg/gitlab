import { __, s__ } from '~/locale';

export const subscriptionDetailsHeaderText = s__('SuperSonics|Subscription details');
export const licensedToHeaderText = s__('SuperSonics|Licensed to');
export const manageSubscriptionButtonText = s__('SuperSonics|Manage');
export const syncSubscriptionButtonText = s__('SuperSonics|Sync Subscription details');
export const copySubscriptionIdButtonText = __('Copy');
export const subscriptionTypeText = __('%{type} License');
export const detailsLabels = {
  address: __('Address'),
  id: s__('SuperSonics|ID'),
  company: __('Company'),
  email: __('Email'),
  lastSync: s__('SuperSonics|Last Sync'),
  name: __('Name'),
  plan: s__('SuperSonics|Plan'),
  renews: s__('SuperSonics|Renews'),
  startsAt: s__('SuperSonics|Started'),
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
export const subscriptionTable = {
  activatedOn: s__('SuperSonics|Activated on'),
  expiresOn: s__('SuperSonics|Expires on'),
  seats: s__('SuperSonics|Seats'),
  title: __('Subscription History'),
  type: s__('SuperSonics|Type'),
  validFrom: s__('SuperSonics|Valid From'),
};
export const subscriptionType = {
  CLOUD: 'cloud',
  LEGACY: 'legacy',
};
