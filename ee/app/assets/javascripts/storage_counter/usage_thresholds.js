import { STORAGE_USAGE_THRESHOLDS } from './constants';

export function usageRatioToThresholdLevel(currentUsageRatio) {
  let currentLevel = Object.keys(STORAGE_USAGE_THRESHOLDS)[0];
  Object.keys(STORAGE_USAGE_THRESHOLDS).forEach(thresholdLevel => {
    if (currentUsageRatio >= STORAGE_USAGE_THRESHOLDS[thresholdLevel])
      currentLevel = thresholdLevel;
  });

  return currentLevel;
}
