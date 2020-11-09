import CeEnvironmentsStore from '~/environments/stores/environments_store';

export default class EnvironmentsStore extends CeEnvironmentsStore {
  // TODO: delete when deploy boards moved to Core
  storeEnvironments(environments = []) {
    super.storeEnvironments(environments);

    /**
     * Add the canary callout banner underneath the second environment listed.
     *
     * If there is only one environment, then add to it underneath the first.
     */
    if (this.state.environments.length >= 2) {
      this.state.environments[1].showCanaryCallout = true;
    } else if (this.state.environments.length === 1) {
      this.state.environments[0].showCanaryCallout = true;
    }
  }
}
