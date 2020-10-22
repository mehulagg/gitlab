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
    state: 'DISMISSED',
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
    state: 'DETECTED',
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
    state: 'DETECTED',
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
    state: 'DETECTED',
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
    state: 'DISMISSED',
    location: {},
    project: {
      nameWithNamespace: 'Administrator / Security reports',
    },
    scanner: {},
  },
];

export const vulnerabilities = generateVulnerabilities();
