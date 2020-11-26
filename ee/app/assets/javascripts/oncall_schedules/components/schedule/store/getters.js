import { newDate } from '~/lib/utils/datetime_utility';

import { PRESET_TYPES, DAYS_IN_WEEK } from '../constants';

/**
 * Returns number representing index of last item of timeframe array from state
 *
 * @param {Object} state
 */
export const lastTimeframeIndex = state => state.timeframe.length - 1;

/**
 * Returns first item of the timeframe array from state
 *
 * @param {Object} state
 */
export const timeframeStartDate = state => {
  if (state.presetType === PRESET_TYPES.QUARTERS) {
    return state.timeframe[0].range[0];
  }
  return state.timeframe[0];
};

/**
 * Returns last item of the timeframe array from state depending on preset
 * type set.
 *
 * @param {Object} state
 * @param {Object} getters
 */
export const timeframeEndDate = (state, getters) => {
  if (state.presetType === PRESET_TYPES.QUARTERS) {
    return state.timeframe[getters.lastTimeframeIndex].range[2];
  } else if (state.presetType === PRESET_TYPES.MONTHS) {
    return state.timeframe[getters.lastTimeframeIndex];
  }
  const endDate = newDate(state.timeframe[getters.lastTimeframeIndex]);
  endDate.setDate(endDate.getDate() + DAYS_IN_WEEK);
  return endDate;
};
