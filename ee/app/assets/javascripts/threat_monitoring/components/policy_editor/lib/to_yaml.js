import { safeDump } from 'js-yaml';
import { ruleSpec } from './rules';
import { labelSelector } from './utils';
import { EndpointMatchModeAny, DisabledByLabel, CiliumNetworkPolicyKind } from '../constants';

/*
 Return kubernetes resource specification object for a policy.
*/
function spec({ rules, isEnabled, endpointMatchMode, endpointLabels }) {
  const matchLabels =
    endpointMatchMode === EndpointMatchModeAny ? {} : labelSelector(endpointLabels);
  const policySpec = {};

  policySpec.endpointSelector = Object.keys(matchLabels).length > 0 ? { matchLabels } : {};
  rules.forEach((rule) => {
    const { direction } = rule;
    if (!policySpec[direction]) policySpec[direction] = [];

    policySpec[direction].push(ruleSpec(rule));
  });

  if (!isEnabled) {
    policySpec.endpointSelector.matchLabels = {
      ...policySpec.endpointSelector.matchLabels,
      [DisabledByLabel]: 'gitlab',
    };
  }

  return policySpec;
}

/*
 Return yaml representation of a policy.
*/
export default function toYaml(policy) {
  const { name, resourceVersion, description } = policy;
  const metadata = { name };
  if (resourceVersion) {
    metadata.resourceVersion = resourceVersion;
  }

  const policySpec = {
    apiVersion: 'cilium.io/v2',
    kind: CiliumNetworkPolicyKind,
  };

  if (description?.length > 0) {
    policySpec.description = description;
  }

  // We want description at a specific position to have yaml in a common form.
  Object.assign(policySpec, {
    metadata,
    spec: spec(policy),
  });

  return safeDump(policySpec, { noArrayIndent: true });
}
