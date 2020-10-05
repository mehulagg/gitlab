import CEGetStateKey from '~/vue_merge_request_widget/stores/get_state_key';
import { stateKey } from './state_maps';

export default function() {
  if (this.isGeoSecondaryNode) {
    return 'geoSecondaryNode';
  }

  if (this.policyViolation) {
    return stateKey.policyViolation;
  }

  return CEGetStateKey.call(this);
}
