export const license = {
  ULTIMATE: {
    id: '1309188',
    plan: 'Ultimate',
    lastSync: 'just now - actual date',
    startsAt: '22 February',
    renews: 'in 11 months',
    name: 'Jane Doe',
    email: 'user@acmecorp.com',
    company: 'ACME Corp',
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
