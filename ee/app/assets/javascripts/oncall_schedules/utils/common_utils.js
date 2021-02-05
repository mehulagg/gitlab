import {
  CHEVRON_SKIPPING_PALETTE_ENUM,
  CHEVRON_SKIPPING_SHADE_ENUM,
} from 'ee/oncall_schedules/constants';
import { sprintf, __ } from '~/locale';

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
 * Returns a Array of Objects that represent the 30 possible
 * color combinations for assignees relative to their index
 *
 *
 * @returns {Array}
 */
export const assigneeColorCombo = () =>
  CHEVRON_SKIPPING_SHADE_ENUM.map((shade) =>
    CHEVRON_SKIPPING_PALETTE_ENUM.map((color) => ({ shade, color })),
  ).flat();
