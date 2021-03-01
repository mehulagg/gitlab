import { get } from 'lodash';

export function isExperimentEnabled(experimentKey) {
  return Boolean(window.gon?.experiments?.[experimentKey]);
}

export function experimentData(experimentName) {
  return get(window, ['gon', 'experiment', experimentName]);
}

export function isExperimentVariant(experimentName, variantName) {
  return experimentData(experimentName)?.variant === variantName;
}
