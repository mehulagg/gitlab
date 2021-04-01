import { PRESET_TYPES } from 'ee/oncall_schedules/constants';

// New utils, unused for now. Added as part of the
// https://gitlab.com/gitlab-org/gitlab/-/issues/324608 merge train.

/**
 *
 * @param {Object} input data
 */
export const milliseconds = ({ h = 0, m = 0, s = 0 }) => (h * 60 * 60 + m * 60 + s) * 1000;

/**
 * @param {IncidentManagementOncallShift} shift
 * @return {Number} start date in milliseconds
 */
export const getAbsoluteStartDate = ({ startsAt }) => {
  return new Date(startsAt).getTime();
};

/**
 * @param {IncidentManagementOncallShift} shift
 * @return {Number} end date in milliseconds
 */
export const getAbsoluteEndDate = ({ endsAt }) => {
  return new Date(endsAt).getTime();
};

/**
 *
 * @param {Enum} presetType
 */
export const getTotalTime = (presetType) => {
  // TODO: There might already be a constant for this in our utils.
  const MS_PER_DAY = 24 * 60 * 60 * 1000;
  return presetType === PRESET_TYPES.DAYS ? MS_PER_DAY : MS_PER_DAY * 14; // Either 1 day or two weeks
};

/**
 *
 * @param {ISODateString} timeframeStartDate
 * @param {IncidentManagementOncallShift} shift
 */
export const getTimeOffset = (timeframeStartDate, shift) => {
  return getAbsoluteStartDate(shift) - timeframeStartDate.getTime();
};

/**
 *
 * @param {IncidentManagementOncallShift} shift
 */
export const getDuration = (shift) => {
  return getAbsoluteEndDate(shift) - getAbsoluteStartDate(shift);
};

/**
 *
 * @param {Object} input data
 */
export const getPixelOffset = ({ timeframe, shift, timelineWidth, presetType }) => {
  const totalTime = getTotalTime(presetType);
  const timeOffset = getTimeOffset(timeframe[0], shift);
  // offset (px) = total width (px) * shift time (ms) / total time (ms)
  return (timelineWidth * timeOffset) / totalTime;
};

/**
 *
 * @param {Object} input data
 */
export const getPixelWidth = ({ shift, timelineWidth, presetType, shiftDLSOffset }) => {
  const totalTime = getTotalTime(presetType);
  const durationMillis = getDuration(shift);
  const DLS = milliseconds({ m: shiftDLSOffset });
  // shift width (px) = shift time (ms) * total width (px) / total time (ms)
  return ((durationMillis + DLS) * timelineWidth) / totalTime;
};
