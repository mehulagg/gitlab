export default [
  {
    environmentPath: 'some/path',
    logsPath: 'some/path/logs',
    project: { path_with_namespace: 'some/path', name: 'some project' },
    name: 'production',
    lastDeployment: { id: '123' },
    rolloutStatus: {
      instances: [
        { status: 'running', pod_name: 'some pod', tooltip: 'success', track: '1', stable: true },
        { status: 'running', pod_name: 'some pod', tooltip: 'success', track: '2', stable: true },
      ],
    },
    updatedAt: '2017-08-13T12:25:24.098Z',
  },
  {
    environmentPath: 'some/other/path',
    logsPath: 'some/other/path/logs',
    project: { path_with_namespace: 'some/other/path', name: 'some other project' },
    name: 'staging',
    lastDeployment: { id: '456' },
    rolloutStatus: {
      status: 'loading',
      instances: [],
    },
    updatedAt: '2019-01-13T12:25:24.098Z',
  },
  {
    environmentPath: 'yet/another/path',
    logsPath: 'yet/another/path/logs',
    project: { path_with_namespace: 'yet/another/path', name: 'yet another project' },
    name: 'development',
    lastDeployment: { id: '789' },
    rolloutStatus: { instances: [] },
    updatedAt: '2019-08-13T12:25:24.098Z',
  },
];
