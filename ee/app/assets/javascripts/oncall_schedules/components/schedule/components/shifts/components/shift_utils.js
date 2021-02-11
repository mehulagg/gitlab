import {
  getOverlapDateInPeriods,
  getDayDifference,
  nDaysAfter,
} from '~/lib/utils/datetime_utility';
import { __ } from '~/locale';
import { PRESET_TYPES, DAYS_IN_WEEK } from 'ee/oncall_schedules/constants';

/**
 * This method returns a Date item that is
 * n days after the start Date provided. This
 * is used to calculate the end Date of a time
 * frame item.
 *
 *
 * @param {Date} timeframeItem - the current timeframe start Date.
 * @param {String} presetType - the current grid type i.e. Week, Day, Hour.
 * @returns {Date}
 * @throws {Error} Uncaught Error: Invalid date
 *
 * @example
 * currentTimeframeEndsAt(new Date(2021, 01, 07), 'WEEKS') => new Date(2021, 01, 14)
 * currentTimeframeEndsAt(new Date(2021, 01, 07), 'DAYS') => new Date(2021, 01, 08)
 *
 */
export const currentTimeframeEndsAt = (
  timeframeItem = new Date(),
  presetType = PRESET_TYPES.WEEKS,
) => {
  if (!(timeframeItem instanceof Date)) {
    throw new Error(__('Invalid date'));
  }
  return new Date(nDaysAfter(timeframeItem, presetType === PRESET_TYPES.DAYS ? 1 : DAYS_IN_WEEK));
};

/**
 * This method returns array of shifts to render
 * against a current timeframe Date item i.e.
 * return any shifts that have an overlap with the current
 * timeframe Date item
 *
 *
 * @param {Array} shifts - current array of shifts for a given rotation timeframe.
 * @param {Date} timeframeItem - the current timeframe start Date.
 * @param {String} presetType - the current grid type i.e. Week, Day, Hour.
 * @returns {Array}
 *
 * @example
 * shiftsToRender([{ startsAt: '2021-01-07', endsAt: '2021-01-08' }, { startsAt: '2021-01-016', endsAt: '2021-01-19' }], new Date(2021, 01, 07), 'WEEKS')
 * => [{ startsAt: '2021-01-07', endsAt: '2021-01-08' }]
 *
 */
export const shiftsToRender = (
  shifts = [],
  timeframeItem = new Date(),
  presetType = PRESET_TYPES.WEEKS,
) => {
  const validShifts = shifts.filter(
    ({ startsAt, endsAt }) =>
      getOverlapDateInPeriods(
        { start: timeframeItem, end: currentTimeframeEndsAt(timeframeItem, presetType) },
        { start: startsAt, end: endsAt },
      ).hoursOverlap > 0,
  );

  return Object.freeze(validShifts);
};

/**
 * This method returns a Boolean
 * to decide if a current shift item
 * is valid for render by checking if there
 * is an hoursOverlap greater than 0
 *
 *
 * @param {Object} shiftRangeOverlap - current shift range overlap object.
 * @returns {Boolean}
 *
 * @example
 * shiftShouldRender({ hoursOverlap: 48 })
 * => true
 *
 */
export const shiftShouldRender = (shiftRangeOverlap = {}) => {
  return Boolean(shiftRangeOverlap?.hoursOverlap);
};

/**
 * This method extends shiftShouldRender for a week item
 * by adding a conditional check for if the
 * shift occurs after the first timeframe
 * item, we need to check if the current shift
 * starts on the timeframe start Date
 *
 *
 * @param {Object} shiftRangeOverlap - current shift range overlap object.
 * @param {Number} timeframeIndex - current timeframe index.
 * @param {Date} shiftStartsAt - current shift start Date.
 * @param {Date} timeframeItem - the current timeframe start Date.
 * @returns {Boolean}
 *
 * @example
 * weekShiftShouldRender({ overlapStartDate: 1610074800000, hoursOverlap: 3 }, 0, new Date(2021-01-07), new Date(2021-01-08))
 * => true
 *
 */
export const weekShiftShouldRender = (
  shiftRangeOverlap = {},
  timeframeIndex = 0,
  shiftStartsAt = new Date(),
  timeframeItem = new Date(),
) => {
  if (timeframeIndex === 0) {
    return shiftShouldRender(shiftRangeOverlap);
  }

  return (
    (shiftStartsAt >= timeframeItem ||
      new Date(shiftRangeOverlap.overlapStartDate) > timeframeItem) &&
    new Date(shiftRangeOverlap.overlapStartDate) <
      currentTimeframeEndsAt(timeframeItem, PRESET_TYPES.WEEKS)
  );
};

/**
 * This method calculates the amount of days until the end of the current
 * timeframe from where the current shift overlap begins at, taking
 * into account when a timeframe might transition month during render
 *
 *
 * @param {Object} shiftRangeOverlap - current shift range overlap object.
 * @param {Date} timeframeItem - the current timeframe start Date.
 * @param {String} presetType - the current grid type i.e. Week, Day, Hour.
 * @returns {Number}
 *
 * @example
 * daysUntilEndOfTimeFrame({ overlapStartDate: 1612814725387 }, Date Mon Feb 08 2021 15:04:57, 'WEEKS')
 * => 7
 * Where overlapStartDate is the timestamp equal to Date Mon Feb 08 2021 15:04:57
 *
 */
export const daysUntilEndOfTimeFrame = (
  shiftRangeOverlap = {},
  timeframeItem = new Date(),
  presetType = PRESET_TYPES.WEEKS,
) => {
  const timeframeEndsAt = currentTimeframeEndsAt(timeframeItem, presetType);
  const startDate = new Date(shiftRangeOverlap?.overlapStartDate);

  if (timeframeEndsAt.getMonth() !== startDate.getMonth()) {
    return Math.abs(getDayDifference(timeframeEndsAt, startDate));
  }

  return timeframeEndsAt.getDate() - startDate.getDate();
};
