import { securityFeatures, complianceFeatures } from './components/constants';

export const augmentFeatures = (features = []) => {
  if (Array.isArray(features) === false) {
    return false;
  }

  const featuresByType = features.reduce((acc, feature) => {
    acc[feature.type] = feature;
    return acc;
  }, {});

  const augmentFeature = (feature) => {
    const augmented = {
      ...feature,
      ...featuresByType[feature.type],
    };

    if (feature.type === 'dast') {
      augmented.secondary = { ...augmented.secondary, ...featuresByType.dast_profiles };
    }

    return augmented;
  };

  return {
    augmentedSecurityFeatures: securityFeatures.map(augmentFeature),
    augmentedComplianceFeatures: complianceFeatures.map(augmentFeature),
  };
};
