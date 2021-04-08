import {
  PRESET_TYPES,
  DAYS_IN_WEEK,
  ASSIGNEE_SPACER,
  ASSIGNEE_SPACER_SMALL,
  HOURS_IN_DAY,
} from 'ee/oncall_schedules/constants';
import {
  getOverlapDateInPeriods,
  getDayDifference,
  nDaysAfter,
} from '~/lib/utils/datetime_utility';
import { __ } from '~/locale';

/**
 * This method returns a Date that is
 * n days after the start Date provided. This
 * is used to calculate the end Date of a time
 * frame item.
 *
 *
 * @param {Date} timeframeStart - the current timeframe start Date.
 * @param {String} presetType - the current grid type i.e. Week, Day, Hour.
 * @returns {Date}
 * @throws {Error} Uncaught Error: Invalid date
 *
 * @example
 * currentTimeframeEndsAt(new Date(2021, 01, 07), 'WEEKS') => new Date(2021, 01, 14)
 * currentTimeframeEndsAt(new Date(2021, 01, 07), 'DAYS') => new Date(2021, 01, 08)
 *
 */
export const currentTimeframeEndsAt = (timeframeStart, presetType) => {
  if (!(timeframeStart instanceof Date)) {
    throw new Error(__('Invalid date'));
  }
  return nDaysAfter(timeframeStart, presetType === PRESET_TYPES.DAYS ? 1 : DAYS_IN_WEEK);
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
export const shiftShouldRender = (shiftRangeOverlap) => {
  return Boolean(shiftRangeOverlap.hoursOverlap);
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
  shiftRangeOverlap,
  timeframeIndex,
  shiftStartsAt,
  timeframeItem,
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
 * This method returns array of shifts to render
 * against a current timeframe Date i.e.
 * return any shifts that have an overlap with the current
 * timeframe Date
 *
 *
 * @param {Array} shifts - current array of shifts for a given rotation timeframe.
 * @param {Date} timeframeItem - the current timeframe start Date.
 * @param {String} presetType - the current grid type i.e. Week, Day, Hour.
 * @param {Number} timeframeIndex - the index of the current timeframe.
 * @returns {Array}
 *
 * @example
 * shiftsToRender([{ startsAt: '2021-01-07', endsAt: '2021-01-08' }, { startsAt: '2021-01-016', endsAt: '2021-01-19' }], new Date(2021, 01, 07), 'WEEKS')
 * => [{ startsAt: '2021-01-07', endsAt: '2021-01-08' }]
 *
 */
export const shiftsToRender = (shifts, timeframeItem, presetType, timeframeIndex) => {
  try {
    const timeframeEndsAt = currentTimeframeEndsAt(timeframeItem, presetType);
    const overlap = (startsAt, endsAt) =>
      getOverlapDateInPeriods(
        { start: timeframeItem, end: timeframeEndsAt },
        { start: startsAt, end: endsAt },
      );

    if (presetType === PRESET_TYPES.DAYS) {
      return shifts.filter(({ startsAt, endsAt }) => overlap(startsAt, endsAt).hoursOverlap > 0);
    }

    return shifts.filter(({ startsAt, endsAt }) =>
      weekShiftShouldRender(
        overlap(startsAt, endsAt),
        timeframeIndex,
        new Date(startsAt),
        timeframeItem,
      ),
    );
  } catch (error) {
    return [];
  }
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
export const daysUntilEndOfTimeFrame = (shiftRangeOverlap, timeframeItem, presetType) => {
  const timeframeEndsAt = currentTimeframeEndsAt(timeframeItem, presetType);
  const startDate = new Date(shiftRangeOverlap?.overlapStartDate);

  if (timeframeEndsAt.getMonth() !== startDate.getMonth()) {
    return Math.abs(getDayDifference(timeframeEndsAt, startDate));
  }

  return timeframeEndsAt.getDate() - startDate.getDate();
};

/**
 * This method calculates the total left position of a current week
 * rotation cell for less than 24 hours, equal to 24 hours
 * or more than 24 hours
 *
 *
 * @param {Boolean} shiftUnitIsHour - true if the current shift length is less than 24 hours.
 * @param {Object} shiftRangeOverlap - current shift range overlap object.
 * @param {Boolean} shiftStartDateOutOfRange - true if the current shift start date is outside of the current grid range.
 * @param {String} shiftTimeUnitWidth - the current grid type i.e. Week, Day, Hour.
 * @param {Date} shiftStartsAt - current shift start Date.
 * @param {Date} timeframeItem - the current timeframe start Date.
 * @param {String} presetType - the current grid type i.e. Week, Day, Hour.
 * @returns {Number}
 *
 * @example
 * weekDisplayShiftLeft(false, { daysOverlap: 3 }, false , 50, Date Mon Feb 08 2021 15:04:57, Date Mon Feb 08 2021 15:04:57, 'WEEKS')
 * => 148
 *
 */
export const weekDisplayShiftLeft = (
  shiftUnitIsHour,
  shiftRangeOverlap,
  shiftStartDateOutOfRange,
  shiftTimeUnitWidth,
  shiftStartsAt,
  timeframeItem,
  presetType,
) => {
  const startDate = shiftStartsAt.getDate();
  const firstDayOfWeek = timeframeItem.getDate();
  const shiftStartsEarly = startDate === firstDayOfWeek || shiftStartDateOutOfRange;
  const daysUntilEnd = daysUntilEndOfTimeFrame(shiftRangeOverlap, timeframeItem, presetType);

  const dayOffSet = (DAYS_IN_WEEK - daysUntilEnd) * shiftTimeUnitWidth;

  if (shiftUnitIsHour) {
    const hourOffset =
      (shiftTimeUnitWidth / HOURS_IN_DAY) * new Date(shiftRangeOverlap.overlapStartDate).getHours();
    return dayOffSet + Math.floor(hourOffset);
  }

  if (shiftStartsEarly) {
    return 0;
  }

  return dayOffSet;
};

/**
 * This method calculates the total width of a current week
 * rotation cell for less than 24 hours, equal to 24 hours
 * or more than 24 hours
 *
 *
 * @param {Boolean} shiftUnitIsHour - true if the current shift length is less than 24 hours.
 * @param {Object} shiftRangeOverlap - current shift range overlap object.
 * @param {Boolean} shiftStartDateOutOfRange - true if the current shift start date is outside of the current grid range.
 * @param {String} shiftTimeUnitWidth - the current grid type i.e. Week, Day, Hour.
 * @returns {Number}
 *
 * @example
 * weekDisplayShiftWidth(false, { daysOverlap: 3, hoursOverlap: 72, overlapEndDate: 1610496000000 }, false , 50)
 * => 148
 *
 */
export const weekDisplayShiftWidth = (
  shiftUnitIsHour,
  shiftRangeOverlap,
  shiftStartDateOutOfRange,
  shiftTimeUnitWidth,
) => {
  if (shiftUnitIsHour) {
    const SPACER = shiftRangeOverlap.hoursOverlap === 1 ? ASSIGNEE_SPACER_SMALL : ASSIGNEE_SPACER;
    return (
      Math.floor((shiftTimeUnitWidth / HOURS_IN_DAY) * shiftRangeOverlap.hoursOverlap) - SPACER
    );
  }

  const shiftEndsAtMidnight = new Date(shiftRangeOverlap.overlapEndDate).getHours() === 0;
  const widthOffset = shiftStartDateOutOfRange && !shiftEndsAtMidnight ? 1 : 0;
  return shiftTimeUnitWidth * (shiftRangeOverlap.daysOverlap - widthOffset) - ASSIGNEE_SPACER;
};

// New utils, unused for now. Added as part of the
// https://gitlab.com/gitlab-org/gitlab/-/issues/324608 merge train.

/**
 * Returns a specified time value as milliseconds.
 *
 * @param {Object} input data
 * @return {Number} the time value in milliseconds
 */
export const milliseconds = ({ h = 0, m = 0, s = 0 }) => (h * 60 * 60 + m * 60 + s) * 1000;

/**
 * Returns the start date of a shift in milliseconds
 *
 * @param {IncidentManagementOncallShift} shift
 * @return {Number} start date in milliseconds
 */
export const getAbsoluteStartDate = ({ startsAt }) => {
  return new Date(startsAt).getTime();
};

/**
 * Returns the end date of a shift in milliseconds
 *
 * @param {IncidentManagementOncallShift} shift
 * @return {Number} end date in milliseconds
 */
export const getAbsoluteEndDate = ({ endsAt }) => {
  return new Date(endsAt).getTime();
};

/**
 * Returns the length of the timeline in milliseconds
 *
 * @param {Enum} presetType
 * @return {Number} timeline length in milliseconds
 */
export const getTotalTime = (presetType) => {
  const MS_PER_DAY = milliseconds({ h: 24 });
  return presetType === PRESET_TYPES.DAYS ? MS_PER_DAY : MS_PER_DAY * 14; // Either 1 day or two weeks
};

/**
 * Returns the time difference between the beginning of the timeline and the beginning of a shift
 *
 * @param {Date} timelineStartDate
 * @param {IncidentManagementOncallShift} shift
 * @return {Number} offset in milliseconds
 */
export const getTimeOffset = (timelineStartDate, shift) => {
  return getAbsoluteStartDate(shift) - timelineStartDate.getTime();
};

/**
 * Returns the duration of a shift in milliseconds
 *
 * @param {IncidentManagementOncallShift} shift
 * @return {Number} duration in milliseconds
 */
export const getDuration = (shift) => {
  return getAbsoluteEndDate(shift) - getAbsoluteStartDate(shift);
};

/**
 * Returns the pixel distance between the beginning of the timeline and the beginning of a shift
 *
 * @param {Object} timeframe, shift, timelineWidth, presetType
 * @return {Number} distance in pixels
 */
export const getPixelOffset = ({ timeframe, shift, timelineWidth, presetType }) => {
  const totalTime = getTotalTime(presetType);
  const timeOffset = getTimeOffset(timeframe[0], shift);
  // offset (px) = total width (px) * shift time (ms) / total time (ms)
  return (timelineWidth * timeOffset) / totalTime;
};

/**
 * Returns the width of a shift in pixels
 *
 * @param {Object} shift, timelineWidth, presetType, shiftDLSOffset
 * @return {Number} width in pixels
 */
export const getPixelWidth = ({ shift, timelineWidth, presetType, shiftDLSOffset }) => {
  const totalTime = getTotalTime(presetType);
  const durationMillis = getDuration(shift);
  const DLS = milliseconds({ m: shiftDLSOffset });
  // shift width (px) = shift time (ms) * total width (px) / total time (ms)
  return ((durationMillis + DLS) * timelineWidth) / totalTime;
};
