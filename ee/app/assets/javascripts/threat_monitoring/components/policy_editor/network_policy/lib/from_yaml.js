import { safeLoad } from 'js-yaml';
import {
  DisabledByLabel,
  EndpointMatchModeAny,
  EndpointMatchModeLabel,
  RuleDirectionInbound,
  RuleDirectionOutbound,
  PortMatchModeAny,
  PortMatchModePortProtocol,
  RuleTypeEndpoint,
  RuleTypeEntity,
  RuleTypeCIDR,
  RuleTypeFQDN,
} from './constants';
import { buildRule } from './rules';

/*
  Convert list of matchLabel selectors used by the endpoint rule to an
  entity rule object expected by the rule builder.

  We expect list of object in format:
  [{ matchLabels: { foo: 'bar' } }, { matchLabels: { bar: 'baz' } }]
  And will return a single rule object:
  { matchLabels: 'foo:bar baz:bar' }
*/
function ruleTypeEndpointFunc(items) {
  const labels = items
    .reduce(
      (acc, { matchLabels }) =>
        acc.concat(Object.keys(matchLabels).map((key) => `${key}:${matchLabels[key]}`)),
      [],
    )
    .join(' ');
  return { matchLabels: labels };
}

function ruleTypeEntityFunc(entities) {
  return { entities };
}

function ruleTypeCIDRFunc(items) {
  const cidr = items.join(' ');
  return { cidr };
}

/*
  Convert list of matchName selectors used by the fqdn rule to a
  fqdn rule object expected by the rule builder.

  We expect list of object in format:
  [{ matchName: 'remote-service.com' }, { matchName: 'another-service.com' }]
  And will return a single rule object:
  { fqdn: 'remote-service.com another-service.com' }
*/
function ruleTypeFQDNFunc(items) {
  const fqdn = items.map(({ matchName }) => matchName).join(' ');
  return { fqdn };
}

const rulesFunc = {
  [RuleTypeEndpoint]: ruleTypeEndpointFunc,
  [RuleTypeEntity]: ruleTypeEntityFunc,
  [RuleTypeCIDR]: ruleTypeCIDRFunc,
  [RuleTypeFQDN]: ruleTypeFQDNFunc,
};

/*
  Parse yaml rule into an object expected by the policy editor.
*/
function parseRule(item, direction) {
  let ruleItem;
  let ruleType;

  if (item.fromEntities || item.toEntities) {
    ruleType = RuleTypeEntity;
    ruleItem = item.fromEntities || item.toEntities;
  } else if (item.fromCIDR || item.toCIDR) {
    ruleType = RuleTypeCIDR;
    ruleItem = item.fromCIDR || item.toCIDR;
  } else if (item.toFQDNs) {
    ruleType = RuleTypeFQDN;
    ruleItem = item.toFQDNs;
  } else {
    ruleItem = item.fromEndpoints || item.toEndpoints || [];
    ruleType = RuleTypeEndpoint;
  }

  let portMatchMode = PortMatchModeAny;
  let portList = [];
  if (item.toPorts?.length > 0) {
    portMatchMode = PortMatchModePortProtocol;
    portList = item.toPorts.reduce(
      (acc, { ports }) =>
        acc.concat(ports.map(({ port, protocol = 'TCP' }) => `${port}/${protocol.toLowerCase()}`)),
      [],
    );
  }

  return {
    ...buildRule(ruleType, {
      direction,
      portMatchMode,
      ports: portList.join(' '),
    }),
    ...rulesFunc[ruleType](ruleItem),
  };
}

/**
 * Checks for parameters unsupported by the network policy "Rule Mode"
 * @param {String} manifest YAML of network policy
 * @returns {Boolean} whether the YAML is valid to be parsed into "Rule Mode"
 */
const hasUnsupportedAttribute = (manifest) => {
  const primaryKeys = ['apiVersion', 'description', 'kind', 'metadata', 'spec'];
  const metadataKeys = ['annotations', 'labels', 'name', 'namespace', 'resourceVersion'];
  const specKeys = ['egress', 'endpointSelector', 'ingress'];
  const ruleKeys = [
    'fromEntities',
    'toEntities',
    'fromCIDR',
    'toCIDR',
    'toFQDNs',
    'fromEndpoints',
    'toEndpoints',
    'toPorts',
  ];
  const toPortKeys = ['ports'];
  const portKeys = ['port', 'protocol'];
  let isUnsupported = false;
  const hasInvalidKey = (object, allowedValues) => {
    return !Object.keys(object).every((item) => allowedValues.includes(item));
  };

  const hasInvalidPolicy = (ingress = [], egress = []) => {
    let isInvalidPolicy = false;
    [...ingress, ...egress].forEach((item) => {
      isInvalidPolicy = hasInvalidKey(item, ruleKeys);
      if (item.toPorts?.length && !isInvalidPolicy) {
        item.toPorts.forEach((entry) => {
          isInvalidPolicy = hasInvalidKey(entry, toPortKeys);
          if (entry.ports?.length && !isInvalidPolicy) {
            entry.ports.forEach((portEntry) => {
              isInvalidPolicy = hasInvalidKey(portEntry, portKeys);
            });
          }
        });
      }
    });
    return isInvalidPolicy;
  };

  isUnsupported = hasInvalidKey(manifest, primaryKeys);

  if (manifest?.metadata && !isUnsupported) {
    isUnsupported = hasInvalidKey(manifest.metadata, metadataKeys);
  }
  if (manifest?.spec && !isUnsupported) {
    isUnsupported = hasInvalidKey(manifest.spec, specKeys);
  }
  if (!isUnsupported && (manifest?.spec?.ingress?.length || manifest?.spec?.egress?.length)) {
    isUnsupported = hasInvalidPolicy(manifest.spec.ingress, manifest.spec.egress);
  }

  return isUnsupported;
};

/*
  Construct a policy object expected by the policy editor from a yaml manifest.
  Expected yaml structure is defined in the official documentation:
    https://docs.cilium.io/en/v1.8/policy/language
*/
export default function fromYaml(manifest) {
  const policy = safeLoad(manifest, { json: true });

  const unsupportedAttribute = hasUnsupportedAttribute(policy);
  if (unsupportedAttribute) return { error: unsupportedAttribute };

  const { description, metadata, spec } = policy;
  const { name, resourceVersion, annotations, labels } = metadata;
  const { endpointSelector = {}, ingress = [], egress = [] } = spec;
  const matchLabels = endpointSelector.matchLabels || {};

  const endpointLabels = Object.keys(matchLabels).reduce((acc, key) => {
    if (key === DisabledByLabel) return acc;
    acc.push(`${key}:${matchLabels[key]}`);
    return acc;
  }, []);

  const rules = []
    .concat(
      ingress.map((item) => parseRule(item, RuleDirectionInbound)),
      egress.map((item) => parseRule(item, RuleDirectionOutbound)),
    )
    .filter((rule) => Boolean(rule));

  return {
    name,
    resourceVersion,
    description,
    annotations,
    labels,
    isEnabled: !Object.keys(matchLabels).includes(DisabledByLabel),
    endpointMatchMode: endpointLabels.length > 0 ? EndpointMatchModeLabel : EndpointMatchModeAny,
    endpointLabels: endpointLabels.join(' '),
    rules,
  };
}
