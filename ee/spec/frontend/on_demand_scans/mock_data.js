export const scannerProfiles = [
  {
    id: 'gid://gitlab/DastScannerProfile/1',
    profileName: 'Scanner profile #1',
    spiderTimeout: 5,
    targetTimeout: 10,
  },
  {
    id: 'gid://gitlab/DastScannerProfile/2',
    profileName: 'Scanner profile #2',
    spiderTimeout: 20,
    targetTimeout: 150,
  },
];

export const siteProfiles = [
  {
    id: 'gid://gitlab/DastSiteProfile/1',
    profileName: 'Site profile #1',
    targetUrl: 'https://foo.com',
  },
  {
    id: 'gid://gitlab/DastSiteProfile/2',
    profileName: 'Site profile #2',
    targetUrl: 'https://bar.com',
  },
];
