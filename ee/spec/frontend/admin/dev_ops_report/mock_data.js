export const groupData = [
  { id: '1', full_name: 'Foo' },
  { id: '2', full_name: 'Bar' },
];

export const pageData = {
  'x-next-page': 2,
};

export const groupNodes = [
  {
    __typename: 'Group',
    full_name: 'Foo',
    id: '1',
  },
  {
    __typename: 'Group',
    full_name: 'Bar',
    id: '2',
  },
];

export const groupNodeLabelValues = [
  { text: 'Foo', value: '1' },
  { text: 'Bar', value: '2' },
];

export const groupIds = ['1', '2'];

export const groupGids = ['gid://gitlab/Group/1', 'gid://gitlab/Group/2'];

export const nextGroupNode = {
  __typename: 'Group',
  full_name: 'Baz',
  id: '3',
};

export const groupPageInfo = {
  nextPage: 2,
};

export const devopsAdoptionSegmentsData = {
  nodes: [
    {
      name: 'Segment 1',
      id: 1,
      groups: [
        {
          id: 'gid://gitlab/Group/1',
        },
      ],
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
    {
      name: 'Segment 2',
      id: 2,
      groups: [
        {
          id: 'gid://gitlab/Group/1',
        },
      ],
      latestSnapshot: null,
      __typename: 'devopsSegment',
    },
  ],
  __typename: 'devopsAdoptionSegments',
};

export const devopsAdoptionSegmentsDataEmpty = {
  nodes: [],
  __typename: 'devopsAdoptionSegments',
};

export const devopsAdoptionTableHeaders = [
  {
    index: 0,
    label: 'Group',
    tooltip: null,
  },
  {
    index: 1,
    label: 'Issues',
    tooltip: 'At least 1 issue opened',
  },
  {
    index: 2,
    label: 'MRs',
    tooltip: 'At least 1 MR opened',
  },
  {
    index: 3,
    label: 'Approvals',
    tooltip: 'At least 1 approval on an MR',
  },
  {
    index: 4,
    label: 'Runners',
    tooltip: 'Runner configured for project/group',
  },
  {
    index: 5,
    label: 'Pipelines',
    tooltip: 'At least 1 pipeline successfully run',
  },
  {
    index: 6,
    label: 'Deploys',
    tooltip: 'At least 1 deploy',
  },
  {
    index: 7,
    label: 'Scanning',
    tooltip: 'At least 1 security scan of any type run in pipeline',
  },
  {
    index: 8,
    label: '',
    tooltip: null,
  },
];

export const segmentName = 'Foooo';

export const genericErrorMessage = 'An error occured while saving the group. Please try again.';

export const dataErrorMessage = 'Name already taken.';

export const genericDeleteErrorMessage =
  'An error occured while deleting the group. Please try again.';
