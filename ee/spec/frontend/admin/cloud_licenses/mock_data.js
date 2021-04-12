export const license = {
  ULTIMATE: {
    billableUsers: '8',
    company: 'ACME Corp',
    email: 'user@acmecorp.com',
    id: '1309188',
    lastSync: 'just now - actual date',
    maximumUsers: '8',
    name: 'Jane Doe',
    plan: 'Ultimate',
    startsAt: '22 February',
    renews: 'in 11 months',
    usersInLicense: '10',
    usersOverSubscription: '0',
  },
};

export const activated_license = {
  id: 'gid://gitlab/License/3',
  type: 'legacy',
  plan: 'ultimate',
  name: 'Test license',
  email: 'user@example.com',
  company: 'Example Inc',
  startsAt: '2020-01-01',
  expiresAt: '2022-01-01',
  activatedAt: '2021-01-02',
  lastSync: null,
  usersInLicenseCount: 100,
  billableUsersCount: 50,
  maximumUserCount: 50,
  usersOverLicenseCount: 0
};

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
        license: activated_license,
        errors: ["undefined method `[]' for nil:NilClass"],
        __typename: 'GitlabSubscriptionActivatePayload',
      },
    },
  },
  SUCCESS: {
    data: {
      gitlabSubscriptionActivate: {
        license: activated_license,
        errors: [],
      },
    },
  },
};
