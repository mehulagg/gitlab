import { s__ } from '~/locale';

export const ERROR_FETCHING_COUNTRIES = s__('Checkout|Failed to load countries. Please try again.');
export const ERROR_FETCHING_STATES = s__('Checkout|Failed to load states. Please try again.');

// The order of the steps in this array determines the flow of the application
/* eslint-disable @gitlab/require-i18n-strings */
export const STEPS = [
  { id: 'subscriptionDetails', __typename: 'Step' },
  { id: 'billingAddress', __typename: 'Step' },
  { id: 'paymentMethod', __typename: 'Step' },
  { id: 'confirmOrder', __typename: 'Step' },
];
/* eslint-enable @gitlab/require-i18n-strings */
