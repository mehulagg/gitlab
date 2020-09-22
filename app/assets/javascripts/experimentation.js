import { property } from 'lodash';

export const featureFlagName = experimentKey => {
  return `${experimentKey}ExperimentPercentage`;
};

export function experimentEnabled(experimentKey) {
  return property(['gon', 'features', featureFlagName(experimentKey)])(window);
}
