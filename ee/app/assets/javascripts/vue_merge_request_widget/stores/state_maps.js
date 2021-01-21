import stateMaps from '~/vue_merge_request_widget/stores/state_maps';

stateMaps.stateToComponentMap.geoSecondaryNode = 'mr-widget-geo-secondary-node';
stateMaps.stateToComponentMap.policyViolation = 'mr-widget-policy-violation';

export const stateKey = {
  policyViolation: 'policyViolation',
};

export default {
  stateToComponentMap: stateMaps.stateToComponentMap,
  statesToShowHelpWidget: stateMaps.statesToShowHelpWidget,
};
