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

export const ProjectIdLabel = 'app.gitlab.com/proj';
