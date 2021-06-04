import {
  RuleTypeEndpoint,
  RuleTypeEntity,
  RuleTypeCIDR,
  RuleTypeFQDN,
  RuleDirectionInbound,
  PortMatchModeAny,
} from './constants';
import { portSelectors, labelSelector, splitItems } from './utils';

/*
 Return kubernetes specification object that is shared by all rule types.
*/
function commonSpec(rule) {
  const spec = {};
  const ports = portSelectors(rule);
  if (Object.keys(ports).length > 0) spec.toPorts = [{ ports }];
  return spec;
}

/*
 Return kubernetes specification object for an endpoint rule.
*/
function ruleEndpointSpec({ direction, matchLabels }) {
  const matchSelector = labelSelector(matchLabels);

  return {
    [direction === RuleDirectionInbound ? 'fromEndpoints' : 'toEndpoints']: [
      {
        matchLabels: matchSelector,
      },
    ],
  };
}

/*
  Return kubernetes specification object for an entity rule.
*/
function ruleEntitySpec({ direction, entities }) {
  if (entities.length === 0) return {};

  return {
    [direction === RuleDirectionInbound ? 'fromEntities' : 'toEntities']: entities,
  };
}

/*
  Return kubernetes specification object for a cidr rule.
*/
function ruleCIDRSpec({ direction, cidr }) {
  const cidrList = splitItems(cidr);
  if (cidrList.length === 0) return {};

  return {
    [direction === RuleDirectionInbound ? 'fromCIDR' : 'toCIDR']: cidrList,
  };
}

/*
  Return kubernetes specification object for a fqdn rule.
*/
function ruleFQDNSpec({ direction, fqdn }) {
  if (direction === RuleDirectionInbound) return {};

  const fqdnList = splitItems(fqdn);
  if (fqdnList.length === 0) return {};

  return {
    toFQDNs: fqdnList.map((item) => ({ matchName: item })),
  };
}

/*
  Construct a new rule object of the given ruleType.
  oldRule: initialize common rule fields using existing rule.
*/
export function buildRule(ruleType = RuleTypeEndpoint, oldRule) {
  const direction = oldRule?.direction || RuleDirectionInbound;
  const portMatchMode = oldRule?.portMatchMode || PortMatchModeAny;
  const ports = oldRule?.ports || '';
  const commons = { ruleType, direction, portMatchMode, ports };

  switch (ruleType) {
    case RuleTypeEntity:
      return { ...commons, entities: [] };
    case RuleTypeCIDR:
      return { ...commons, cidr: '' };
    case RuleTypeFQDN:
      return { ...commons, fqdn: '' };
    default:
      return { ...commons, matchLabels: '' };
  }
}

/*
 Return rule's kubernetes specification object
*/
export function ruleSpec(rule) {
  const commons = commonSpec(rule);
  switch (rule.ruleType) {
    case RuleTypeEntity:
      return { ...commons, ...ruleEntitySpec(rule) };
    case RuleTypeCIDR:
      return { ...commons, ...ruleCIDRSpec(rule) };
    case RuleTypeFQDN:
      return { ...commons, ...ruleFQDNSpec(rule) };
    default:
      return { ...commons, ...ruleEndpointSpec(rule) };
  }
}
