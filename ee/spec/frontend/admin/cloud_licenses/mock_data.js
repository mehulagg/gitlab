export const license = {
  ULTIMATE: {
    billableUsersCount: '8',
    expiresAt: '2022-03-16',
    company: 'ACME Corp',
    email: 'user@acmecorp.com',
    id: '1309188',
    lastSync: '2021-03-16T00:00:00.000',
    maximumUserCount: '8',
    name: 'Jane Doe',
    plan: 'ultimate',
    startsAt: '2021-03-16',
    usersInLicenseCount: '10',
    usersOverLicenseCount: '0',
  },
};

export const subscriptionHistory = [
  {
    company: 'ACME Corp',
    email: 'user@acmecorp.com',
    expiresAt: '2022-03-16',
    // TODO: verify presence in graphQL response
    id: '1309188',
    name: 'Jane Doe',
    plan: 'ultimate',
    startsAt: '2021-03-16',
    type: subscriptionType.CLOUD,
    validFrom: '2021-03-16',
    usersInLicenseCount: '10',
  },
  {
    company: 'ACME Corp',
    email: 'user@acmecorp.com',
    expiresAt: '2021-06-30',
    // TODO: verify presence in graphQL response
    id: '000000000',
    name: 'Jane Doe',
    plan: 'premium',
    startsAt: '2020-07-01',
    type: subscriptionType.LEGACY,
    validFrom: '2020-07-01',
    usersInLicenseCount: '5',
  },
];

export const activateLicenseMutationResponse = {
  FAILURE: [
    {
      errors: [
        {
          message:
            'Variable $gitlabSubscriptionActivateInput of type GitlabSubscriptionActivateInput! was provided invalid value',
          locations: [
            {
              line: 1,
              column: 11,
            },
          ],
          extensions: {
            value: null,
            problems: [
              {
                path: [],
                explanation: 'Expected value to not be null',
              },
            ],
          },
        },
      ],
    },
  ],
  FAILURE_IN_DISGUISE: {
    data: {
      gitlabSubscriptionActivate: {
        clientMutationId: null,
        errors: ["undefined method `[]' for nil:NilClass"],
        __typename: 'GitlabSubscriptionActivatePayload',
      },
    },
  },
  SUCCESS: {
    data: {
      gitlabSubscriptionActivate: {
        clientMutationId: null,
        errors: [],
      },
    },
  },
};
