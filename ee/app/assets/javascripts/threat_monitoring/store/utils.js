import { pick } from 'lodash';
import { getTimeWindow, defaultTimeRange } from '~/vue_shared/constants';

export const getTimeWindowConfig = (timeWindow) => {
  const timeWindowObj = pick(getTimeWindow(timeWindow) || defaultTimeRange, 'duration', 'interval');
  return {
    durationInMilliseconds: timeWindowObj.duration.seconds * 1000,
    interval: timeWindowObj.interval,
  };
};

/**
 * Get the from/to/interval query parameters for the given time window.
 * @param {string} timeWindow - The time window name (from the array of objects timeRanges)
 * @param {number} to - Milliseconds past the epoch corresponding to the
 *     returned `to` parameter
 * @returns {Object} Query parameters `from` and `to` are ISO 8601 dates and
 *    `interval` is the configured interval for the time window.
 */
export const getTimeWindowParams = (timeWindow, to) => {
  const { durationInMilliseconds, interval } = getTimeWindowConfig(timeWindow);

  return {
    from: new Date(to - durationInMilliseconds).toISOString(),
    to: new Date(to).toISOString(),
    interval,
  };
};
