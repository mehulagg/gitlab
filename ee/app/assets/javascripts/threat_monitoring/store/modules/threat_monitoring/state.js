import { defaultTimeRange } from '~/vue_shared/constants';

export default () => ({
  environmentsEndpoint: '',
  environments: [],
  isLoadingEnvironments: false,
  errorLoadingEnvironments: false,
  currentEnvironmentId: -1,
  currentTimeWindow: defaultTimeRange.name,
  allEnvironments: false,
});
