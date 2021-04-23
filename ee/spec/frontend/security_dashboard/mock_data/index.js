export const mockProjectsWithSeverityCounts = () => [
  {
    id: 'gid://gitlab/Project/1',
    name: 'Gitlab Test',
    nameWithNamespace: 'Gitlab Org / Gitlab Test',
    securityDashboardPath: '/gitlab-org/gitlab-test/-/security/dashboard',
    fullPath: 'gitlab-org/gitlab-test',
    avatarUrl: null,
    path: 'gitlab-test',
    vulnerabilitySeveritiesCount: {
      critical: 2,
      high: 0,
      info: 4,
      low: 3,
      medium: 0,
      unknown: 1,
    },
  },
  {
    id: 'gid://gitlab/Project/2',
    name: 'Gitlab Shell',
    nameWithNamespace: 'Gitlab Org / Gitlab Shell',
    securityDashboardPath: '/gitlab-org/gitlab-shell/-/security/dashboard',
    fullPath: 'gitlab-org/gitlab-shell',
    avatarUrl: null,
    path: 'gitlab-shell',
    vulnerabilitySeveritiesCount: {
      critical: 0,
      high: 2,
      info: 2,
      low: 1,
      medium: 1,
      unknown: 2,
    },
  },
  {
    id: 'gid://gitlab/Project/4',
    name: 'Gitlab Perfectly Secure',
    nameWithNamespace: 'Gitlab Org / Perfectly Secure',
    securityDashboardPath: '/gitlab-org/gitlab-perfectly-secure/-/security/dashboard',
    fullPath: 'gitlab-org/gitlab-perfectly-secure',
    avatarUrl: null,
    path: 'gitlab-perfectly-secure',
    vulnerabilitySeveritiesCount: {
      critical: 0,
      high: 0,
      info: 0,
      low: 0,
      medium: 0,
      unknown: 0,
    },
  },
  {
    id: 'gid://gitlab/Project/5',
    name: 'Gitlab Perfectly Secure 2 ',
    nameWithNamespace: 'Gitlab Org / Perfectly Secure 2',
    securityDashboardPath: '/gitlab-org/gitlab-perfectly-secure-2/-/security/dashboard',
    fullPath: 'gitlab-org/gitlab-perfectly-secure-2',
    avatarUrl: null,
    path: 'gitlab-perfectly-secure-2',
    vulnerabilitySeveritiesCount: {
      critical: 0,
      high: 0,
      info: 0,
      low: 0,
      medium: 0,
      unknown: 0,
    },
  },
];

const projectsMemoized = mockProjectsWithSeverityCounts();
const vulnerabilityGrades = [
  {
    grade: 'F',
    projects: {
      nodes: [projectsMemoized[0]],
    },
  },
  {
    grade: 'D',
    projects: {
      nodes: [projectsMemoized[1]],
    },
  },
  {
    grade: 'C',
    projects: {
      nodes: [projectsMemoized[0], projectsMemoized[1]],
    },
  },
  {
    grade: 'B',
    projects: {
      nodes: [projectsMemoized[1]],
    },
  },
  {
    grade: 'A',
    projects: {
      nodes: [projectsMemoized[2], projectsMemoized[3]],
    },
  },
];

export const mockGroupVulnerabilityGrades = () => ({
  data: {
    group: {
      vulnerabilityGrades,
    },
  },
});

export const mockInstanceVulnerabilityGrades = () => ({
  data: {
    instanceSecurityDashboard: {
      vulnerabilityGrades,
    },
  },
});

export const mockProjectSecurityChartsWithoutData = () => ({
  data: {
    project: {
      vulnerabilitiesCountByDay: {
        edges: [],
      },
    },
  },
});

export const mockProjectSecurityChartsWithData = () => ({
  data: {
    project: {
      vulnerabilitiesCountByDay: {
        nodes: [
          {
            date: '2020-07-22',
            critical: 4,
            high: 3,
            info: 2,
            low: 10,
            medium: 2,
            unknown: 1,
          },
          {
            date: '2020-07-23',
            critical: 2,
            high: 3,
            info: 2,
            low: 10,
            medium: 2,
            unknown: 1,
          },
          {
            date: '2020-07-24',
            critical: 2,
            high: 3,
            info: 2,
            low: 10,
            medium: 2,
            unknown: 1,
          },
          {
            date: '2020-07-25',
            critical: 2,
            high: 3,
            info: 2,
            low: 10,
            medium: 2,
            unknown: 1,
          },
          {
            date: '2020-07-26',
            critical: 2,
            high: 3,
            info: 2,
            low: 10,
            medium: 2,
            unknown: 1,
          },
          {
            date: '2020-07-27',
            critical: 2,
            high: 3,
            info: 2,
            low: 10,
            medium: 2,
            unknown: 1,
          },
        ],
      },
    },
  },
});

export const mockVulnerableProjectsInstance = () => ({
  data: {
    instanceSecurityDashboard: {
      projects: {
        nodes: [
          {
            id: 'gid://gitlab/Project/2',
            name: 'Gitlab Shell',
          },
        ],
      },
    },
  },
});

export const mockVulnerableProjectsGroup = () => ({
  data: {
    group: {
      projects: {
        nodes: [
          {
            id: 'gid://gitlab/Project/2',
            name: 'Gitlab Shell',
          },
        ],
      },
    },
  },
});

export const mockVulnerabilitySeveritiesGraphQLResponse = ({ dashboardType }) => ({
  data: {
    [dashboardType]: {
      vulnerabilitySeveritiesCount: {
        __typename: 'VulnerabilitySeveritiesCount',
        critical: 0,
        high: 0,
        info: 0,
        low: 0,
        medium: 4,
        unknown: 2,
      },
    },
    __typename: { project: 'Project', instance: 'InstanceSecurityDashboard', group: 'Group' }[
      dashboardType
    ],
  },
});
