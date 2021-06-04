import { s__ } from '~/locale';
import { buildRule, EndpointMatchModeAny } from './lib';

export const EditorModeRule = 'rule';
export const EditorModeYAML = 'yaml';

export const PARSING_ERROR_MESSAGE = s__(
  'NetworkPolicies|Rule mode is unavailable for this policy. In some cases, we cannot parse the YAML file back into the rules editor.',
);

export const DEFAULT_NETWORK_POLICY = {
  name: '',
  description: '',
  isEnabled: false,
  endpointMatchMode: EndpointMatchModeAny,
  endpointLabels: '',
  rules: [buildRule()],
  annotations: '',
  labels: '',
};
