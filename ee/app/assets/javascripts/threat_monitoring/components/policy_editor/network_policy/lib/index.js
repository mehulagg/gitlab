import { EndpointMatchModeAny } from './constants';

export * from './constants';
export { default as fromYaml } from './from_yaml';
export { default as humanizeNetworkPolicy } from './humanize';
export { buildRule } from './rules';
export { default as toYaml } from './to_yaml';

export const DEFAULT_NETWORK_POLICY = {
  name: '',
  description: '',
  isEnabled: false,
  endpointMatchMode: EndpointMatchModeAny,
  endpointLabels: '',
  annotations: '',
  labels: '',
};
