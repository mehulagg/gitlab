export const scannerProfiles = [
  {
    id: 'gid://gitlab/DastScannerProfile/1',
    profileName: 'Scanner profile #1',
    spiderTimeout: 5,
    targetTimeout: 10,
    scanType: 'PASSIVE',
    useAjaxSpider: false,
    showDebugMessages: false,
    editPath: '/scanner_profile/edit/1',
  },
  {
    id: 'gid://gitlab/DastScannerProfile/2',
    profileName: 'Scanner profile #2',
    spiderTimeout: 20,
    targetTimeout: 150,
    scanType: 'ACTIVE',
    useAjaxSpider: true,
    showDebugMessages: true,
    editPath: '/scanner_profile/edit/2',
  },
];

export const siteProfiles = [
  {
    id: 'gid://gitlab/DastSiteProfile/1',
    profileName: 'Site profile #1',
    targetUrl: 'https://foo.com',
    normalizedTargetUrl: 'https://foo.com:443',
    editPath: '/site_profiles/edit/1',
    validationStatus: 'PENDING_VALIDATION',
  },
  {
    id: 'gid://gitlab/DastSiteProfile/2',
    profileName: 'Site profile #2',
    targetUrl: 'https://bar.com',
    normalizedTargetUrl: 'https://bar.com:443',
    editPath: '/site_profiles/edit/2',
    validationStatus: 'PASSED_VALIDATION',
  },
];
