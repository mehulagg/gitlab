export const projects = [
  {
    id: '24',
    fullPath: 'h5bp/dummy-project',
    nameWithNamespace: 'H5bp / dummy project',
    avatarUrl: null,
    webUrl: 'http://localhost:3001/h5bp/dummy-project',
    name: 'dummy project',
    statistics: {
      commitCount: 1,
      storageSize: 41943,
      repositorySize: 41943,
      lfsObjectsSize: 0,
      buildArtifactsSize: 0,
      packagesSize: 0,
    },
  },
  {
    id: '8',
    fullPath: 'h5bp/html5-boilerplate',
    nameWithNamespace: 'H5bp / Html5 Boilerplate',
    avatarUrl: null,
    webUrl: 'http://localhost:3001/h5bp/html5-boilerplate',
    name: 'Html5 Boilerplate',
    statistics: {
      commitCount: 0,
      storageSize: 1293346,
      repositorySize: 0,
      lfsObjectsSize: 0,
      buildArtifactsSize: 1272375,
      packagesSize: 0,
    },
  },
  {
    id: '80',
    fullPath: 'twit/twitter',
    nameWithNamespace: 'Twitter',
    avatarUrl: null,
    webUrl: 'http://localhost:3001/twit/twitter',
    name: 'Twitter',
    statistics: {
      commitCount: 0,
      storageSize: 129334601203,
      repositorySize: 0,
      lfsObjectsSize: 0,
      buildArtifactsSize: 1272375,
      packagesSize: 0,
    },
  },
];

export const namespaceData = {
  totalUsage: 'N/A',
  limit: 10000000,
  projects,
};

export const withRootStorageStatistics = { ...projects, totalUsage: 3261070 };
