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
