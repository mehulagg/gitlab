const DEFAULT_SETTINGS = {
  prefix: 'license-approvals',
};

export default (settings = {}) => ({
  settings: {
    ...DEFAULT_SETTINGS,
    ...settings,
  },
});
