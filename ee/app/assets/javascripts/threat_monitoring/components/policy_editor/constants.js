import { s__ } from '~/locale';

export const EditorModeRule = 'rule';
export const EditorModeYAML = 'yaml';

export const RuleTypeNetwork = 'network';

export const RuleActionTypeAllow = 'allow';

export const RuleDirectionInbound = 'ingress';
export const RuleDirectionOutbound = 'egress';

export const EndpointMatchModeAny = 'any';
export const EndpointMatchModeLabel = 'label';

export const RuleTypeEndpoint = 'NetworkPolicyRuleEndpoint';
export const RuleTypeEntity = 'NetworkPolicyRuleEntity';
export const RuleTypeCIDR = 'NetworkPolicyRuleCIDR';
export const RuleTypeFQDN = 'NetworkPolicyRuleFQDN';

export const EntityTypes = {
  ALL: 'all',
  HOST: 'host',
  REMOTE_NODE: 'remote-node',
  CLUSTER: 'cluster',
  INIT: 'init',
  HEALTH: 'health',
  UNMANAGED: 'unmanaged',
  WORLD: 'world',
};

export const PortMatchModeAny = 'any';
export const PortMatchModePortProtocol = 'port/protocol';

export const DisabledByLabel = 'network-policy.gitlab.com/disabled_by';

export const CiliumNetworkPolicyKind = 'CiliumNetworkPolicy';

export const ProjectIdLabel = 'app.gitlab.com/proj';

export const PARSING_ERROR_MESSAGE = s__(
  'NetworkPolicies|Rule mode is unavailable for this policy. In some cases, we cannot parse the YAML file back into the rules editor.',
);
