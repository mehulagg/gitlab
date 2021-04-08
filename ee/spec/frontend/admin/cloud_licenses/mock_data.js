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
