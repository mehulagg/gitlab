import { newDateAsLocaleTime } from '~/lib/utils/datetime_utility';
import { sprintf, __ } from '~/locale';
import { ASSIGNEE_COLORS_COMBO } from '../constants';

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
 * Returns `true` for non-empty string, otherwise returns `false`
 *
 * @param {String} startDate
 *
 * @returns {Boolean}
 */
export const isNameFieldValid = (nameField) => {
  return Boolean(nameField?.length);
};

/**
 * Returns a Array of Objects that represent the shift participant
 * with his/her username and unique shift color values
 *
 * @param {Object[]} participants
 * @param {string} participants[].username - The username of the participant.
 *
 * @returns {Object[]} A list of values to save each participant
 * @property {string} username
 * @property {string} colorWeight
 * @property {string} colorPalette
 */
export const getParticipantsForSave = (participants) =>
  participants.map(({ username }, index) => {
    const colorIndex = index % ASSIGNEE_COLORS_COMBO.length;
    const { colorWeight, colorPalette } = ASSIGNEE_COLORS_COMBO[colorIndex];

    return {
      username,
      colorWeight,
      colorPalette,
    };
  });

/**
 * Parses a activePeriod string into an integer value
 *
 * @param {String} hourString
 */
export const parseHour = (hourString) => parseInt(hourString.slice(0, 2), 10);

/**
 * Parses a rotation date for use in the add/edit rotation form
 *
 * @param {ISOString} dateTimeString
 * @param {Timezone string - long} scheduleTimezone
 */
export const parseRotationDate = (dateTimeString, scheduleTimezone) => {
  const options = {
    year: 'numeric',
    month: '2-digit',
    day: '2-digit',
    hour: '2-digit',
    hourCycle: 'h23',
    timeZone: scheduleTimezone,
    timeZoneName: 'long',
  };
  const formatter = new Intl.DateTimeFormat('en-US', options);
  const parts = formatter.formatToParts(Date.parse(dateTimeString));
  const [month, , day, , year, , hour] = parts.map((part) => part.value);
  // The datepicker uses local time
  const date = newDateAsLocaleTime(`${year}-${month}-${day}`);
  const time = parseInt(hour, 10);

  return { date, time };
};
