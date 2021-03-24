// The order of the steps in this array determines the flow of the application
/* eslint-disable @gitlab/require-i18n-strings */
export const STEPS = [
  { id: 'subscriptionDetails', __typename: 'Step' },
  { id: 'billingAddress', __typename: 'Step' },
  { id: 'paymentMethod', __typename: 'Step' },
  { id: 'confirmOrder', __typename: 'Step' },
];
/* eslint-enable @gitlab/require-i18n-strings */

export const ZUORA_SCRIPT_URL = 'https://static.zuora.com/Resources/libs/hosted/1.3.1/zuora-min.js';

export const PAYMENT_FORM_ID = 'paid_signup_flow';

export const ZUORA_IFRAME_OVERRIDE_PARAMS = {
  style: 'inline',
  submitEnabled: 'true',
  retainValues: 'true',
};

export const TAX_RATE = 0;

export const NEW_GROUP = 'new_group';
