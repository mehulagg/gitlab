import { INVALID_CURRENT_ENVIRONMENT_NAME } from '../../../constants';

const getEnvironmentById = ({ environments, id }) =>
  environments.find((environment) => environment.id === id);

export const currentEnvironmentName = ({ currentEnvironmentId, environments }) => {
  const environment = getEnvironmentById({ environments, id: currentEnvironmentId });
  return environment ? environment.name : INVALID_CURRENT_ENVIRONMENT_NAME;
};

export const currentEnvironmentGid = ({ currentEnvironmentId, environments }) => {
  const environment = getEnvironmentById({ environments, id: currentEnvironmentId });
  return environment?.global_id;
};

export const canChangeEnvironment = ({
  isLoadingEnvironments,
  isLoadingNetworkPolicyStatistics,
  environments,
}) => !isLoadingEnvironments && !isLoadingNetworkPolicyStatistics && environments.length > 0;
