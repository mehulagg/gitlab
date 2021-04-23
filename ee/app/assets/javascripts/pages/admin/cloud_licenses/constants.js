import { __, s__ } from '~/locale';
import activateSubscriptionMutation from './graphql/mutations/activate_subscription.mutation.graphql';
import getCurrentLicense from './graphql/queries/get_current_license.query.graphql';
import getLicenseHistory from './graphql/queries/get_license_history.query.graphql';

export const subscriptionMainTitle = s__('SuperSonics|Your subscription');
export const subscriptionActivationTitle = s__(
  `SuperSonics|You do not have an active subscription`,
);
export const subscriptionDetailsHeaderText = s__('SuperSonics|Subscription details');
export const licensedToHeaderText = s__('SuperSonics|Licensed to');
export const manageSubscriptionButtonText = s__('SuperSonics|Manage');
export const syncSubscriptionButtonText = s__('SuperSonics|Sync subscription details');
export const copySubscriptionIdButtonText = __('Copy');
export const subscriptionTypeText = __('%{type} License');
export const detailsLabels = {
  address: __('Address'),
  company: __('Company'),
  email: __('Email'),
  id: s__('SuperSonics|ID'),
  lastSync: s__('SuperSonics|Last Sync'),
  name: __('Name'),
  plan: s__('SuperSonics|Plan'),
  expiresAt: s__('SuperSonics|Renews'),
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
  activatedAt: s__('SuperSonics|Activated on'),
  expiresOn: s__('SuperSonics|Expires on'),
  seats: s__('SuperSonics|Seats'),
  startsAt: s__('SuperSonics|Valid From'),
  title: __('Subscription History'),
  type: s__('SuperSonics|Type'),
};
export const manualSyncSuccessfulTitle = s__(
  'SuperSonics|The subscription details synced successfully.',
);
export const manualSyncFailureText = s__(
  'SuperSonics|You can no longer sync your subscription details with GitLab. Get help for the most common connectivity issues by %{connectivityHelpLinkStart}troubleshooting the activation code%{connectivityHelpLinkEnd}.',
);
export const manualSyncFailureTitle = s__('SuperSonics|There is a connectivity issue.');

export const subscriptionActivationForm = {
  title: s__('CloudLicense|Activate subscription'),
  howToActivateSubscription: s__(
    'CloudLicense|Learn how to %{linkStart}activate your subscription%{linkEnd}.',
  ),
  activationCode: s__('CloudLicense|Activation code'),
  pasteActivationCode: s__('CloudLicense|Paste your activation code'),
  acceptTerms: s__(
    'CloudLicense|I agree that my use of the GitLab Software is subject to the Subscription Agreement located at the %{linkStart}Terms of Service%{linkEnd}, unless otherwise agreed to in writing with GitLab.',
  ),
  activateLabel: s__('CloudLicense|Activate'),
};

export const subscriptionType = {
  CLOUD: 'cloud',
  LEGACY: 'legacy',
};

export const subscriptionQueries = {
  query: getCurrentLicense,
  mutation: activateSubscriptionMutation,
};

export const subscriptionHistoryQueries = {
  query: getLicenseHistory,
};

export const trialCard = {
  title: s__('CloudLicense|Free trial'),
  description: s__(
    'CloudLicense|You can start a free trial of GitLab Ultimate without any obligation or payment details.',
  ),
  startTrial: s__('CloudLicense|Start free trial'),
};

export const buySubscriptionCard = {
  title: s__('CloudLicense|Subscription'),
  description: s__(
    'CloudLicense|Ready to get started? A GitLab plan is ideal for scaling organizations and for multi team usage.',
  ),
  buttonLabel: s__('CloudLicense|Buy subscription'),
};
