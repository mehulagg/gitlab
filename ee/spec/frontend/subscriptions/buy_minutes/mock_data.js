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

export const mockNamespaces =
  '[{"id":22,"name":"Gitlab Org","users":5,"guests":2},{"id":23,"name":"Gnuwget","users":5,"guests":0}]';
export const mockParsedNamespaces = [
  { __typename: 'Namespace', id: 22, name: 'Gitlab Org', users: 5, guests: 2 },
  { __typename: 'Namespace', id: 23, name: 'Gnuwget', users: 5, guests: 0 },
];

export const mockNewUser = 'false';
export const mockFullName = 'John Admin';
export const mockSetupForCompany = 'true';
