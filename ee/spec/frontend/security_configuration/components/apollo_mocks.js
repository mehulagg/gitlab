const buildConfigureDependencyScanningMock = ({
  successPath = 'testSuccessPath',
  errors = [],
} = {}) => ({
  data: {
    configureDependencyScanning: {
      successPath,
      errors,
      __typename: 'ConfigureDependencyScanningPayload',
    },
  },
});

export const configureDependencyScanningSuccess = buildConfigureDependencyScanningMock();
export const configureDependencyScanningNoSuccessPath = buildConfigureDependencyScanningMock({
  successPath: '',
});
export const configureDependencyScanningError = buildConfigureDependencyScanningMock({
  errors: ['foo'],
});
