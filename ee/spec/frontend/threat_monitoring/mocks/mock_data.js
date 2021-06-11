export const mockEnvironmentsResponse = {
  environments: [
    {
      id: 1129970,
      name: 'production',
      state: 'available',
    },
    {
      id: 1156094,
      name: 'review/enable-network-policies',
      state: 'available',
    },
  ],
  available_count: 2,
  stopped_count: 5,
};

export const mockPoliciesResponse = [
  {
    name: 'policy',
    namespace: 'production',
    manifest: `---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: example-name
  namespace: example-namespace
spec:
  podSelector:
    matchLabels:
      role: db
  policyTypes:
  - Ingress
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          project: myproject`,
    creation_timestamp: '2020-04-14T00:08:30Z',
    is_enabled: true,
  },
];

export const mockCiliumPolicy = {
  name: 'policy',
  creationTimestamp: new Date('2021-06-07T00:00:00.000Z'),
  manifest: `apiVersion: cilium.io/v2
kind: CiliumNetworkPolicy
metadata:
  name: policy
spec:
  endpointSelector: {}`,
};

export const mockScanExecutionPolicy = {
  name: 'Scheduled DAST scan',
  creationTimestamp: new Date('2021-06-07T00:00:00.000Z'),
  manifest: `---
name: Enforce DAST in every pipeline
description: This policy enforces pipeline configuration to have a job with DAST scan
enabled: true
rules:
- type: pipeline
  branches:
  - master
actions:
- scan: dast
  scanner_profile: Scanner Profile
  site_profile: Site Profile
`,
};

export const mockNominalHistory = [
  ['2019-12-04T00:00:00.000Z', 56],
  ['2019-12-05T00:00:00.000Z', 2647],
];

export const mockAnomalousHistory = [
  ['2019-12-04T00:00:00.000Z', 1],
  ['2019-12-05T00:00:00.000Z', 83],
];

export const mockNetworkPolicyStatisticsResponse = {
  ops_total: {
    total: 2703,
    drops: 84,
  },
  ops_rate: {
    total: [
      [1575417600, 56],
      [1575504000, 2647],
    ],
    drops: [
      [1575417600, 1],
      [1575504000, 83],
    ],
  },
};

export const formattedMockNetworkPolicyStatisticsResponse = {
  opsRate: {
    drops: [
      [new Date('2019-12-04T00:00:00.000Z'), 1],
      [new Date('2019-12-05T00:00:00.000Z'), 83],
    ],
    total: [
      [new Date('2019-12-04T00:00:00.000Z'), 56],
      [new Date('2019-12-05T00:00:00.000Z'), 2647],
    ],
  },
  opsTotal: { drops: 84, total: 2703 },
};

export const mockAlerts = [
  {
    iid: '01',
    assignees: {
      nodes: [
        {
          id: 'Alert:1',
          name: 'Administrator',
          username: 'root',
          avatarUrl: '/test-avatar-url',
          webUrl: 'https://gitlab:3443/root',
        },
      ],
    },
    eventCount: '1',
    issueIid: null,
    issue: { iid: '5', state: 'opened', title: 'Issue 01', webUrl: 'http://test.com/05' },
    title: 'Issue 01',
    severity: 'HIGH',
    status: 'TRIGGERED',
    startedAt: '2020-11-19T18:36:23Z',
  },
  {
    iid: '02',
    eventCount: '2',
    assignees: { nodes: [] },
    issueIid: null,
    issue: { iid: '6', state: 'closed', title: 'Issue 02', webUrl: 'http://test.com/06' },
    severity: 'CRITICAL',
    title: 'Issue 02',
    status: 'ACKNOWLEDGED',
    startedAt: '2020-11-16T21:59:28Z',
  },
  {
    iid: '03',
    eventCount: '3',
    assignees: { nodes: [] },
    issueIid: null,
    issue: null,
    severity: 'MEDIUM',
    title: 'Issue 03',
    status: 'RESOLVED',
    startedAt: '2020-11-13T20:03:04Z',
  },
  {
    iid: '04',
    assignees: { nodes: [] },
    issueIid: null,
    issue: null,
    severity: 'LOW',
    eventCount: '4',
    title: 'Issue 04',
    status: 'IGNORED',
    startedAt: '2020-10-29T13:37:55Z',
  },
];

export const mockPageInfo = {
  endCursor: 'eyJpZCI6IjIwIiwic3RhcnRlZF9hdCI6IjIwMjAtMTItMDMgMjM6MTI6NDkuODM3Mjc1MDAwIFVUQyJ9',
  hasNextPage: true,
  hasPreviousPage: false,
  startCursor: 'eyJpZCI6IjM5Iiwic3RhcnRlZF9hdCI6IjIwMjAtMTItMDQgMTg6MDE6MDcuNzY1ODgyMDAwIFVUQyJ9',
};

export const mockAlertDetails = {
  iid: '01',
  issue: { webUrl: '/#/-/issues/02' },
  title: 'dropingress',
  monitorTool: 'Cilium',
};
