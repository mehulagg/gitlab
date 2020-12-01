export const groupData = [{ id: 'foo', full_name: 'Foo' }, { id: 'bar', full_name: 'Bar' }];

export const pageData = {
  'x-next-page': 2,
};

export const groupNodes = [
  {
    __typename: 'Group',
    full_name: 'Foo',
    id: 'foo',
  },
  {
    __typename: 'Group',
    full_name: 'Bar',
    id: 'bar',
  },
];

export const nextGroupNode = {
  __typename: 'Group',
  full_name: 'Baz',
  id: 'baz',
};

export const groupPageInfo = {
  nextPage: 2,
};

export const devopsAdoptionSegmentsData = {
  nodes: [
    {
      name: 'Segment 1',
      latestSnapshot: {
        issueOpened: true,
        mergeRequestOpened: true,
        mergeRequestApproved: false,
        runnerConfigured: true,
        pipelineSucceeded: false,
        deploySucceeded: false,
        securityScanSucceeded: false,
        recordedAt: '2020-10-31T23:59:59Z',
        __typename: 'latestSnapshot',
      },
      __typename: 'devopsSegment',
    },
  ],
  __typename: 'devopsAdoptionSegments',
};

export const devopsAdoptionTableHeaders = [
  'Segment',
  'Issues',
  'MRs',
  'Approvals',
  'Runners',
  'Pipelines',
  'Deploys',
  'Scanning',
  '',
];
