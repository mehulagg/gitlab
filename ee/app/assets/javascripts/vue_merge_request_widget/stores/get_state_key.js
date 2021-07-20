import CEGetStateKey from '~/vue_merge_request_widget/stores/get_state_key';
import { stateKey } from './state_maps';

export default function getStateKey() {
  if (this.isGeoSecondaryNode) {
    return 'geoSecondaryNode';
  }

  if (this.policyViolation) {
    return stateKey.policyViolation;
  }

  if (this.jiraAssociation.enforced && this.jiraAssociation.issue_keys.length === 0) {
    return stateKey.jiraAssociationMissing;
  }

  return CEGetStateKey.call(this);
}
