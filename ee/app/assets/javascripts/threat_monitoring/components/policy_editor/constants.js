import { s__ } from '~/locale';

export const EditorModeRule = 'rule';
export const EditorModeYAML = 'yaml';

export const PARSING_ERROR_MESSAGE = s__(
  'NetworkPolicies|Rule mode is unavailable for this policy. In some cases, we cannot parse the YAML file back into the rules editor.',
);

export const POLICY_TYPES = {
  networkPolicy: {
    value: 'networkPolicy',
    text: s__('NetworkPolicies|Network Policy'),
    component: 'network-policy-editor',
  },
};
