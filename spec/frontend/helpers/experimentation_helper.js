import { featureFlagName } from '~/experimentation';

export function mockExperimentFeatureFlag(experimentKey, value = true) {
  window.gon = () => {};

  gon.features = { [featureFlagName(experimentKey)]: value };
}
