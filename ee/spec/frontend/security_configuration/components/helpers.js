export const generateFeatures = (n, overrides = {}) => {
  return [...Array(n).keys()].map(i => ({
    type: `scan-type-${i}`,
    name: `name-feature-${i}`,
    description: `description-feature-${i}`,
    link: `link-feature-${i}`,
    configuration_path: i % 2 ? `configuration_path-${i}` : null,
    configured: i % 2 === 0,
    status: i % 2 === 0 ? 'Enabled' : 'Not enabled',
    ...overrides,
  }));
};
