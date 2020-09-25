export const expirationPolicyPayload = override => ({
  data: {
    project: {
      containerExpirationPolicy: {
        __typename: 'ContainerExpirationPolicy',
        cadence: 'EVERY_DAY',
        enabled: true,
        keepN: 'TEN_TAGS',
        nameRegex: 'asdasdssssdfdf',
        nameRegexKeep: 'sss',
        olderThan: 'FOURTEEN_DAYS',
        ...override,
      },
      __typename: 'Project',
    },
  },
});
