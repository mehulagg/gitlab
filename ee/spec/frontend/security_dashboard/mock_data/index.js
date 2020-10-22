export const mockProjects = () => [
  {
    id: 'gid://gitlab/Project/1',
    name: 'Gitlab Test',
    nameWithNamespace: 'Gitlab Org / Gitlab Test',
    securityDashboardPath: '/gitlab-org/gitlab-test/-/security/dashboard',
    fullPath: 'gitlab-org/gitlab-test',
    avatarUrl: null,
    path: 'gitlab-test',
  },
  {
    id: 'gid://gitlab/Project/2',
    name: 'Gitlab Shell',
    nameWithNamespace: 'Gitlab Org / Gitlab Shell',
    securityDashboardPath: '/gitlab-org/gitlab-shell/-/security/dashboard',
    fullPath: 'gitlab-org/gitlab-shell',
    avatarUrl: null,
    path: 'gitlab-shell',
  },
  {
    id: 'gid://gitlab/Project/4',
    name: 'Gitlab Perfectly Secure',
    nameWithNamespace: 'Gitlab Org / Perfectly Secure',
    securityDashboardPath: '/gitlab-org/gitlab-perfectly-secure/-/security/dashboard',
    fullPath: 'gitlab-org/gitlab-perfectly-secure',
    avatarUrl: null,
    path: 'gitlab-perfectly-secure',
  },
  {
    id: 'gid://gitlab/Project/5',
    name: 'Gitlab Perfectly Secure 2 ',
    nameWithNamespace: 'Gitlab Org / Perfectly Secure 2',
    securityDashboardPath: '/gitlab-org/gitlab-perfectly-secure-2/-/security/dashboard',
    fullPath: 'gitlab-org/gitlab-perfectly-secure-2',
    avatarUrl: null,
    path: 'gitlab-perfectly-secure-2',
  },
];

const projectsMemoized = mockProjects();

export const mockGroupVulnerabilityGrades = () => ({
  data: {
    group: {
      vulnerabilityGrades: [
        {
          grade: 'F',
          projects: {
            nodes: [
              {
                vulnerabilitySeveritiesCount: {
                  critical: 2,
                  high: 0,
                  info: 4,
                  low: 3,
                  medium: 0,
                  unknown: 1,
                },
                ...projectsMemoized[0],
              },
            ],
          },
        },
        {
          grade: 'D',
          projects: {
            nodes: [
              {
                vulnerabilitySeveritiesCount: {
                  critical: 2,
                  high: 2,
                  info: 2,
                  low: 1,
                  medium: 1,
                  unknown: 2,
                },
                ...projectsMemoized[1],
              },
            ],
          },
        },
        {
          grade: 'C',
          projects: {
            nodes: [
              {
                vulnerabilitySeveritiesCount: {
                  critical: 2,
                  high: 2,
                  info: 2,
                  low: 1,
                  medium: 1,
                  unknown: 2,
                },
                ...projectsMemoized[0],
              },
              {
                vulnerabilitySeveritiesCount: {
                  critical: 2,
                  high: 0,
                  info: 4,
                  low: 3,
                  medium: 3,
                  unknown: 1,
                },
                ...projectsMemoized[1],
              },
            ],
          },
        },
        {
          grade: 'B',
          projects: {
            nodes: [
              {
                vulnerabilitySeveritiesCount: {
                  critical: 2,
                  high: 0,
                  info: 4,
                  low: 3,
                  medium: 0,
                  unknown: 1,
                },
                ...projectsMemoized[0],
              },
            ],
          },
        },
        {
          grade: 'A',
          projects: {
            nodes: [
              {
                vulnerabilitySeveritiesCount: {
                  critical: 0,
                  high: 0,
                  info: 0,
                  low: 0,
                  medium: 0,
                  unknown: 0,
                },
                ...projectsMemoized[2],
              },
              {
                vulnerabilitySeveritiesCount: {
                  critical: 0,
                  high: 0,
                  info: 0,
                  low: 0,
                  medium: 0,
                  unknown: 0,
                },
                ...projectsMemoized[3],
              },
            ],
          },
        },
      ],
    },
  },
});

export const mockInstanceVulnerabilityGrades = () => ({
  data: {
    instanceSecurityDashboard: {
      vulnerabilityGrades: [
        {
          grade: 'F',
          projects: {
            nodes: [
              {
                vulnerabilitySeveritiesCount: {
                  critical: 2,
                  high: 0,
                  info: 4,
                  low: 3,
                  medium: 0,
                  unknown: 1,
                },
                ...projectsMemoized[0],
              },
            ],
          },
        },
        {
          grade: 'D',
          projects: {
            nodes: [
              {
                vulnerabilitySeveritiesCount: {
                  critical: 0,
                  high: 2,
                  info: 2,
                  low: 1,
                  medium: 1,
                  unknown: 2,
                },
                ...projectsMemoized[1],
              },
            ],
          },
        },
        {
          grade: 'C',
          projects: {
            nodes: [
              {
                vulnerabilitySeveritiesCount: {
                  critical: 2,
                  high: 2,
                  info: 2,
                  low: 1,
                  medium: 1,
                  unknown: 2,
                },
                ...projectsMemoized[0],
              },
              {
                vulnerabilitySeveritiesCount: {
                  critical: 2,
                  high: 0,
                  info: 4,
                  low: 3,
                  medium: 3,
                  unknown: 1,
                },
                ...projectsMemoized[1],
              },
            ],
          },
        },
        {
          grade: 'B',
          projects: {
            nodes: [
              {
                vulnerabilitySeveritiesCount: {
                  critical: 2,
                  high: 0,
                  info: 4,
                  low: 3,
                  medium: 0,
                  unknown: 1,
                },
                ...projectsMemoized[1],
              },
            ],
          },
        },
        {
          grade: 'A',
          projects: {
            nodes: [
              {
                vulnerabilitySeveritiesCount: {
                  critical: 0,
                  high: 0,
                  info: 0,
                  low: 0,
                  medium: 0,
                  unknown: 0,
                },
                ...projectsMemoized[2],
              },
              {
                vulnerabilitySeveritiesCount: {
                  critical: 0,
                  high: 0,
                  info: 0,
                  low: 0,
                  medium: 0,
                  unknown: 0,
                },
                ...projectsMemoized[3],
              },
            ],
          },
        },
      ],
    },
  },
});
