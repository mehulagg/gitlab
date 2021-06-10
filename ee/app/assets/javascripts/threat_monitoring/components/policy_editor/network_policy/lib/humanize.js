import { sprintf, __, s__ } from '~/locale';
import {
  EndpointMatchModeAny,
  RuleDirectionInbound,
  PortMatchModeAny,
  RuleTypeEntity,
  RuleTypeCIDR,
  RuleTypeFQDN,
} from './constants';
import { portSelectors, labelSelector, splitItems } from './utils';

const strongArgs = { strongOpen: '<strong>', strongClose: '</strong>' };

/*
 Return humanizied description for a port matcher of a rule.
*/
function humanizeNetworkPolicyRulePorts(rule) {
  const { portMatchMode } = rule;

  if (portMatchMode === PortMatchModeAny)
    return sprintf(s__('NetworkPolicies|%{strongOpen}any%{strongClose} port'), strongArgs, false);

  const portList = portSelectors(rule);
  const ports = portList.map(({ port, protocol }) => `${port}/${protocol}`).join(', ');
  return sprintf(
    s__('NetworkPolicies|ports %{ports}'),
    {
      ports: `<strong>${ports}</strong>`,
    },
    false,
  );
}

/*
 Return humanizied description of an endpoint rule.
*/
function humanizeNetworkPolicyRuleEndpoint({ matchLabels }) {
  const matchSelector = labelSelector(matchLabels);
  const labels = Object.keys(matchSelector)
    .map((key) => `${key}: ${matchSelector[key]}`)
    .join(', ');
  return labels.length === 0
    ? sprintf(s__('NetworkPolicies|%{strongOpen}all%{strongClose} pods'), strongArgs, false)
    : sprintf(
        s__('NetworkPolicies|pods %{pods}'),
        {
          pods: `<strong>[${labels}]</strong>`,
        },
        false,
      );
}

/*
 Return humanizied description of an entity rule.
*/
function humanizeNetworkPolicyRuleEntity({ entities }) {
  const entitiesList = entities.length === 0 ? s__('NetworkPolicies|nowhere') : entities.join(', ');
  return `<strong>${entitiesList}</strong>`;
}

/*
 Return humanizied description of a cidr rule.
*/
function humanizeNetworkPolicyRuleCIDR({ cidr }) {
  const cidrList = splitItems(cidr);
  const cidrs =
    cidrList.length === 0 ? s__('NetworkPolicies|all IP addresses') : cidrList.join(', ');
  return `<strong>${cidrs}</strong>`;
}

/*
 Return humanizied description of a fqdn rule.
*/
function humanizeNetworkPolicyRuleFQDN({ fqdn }) {
  const fqdnList = splitItems(fqdn);
  const fqdns = fqdnList.length === 0 ? s__('NetworkPolicies|all DNS names') : fqdnList.join(', ');
  return `<strong>${fqdns}</strong>`;
}

/*
 Return humanizied description of a rule.
*/
function humanizeNetworkPolicyRule(rule) {
  const { ruleType } = rule;

  switch (ruleType) {
    case RuleTypeEntity:
      return humanizeNetworkPolicyRuleEntity(rule);
    case RuleTypeCIDR:
      return humanizeNetworkPolicyRuleCIDR(rule);
    case RuleTypeFQDN:
      return humanizeNetworkPolicyRuleFQDN(rule);
    default:
      return humanizeNetworkPolicyRuleEndpoint(rule);
  }
}

/*
 Return humanizied description of an endpoint matcher of a policy.
*/
function humanizeEndpointSelector({ endpointMatchMode, endpointLabels }) {
  if (endpointMatchMode === EndpointMatchModeAny)
    return sprintf(s__('NetworkPolicies|%{strongOpen}all%{strongClose} pods'), strongArgs, false);

  const selector = labelSelector(endpointLabels);
  const pods = Object.keys(selector)
    .map((key) => `${key}: ${selector[key]}`)
    .join(', ');
  return sprintf(
    s__('NetworkPolicies|pods %{pods}'),
    {
      pods: `<strong>[${pods}]</strong>`,
    },
    false,
  );
}

/*
 Return humanizied description of a provided network policy.
*/
export default function humanizeNetworkPolicy(policy) {
  const { rules } = policy;
  if (rules.length === 0) return s__('NetworkPolicies|Deny all traffic');

  const selector = humanizeEndpointSelector(policy);

  const humanizedRules = rules.map((rule) => {
    const { direction } = rule;
    const template =
      direction === RuleDirectionInbound
        ? s__(
            'NetworkPolicies|Allow all inbound traffic to %{selector} from %{ruleSelector} on %{ports}',
          )
        : s__(
            'NetworkPolicies|Allow all outbound traffic from %{selector} to %{ruleSelector} on %{ports}',
          );
    const ruleSelector = humanizeNetworkPolicyRule(rule);
    const ports = humanizeNetworkPolicyRulePorts(rule);
    return sprintf(template, { selector, ruleSelector, ports }, false);
  });

  return humanizedRules.join(`<br><br>${__('and').toLocaleUpperCase()}<br><br>`);
}
