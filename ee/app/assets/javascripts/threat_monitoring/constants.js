import { s__ } from '~/locale';

export const INVALID_CURRENT_ENVIRONMENT_NAME = '–';

export const PREDEFINED_NETWORK_POLICIES = [
  {
    name: 'drop-outbound',
    isEnabled: false,
    manifest: `---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: drop-outbound
spec:
  podSelector: {}
  policyTypes:
  - Egress`,
  },
  {
    name: 'allow-inbound-http',
    isEnabled: false,
    manifest: `---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-inbound-http
spec:
  podSelector: {}
  ingress:
  - ports:
    - port: 80
    - port: 443`,
  },
];

export const ALL_ENVIRONMENT_NAME = s__('ThreatMonitoring|All Environments');
