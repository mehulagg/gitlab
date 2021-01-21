import { newDate } from '~/lib/utils/datetime_utility';
import { PRESET_DEFAULTS, DAYS_IN_WEEK } from '../../constants';

/**
 * This method returns array of Dates representing 2-weeks timeframe based on provided initialDate
 *
 * For eg; If initialDate is 31th Dec 2017
 *         we show 2 weeks starting from the current date
 * So returned array from this method will be;
 *        [
 *          31 Dec 2017, 7 Jan 2018
 *        ]
 *
 * @param {Date} initialDate
 */
export const getTimeframeForWeeksView = (initialDate = new Date()) => {
  const timeframe = [];
  const startDate = newDate(initialDate);
  startDate.setHours(0, 0, 0, 0);

  const rangeLength = PRESET_DEFAULTS.WEEKS.TIMEFRAME_LENGTH;

  // Iterate for the length of this preset
  for (let i = 0; i < rangeLength; i += 1) {
    // Push date to timeframe only when day is
    // the first day of the next week (if initial date is Tuesday next date will be also Tuesday but of the next week)
    timeframe.push(newDate(startDate));

    // Move date to the next in a week
    startDate.setDate(startDate.getDate() + DAYS_IN_WEEK);
  }

  return timeframe;
};

/**
 * A utility function which extends a given date value by a certain amount of days.
 *
 * @param {Date} initial - the initial date to extend.
 * @param {Number} increment - the amount of days to extend by.
 * @returns {Date}
 *
 * @example
 * incrementDateByDays(new Date(2021, 0, 10), 6) => new Date(2021, 0, 16)
 *
 */
export const incrementDateByDays = (initial, increment) => {
  return new Date(new Date().setDate(initial.getDate() + increment));
};
