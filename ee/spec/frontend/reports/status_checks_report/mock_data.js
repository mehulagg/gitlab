export const approvedChecks = [
  {
    id: 1,
    name: 'Foo',
    external_url: 'http://foo',
    status: 'approved',
  },
];

export const pendingChecks = [
  {
    id: 2,
    name: 'Foo Bar',
    external_url: 'http://foobar',
    status: 'pending',
  },
];

export const mixedChecks = [...approvedChecks, ...pendingChecks];
