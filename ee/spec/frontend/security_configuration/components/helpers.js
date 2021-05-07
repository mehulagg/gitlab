import { scanners } from '~/security_configuration/components/constants';

export const generateFeatures = (n, overrides = {}) => {
  return [...Array(n).keys()].map((i) => ({
    type: scanners[i % scanners.length].type,
    configuration_path: i % 2 ? `configuration_path-${i}` : null,
    configured: i % 2 === 0,
    status: i % 2 === 0 ? 'Enabled' : 'Not enabled',
    ...overrides,
  }));
};
