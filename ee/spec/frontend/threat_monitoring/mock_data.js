export const mockEnvironmentsResponse = {
  environments: [
    {
      id: 1129970,
      name: 'production',
      state: 'available',
    },
    {
      id: 1156094,
      name: 'review/enable-blocking-waf',
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

export const mockNominalHistory = [
  ['2019-12-04T00:00:00.000Z', 56],
  ['2019-12-05T00:00:00.000Z', 2647],
];

export const mockAnomalousHistory = [
  ['2019-12-04T00:00:00.000Z', 1],
  ['2019-12-05T00:00:00.000Z', 83],
];

export const mockWafStatisticsResponse = {
  total_traffic: 2703,
  anomalous_traffic: 0.03,
  history: {
    nominal: mockNominalHistory,
    anomalous: mockAnomalousHistory,
  },
};

export const mockNetworkPolicyStatisticsResponse = {
  ops_total: {
    total: 2703,
    drops: 84,
  },
  ops_rate: {
    total: [[1575417600, 56], [1575504000, 2647]],
    drops: [[1575417600, 1], [1575504000, 83]],
  },
};

export const formattedMockNetworkPolicyStatisticsResponse = {
  opsRate: {
    drops: [[new Date('2019-12-04T00:00:00.000Z'), 1], [new Date('2019-12-05T00:00:00.000Z'), 83]],
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
    title: 'Issue 01',
    status: 'TRIGGERED',
    startedAt: '2020-11-19T18:36:23Z',
  },
  {
    iid: '02',
    title: 'Issue 02',
    status: 'ACKNOWLEDGED',
    startedAt: '2020-11-16T21:59:28Z',
  },
  {
    iid: '03',
    title: 'Issue 03',
    status: 'RESOLVED',
    startedAt: '2020-11-13T20:03:04Z',
  },
  {
    iid: '04',
    title: 'Issue 04',
    status: 'IGNORED',
    startedAt: '2020-10-29T13:37:55Z',
  },
];
