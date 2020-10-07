export const generateVulnerabilities = () => [
  {
    id: 'id_0',
    detectedAt: '2020-07-29T15:36:54Z',
    identifiers: [
      {
        externalType: 'cve',
        name: 'CVE-2018-1234',
      },
      {
        externalType: 'gemnasium',
        name: 'Gemnasium-2018-1234',
      },
    ],
    title: 'Vulnerability 0',
    severity: 'critical',
    state: 'dismissed',
    reportType: 'SAST',
    resolvedOnDefaultBranch: true,
    location: {
      image:
        'registry.gitlab.com/groulot/container-scanning-test/master:5f21de6956aee99ddb68ae49498662d9872f50ff',
    },
    project: {
      nameWithNamespace: 'Administrator / Security reports',
    },
    scanner: {
      vendor: 'GitLab',
    },
    issueLinks: {
      nodes: [{ issue: { iid: 15 } }],
    },
  },
  {
    id: 'id_1',
    detectedAt: '2020-07-22T19:31:24Z',
    identifiers: [
      {
        externalType: 'gemnasium',
        name: 'Gemnasium-2018-1234',
      },
    ],
    title: 'Vulnerability 1',
    severity: 'high',
    state: 'opened',
    reportType: 'DEPENDENCY_SCANNING',
    location: {
      file: 'src/main/java/com/gitlab/security_products/tests/App.java',
      startLine: '1337',
    },
    project: {
      nameWithNamespace: 'Administrator / Vulnerability reports',
    },
    scanner: {
      vendor: 'GitLab',
    },
  },
  {
    id: 'id_2',
    detectedAt: '2020-08-22T20:00:12Z',
    identifiers: [],
    title: 'Vulnerability 2',
    severity: 'high',
    state: 'opened',
    reportType: 'CUSTOM_SCANNER_WITHOUT_TRANSLATION',
    location: {
      file: 'src/main/java/com/gitlab/security_products/tests/App.java',
    },
    project: {
      nameWithNamespace: 'Mixed Vulnerabilities / Dependency List Test 01',
    },
    scanner: {
      vendor: 'My Custom Scanner',
    },
  },
  {
    id: 'id_3',
    title: 'Vulnerability 3',
    severity: 'high',
    state: 'opened',
    location: {
      file: 'yarn.lock',
    },
    project: {
      nameWithNamespace: 'Mixed Vulnerabilities / Rails App',
    },
    scanner: {},
  },
  {
    id: 'id_4',
    title: 'Vulnerability 4',
    severity: 'critical',
    state: 'dismissed',
    location: {},
    project: {
      nameWithNamespace: 'Administrator / Security reports',
    },
    scanner: {},
  },
];

export const vulnerabilities = generateVulnerabilities();

export const generateProjectsWithSeverityCounts = () => [
  {
    id: 'gid://gitlab/Project/1',
    name: 'Gitlab Test 1',
    nameWithNamespace: 'Gitlab Org / Gitlab Test 1',
    fullPath: 'gitlab-org/gitlab-test-1',
    securityDashboardPath: '/gitlab-org/gitlab-test-1/-/security/dashboard',
    vulnerabilitySeveritiesCount: {
      critical: 2,
      high: 0,
      info: 0,
      low: 0,
      medium: 0,
      unknown: 0,
    },
  },
  {
    id: 'gid://gitlab/Project/2',
    name: 'Gitlab Test 2',
    nameWithNamespace: 'Gitlab Org / Gitlab Test 2',
    fullPath: 'gitlab-org/gitlab-test-2',
    securityDashboardPath: '/gitlab-org/gitlab-test-2/-/security/dashboard',
    vulnerabilitySeveritiesCount: {
      critical: 0,
      high: 1,
      info: 0,
      low: 0,
      medium: 0,
      unknown: 0,
    },
  },
  {
    id: 'gid://gitlab/Project/3',
    name: 'Gitlab Test 3',
    nameWithNamespace: 'Gitlab Org / Gitlab Test 3',
    fullPath: 'gitlab-org/gitlab-test-3',
    securityDashboardPath: '/gitlab-org/gitlab-test-3/-/security/dashboard',
    vulnerabilitySeveritiesCount: {
      critical: 0,
      high: 0,
      info: 0,
      low: 0,
      medium: 5,
      unknown: 0,
    },
  },
  {
    id: 'gid://gitlab/Project/4',
    name: 'Gitlab Test 4',
    nameWithNamespace: 'Gitlab Org / Gitlab Test 4',
    fullPath: 'gitlab-org/gitlab-test-4',
    securityDashboardPath: '/gitlab-org/gitlab-test-4/-/security/dashboard',
    vulnerabilitySeveritiesCount: {
      critical: 0,
      high: 0,
      info: 0,
      low: 0,
      medium: 4,
      unknown: 0,
    },
  },
  {
    id: 'gid://gitlab/Project/5',
    name: 'Gitlab Test 5',
    nameWithNamespace: 'Gitlab Org / Gitlab Test 5',
    fullPath: 'gitlab-org/gitlab-test-5',
    securityDashboardPath: '/gitlab-org/gitlab-test-5/-/security/dashboard',
    vulnerabilitySeveritiesCount: {
      critical: 0,
      high: 0,
      info: 0,
      low: 2,
      medium: 0,
      unknown: 0,
    },
  },
  {
    id: 'gid://gitlab/Project/6',
    name: 'Gitlab Test 6',
    nameWithNamespace: 'Gitlab Org / Gitlab Test 6',
    fullPath: 'gitlab-org/gitlab-test-6',
    securityDashboardPath: '/gitlab-org/gitlab-test-6/-/security/dashboard',
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
    id: 'gid://gitlab/Project/7',
    name: 'Gitlab Test 7',
    nameWithNamespace: 'Gitlab Org / Subgroup / Gitlab Test 7',
    fullPath: 'gitlab-org/subgroup/gitlab-test-7',
    securityDashboardPath: '/gitlab-org/subgroup/gitlab-test-7/-/security/dashboard',
    vulnerabilitySeveritiesCount: {
      critical: 0,
      high: 0,
      info: 2,
      low: 0,
      medium: 0,
      unknown: 0,
    },
  },
];

export const projectsWithSeverityCounts = generateProjectsWithSeverityCounts();
