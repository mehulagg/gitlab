export const siteProfiles = [
  {
    id: 'gid://gitlab/DastSiteProfile/0',
    profileName: 'Profile 0',
    targetUrl: 'http://example-1.com',
    editPath: '/0/edit',
    validationStatus: 'NONE',
  },
  {
    id: 'gid://gitlab/DastSiteProfile/1',
    profileName: 'Profile 1',
    targetUrl: 'http://example-1.com',
    editPath: '/1/edit',
    validationStatus: 'PENDING_VALIDATION',
  },
  {
    id: 'gid://gitlab/DastSiteProfile/2',
    profileName: 'Profile 2',
    targetUrl: 'http://example-2.com',
    editPath: '/2/edit',
    validationStatus: 'INPROGRESS_VALIDATION',
  },
  {
    id: 'gid://gitlab/DastSiteProfile/3',
    profileName: 'Profile 3',
    targetUrl: 'http://example-2.com',
    editPath: '/3/edit',
    validationStatus: 'PASSED_VALIDATION',
  },
  {
    id: 'gid://gitlab/DastSiteProfile/4',
    profileName: 'Profile 4',
    targetUrl: 'http://example-3.com',
    editPath: '/3/edit',
    validationStatus: 'FAILED_VALIDATION',
  },
];

export const scannerProfiles = [
  {
    id: 'gid://gitlab/DastScannerProfile/1',
    profileName: 'Scanner profile #1',
    spiderTimeout: 5,
    targetTimeout: 10,
    scanType: 'PASSIVE',
    useAjaxSpider: false,
    showDebugMessages: false,
  },
  {
    id: 'gid://gitlab/DastScannerProfile/2',
    profileName: 'Scanner profile #2',
    spiderTimeout: 20,
    targetTimeout: 150,
    scanType: 'ACTIVE',
    useAjaxSpider: true,
    showDebugMessages: true,
  },
];
