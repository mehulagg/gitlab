import { STEPS } from 'ee/subscriptions/new/constants';

export const mockCiMinutesPlans = [
  {
    id: 'ci_minutes',
    deprecated: false,
    name: '1000 CI minutes pack',
    code: 'ci_minutes',
    active: true,
    free: null,
    pricePerMonth: 0.8333333333333334,
    pricePerYear: 10.0,
    features: null,
    aboutPageHref: null,
    hideDeprecatedCard: false,
  },
];

export const namespaces = [
  { id: 132, name: 'My first group', users: 3, __typename: 'Namespace' },
  { id: 483, name: 'My second group', users: 12, __typename: 'Namespace' },
];

export const plans = [
  { id: 'firstPlanId', code: 'bronze', pricePerYear: 48, name: 'bronze', __typename: 'Plan' },
  { id: 'secondPlanId', code: 'silver', pricePerYear: 228, name: 'silver', __typename: 'Plan' },
];

export const stateData = {
  state: {
    plans,
    namespaces: [],
    subscription: {
      planId: 'secondPlanId',
      quantity: 1,
      namespaceId: null,
      paymentMethodId: null,
      __typename: 'Subscription',
    },
    customer: {
      country: null,
      address1: null,
      address2: null,
      city: null,
      state: null,
      zipCode: null,
      company: null,
      __typename: 'Customer',
    },
    fullName: 'Full Name',
    isNewUser: false,
    isSetupForCompany: true,
  },
  stepList: STEPS,
  activeStep: STEPS[0],
};
