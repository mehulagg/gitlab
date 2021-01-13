import { PREDEFINED_NETWORK_POLICIES } from 'ee/threat_monitoring/constants';

export const policiesWithDefaults = ({ policies }) => {
  // Predefined policies that were enabled by users will be present in
  // the list of policies we received from the backend. We want to
  // filter out enabled predefined policies and only append the ones
  // that are not present in a cluster.
  const predefined = PREDEFINED_NETWORK_POLICIES.filter(
    ({ name }) => !policies.some((policy) => name === policy.name),
  );
  return [...policies, ...predefined];
};
