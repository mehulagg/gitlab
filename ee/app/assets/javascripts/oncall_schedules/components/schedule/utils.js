import { newDate } from '~/lib/utils/datetime_utility';

import { PRESET_DEFAULTS, DAYS_IN_WEEK } from './constants';

/**
 * This method returns array of Dates respresenting Months based on provided initialDate
 *
 * For eg; If initialDate is 15th Jan 2018
 *         Then as per Roadmap specs, we need to show
 *         2 weeks before current week,
 *         current week AND
 *         4 weeks after current week
 *         thus, total of 7 weeks.
 *         Note that week starts on Sunday
 *
 * So returned array from this method will be;
 *        [
 *          31 Dec 2017, 7 Jan 2018, 14 Jan 2018, 21 Jan 2018,
 *          28 Jan 2018, 4 Mar 2018, 11 Mar 2018
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
    // first day (Sunday) of the week
    timeframe.push(newDate(startDate));

    // Move date next Sunday
    startDate.setDate(startDate.getDate() + DAYS_IN_WEEK);
  }

  return timeframe;
};
