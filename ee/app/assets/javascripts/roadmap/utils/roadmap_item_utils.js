import { newDate } from '~/lib/utils/datetime_utility';
import { PRESET_TYPES, DAYS_IN_WEEK } from '../constants';

/**
 * Returns array of milestones extracted from GraphQL response
 * discarding the `edges`->`node` nesting
 *
 * @param {Object} group
 */
export const extractGroupMilestones = (edges) =>
  edges.map(({ node, milestoneNode = node }) => ({
    ...milestoneNode,
  }));

/**
 * Returns number representing index of last item of timeframe array
 *
 * @param {Array} timeframe
 */
export const lastTimeframeIndex = (timeframe) => timeframe.length - 1;

/**
 * Returns first item of the timeframe array
 *
 * @param {string} presetType
 * @param {Array} timeframe
 */
export const timeframeStartDate = (presetType, timeframe) => {
  if (presetType === PRESET_TYPES.QUARTERS) {
    return timeframe[0].range[0];
  }
  return timeframe[0];
};

/**
 * Returns last item of the timeframe array depending on preset type set.
 *
 * @param {string} presetType
 * @param {Array} timeframe
 */
export const timeframeEndDate = (presetType, timeframe) => {
  if (presetType === PRESET_TYPES.QUARTERS) {
    return timeframe[lastTimeframeIndex(timeframe)].range[2];
  } else if (presetType === PRESET_TYPES.MONTHS) {
    return timeframe[lastTimeframeIndex(timeframe)];
  }
  const endDate = newDate(timeframe[lastTimeframeIndex(timeframe)]);
  endDate.setDate(endDate.getDate() + DAYS_IN_WEEK);
  return endDate;
};
