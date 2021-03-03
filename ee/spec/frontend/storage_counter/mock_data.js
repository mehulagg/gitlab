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
    actualRepositorySizeLimit: 100000,
    totalCalculatedUsedStorage: 41943,
    totalCalculatedStorageLimit: 41943000,
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
      storageSize: 99000,
      repositorySize: 0,
      lfsObjectsSize: 0,
      buildArtifactsSize: 1272375,
      packagesSize: 0,
    },
    actualRepositorySizeLimit: 100000,
    totalCalculatedUsedStorage: 89000,
    totalCalculatedStorageLimit: 99430,
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
      storageSize: 12933460,
      repositorySize: 209710,
      lfsObjectsSize: 209720,
      buildArtifactsSize: 1272375,
      packagesSize: 0,
    },
    actualRepositorySizeLimit: 100000,
    totalCalculatedUsedStorage: 13143170,
    totalCalculatedStorageLimit: 12143170,
  },
];

export const namespaceData = {
  totalUsage: 'N/A',
  limit: 10000000,
  projects: { data: projects },
};

export const withRootStorageStatistics = {
  projects,
  limit: 10000000,
  totalUsage: 129334601,
  containsLockedProjects: true,
  repositorySizeExcessProjectCount: 1,
  totalRepositorySizeExcess: 2321,
  totalRepositorySize: 1002321,
  additionalPurchasedStorageSize: 321,
  actualRepositorySizeLimit: 1002321,
  rootStorageStatistics: {
    storageSize: 129334601,
    repositorySize: 46012030,
    lfsObjectsSize: 4329334601203,
    buildArtifactsSize: 1272375,
    packagesSize: 123123120,
    wikiSize: 1000,
    snippetsSize: 10000,
  },
};

export const mockGetStorageCounterGraphQLResponse = {
  nodes: projects.map((node) => node),
};
