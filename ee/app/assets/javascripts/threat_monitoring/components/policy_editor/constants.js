import { s__, __ } from '~/locale';

export const EditorModeRule = 'rule';
export const EditorModeYAML = 'yaml';

export const PARSING_ERROR_MESSAGE = s__(
  'NetworkPolicies|Rule mode is unavailable for this policy. In some cases, we cannot parse the YAML file back into the rules editor.',
);

export const EDITOR_MODES = [
  { value: EditorModeRule, text: s__('NetworkPolicies|Rule mode') },
  { value: EditorModeYAML, text: s__('NetworkPolicies|.yaml mode') },
];

export const POLICY_TYPES = {
  networkPolicy: {
    value: 'networkPolicy',
    text: s__('NetworkPolicies|Network Policy'),
    component: 'network-policy-editor',
    shouldShowEnvironmentPicker: true,
  },
  scanExecution: {
    value: 'scanExecution',
    text: s__('NetworkPolicies|Scan Execution'),
    component: 'scan-execution-policy-editor',
    shouldShowMergeRequestButton: true,
  },
};

export const DELETE_MODAL_CONFIG = {
  id: 'delete-modal',
  secondary: {
    text: s__('NetworkPolicies|Delete policy'),
    attributes: { variant: 'danger' },
  },
  cancel: {
    text: __('Cancel'),
  },
};
