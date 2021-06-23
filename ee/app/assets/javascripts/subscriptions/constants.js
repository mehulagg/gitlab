import { s__ } from '~/locale';

export const ZUORA_SCRIPT_URL = 'https://static.zuora.com/Resources/libs/hosted/1.3.1/zuora-min.js';

export const PAYMENT_FORM_ID = 'paid_signup_flow';

export const ZUORA_IFRAME_OVERRIDE_PARAMS = {
  style: 'inline',
  submitEnabled: 'true',
  retainValues: 'true',
};

export const ERROR_FETCHING_COUNTRIES = s__('Checkout|Failed to load countries. Please try again.');
export const ERROR_FETCHING_STATES = s__('Checkout|Failed to load states. Please try again.');
export const ERROR_LOADING_PAYMENT_FORM = s__(
  'Checkout|Failed to load the payment form. Please try again.',
);

// The order of the steps in this array determines the flow of the application
/* eslint-disable @gitlab/require-i18n-strings */
export const STEPS = [
  { id: 'subscriptionDetails', __typename: 'Step' },
  { id: 'billingAddress', __typename: 'Step' },
  { id: 'paymentMethod', __typename: 'Step' },
  { id: 'confirmOrder', __typename: 'Step' },
];
/* eslint-enable @gitlab/require-i18n-strings */
