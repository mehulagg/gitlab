import {
  ALERT_THRESHOLD,
  ERROR_THRESHOLD,
  INFO_THRESHOLD,
  NONE_THRESHOLD,
  WARNING_THRESHOLD,
} from './constants';

const STORAGE_USAGE_THRESHOLDS = {
  [NONE_THRESHOLD]: 0.0,
  [INFO_THRESHOLD]: 0.5,
  [WARNING_THRESHOLD]: 0.75,
  [ALERT_THRESHOLD]: 0.95,
  [ERROR_THRESHOLD]: 1.0,
};

export function usageRatioToThresholdLevel(currentUsageRatio) {
  let currentLevel = Object.keys(STORAGE_USAGE_THRESHOLDS)[0];
  Object.keys(STORAGE_USAGE_THRESHOLDS).forEach(thresholdLevel => {
    if (currentUsageRatio >= STORAGE_USAGE_THRESHOLDS[thresholdLevel])
      currentLevel = thresholdLevel;
  });

  return currentLevel;
}
