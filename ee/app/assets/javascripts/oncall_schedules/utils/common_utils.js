import { sprintf, __ } from '~/locale';
import { getDateInFuture } from '~/lib/utils/datetime_utility';

/**
 * Returns formatted timezone string, e.g. (UTC-09:00) AKST Alaska
 *
 * @param {Object} tz
 * @param {String} tz.name
 * @param {String} tz.formatted_offset
 * @param {String} tz.abbr
 *
 * @returns {String}
 */
export const getFormattedTimezone = (tz) => {
  return sprintf(__('(UTC %{offset}) %{timezone}'), {
    offset: tz.formatted_offset,
    timezone: `${tz.abbr} ${tz.name}`,
  });
};

/**
 * Returns formatted date of the rotation assignee
 * based on the rotation start time and length
 *
 * @param {Date} startDate
 * @param {Number} daysToAdd
 *
 * @returns {Date}
 */
export const assigneeScheduleDateStart = (startDate, daysToAdd) => {
  return getDateInFuture(startDate, daysToAdd);
};

/**
 * Returns boolean based on a valid(non-empty string) form element - name
 *
 * @param {String} startDate
 *
 * @returns {Boolean}
 */
export const formNameIsValid = (formName) => {
  if (!formName) return false;

  return formName !== '';
};
