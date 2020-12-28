import { newDate, parsePikadayDate } from '~/lib/utils/datetime_utility';

import { PRESET_TYPES, DAYS_IN_WEEK } from '../constants';

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
export const getTimeframeStartDate = (presetType, timeframe) => {
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
export const getTimeframeEndDate = (presetType, timeframe) => {
  if (presetType === PRESET_TYPES.QUARTERS) {
    return timeframe[lastTimeframeIndex(timeframe)].range[2];
  } else if (presetType === PRESET_TYPES.MONTHS) {
    return timeframe[lastTimeframeIndex(timeframe)];
  }
  const endDate = newDate(timeframe[lastTimeframeIndex(timeframe)]);
  endDate.setDate(endDate.getDate() + DAYS_IN_WEEK);
  return endDate;
};

export const computeStartDate = (rawStartDate, presetType, timeframe) => {
  const timeframeStartDate = getTimeframeStartDate(presetType, timeframe);
  const startDate = {
    actual: rawStartDate ? newDate(parsePikadayDate(rawStartDate)) : undefined,
    undefined: rawStartDate === undefined,
    outOfRange: null,
    /*
      Use 'timeframeStartDate' as a proxy date for rendering a timeline bar
      unless an actual start date is defined and in-range.

      Visualization:

            |----------timeframe-----------|
      |------------------------------|
      ^     ^
      ^     proxy start date
      actual start date of an epic
    */
    proxy: newDate(timeframeStartDate),
  };

  if (!startDate.undefined) {
    startDate.outOfRange = startDate.actual.getTime() < timeframeStartDate.getTime();

    if (!startDate.outOfRange) {
      startDate.proxy = startDate.actual;
    }
  }

  return startDate;
};

export const computeDueDate = (rawDueDate, presetType, timeframe) => {
  const timeframeEndDate = getTimeframeEndDate(presetType, timeframe);
  const dueDate = {
    actual: rawDueDate ? new Date(parsePikadayDate(rawDueDate)) : undefined,
    undefined: rawDueDate === undefined,
    outOfRange: null,
    // Always use 'timeframeEndDate' as a proxy date
    // unless an actual due date is defined and in-range.
    proxy: newDate(timeframeEndDate),
  };

  if (!dueDate.undefined) {
    dueDate.outOfRange = dueDate.actual.getTime() > timeframeEndDate.getTime();

    if (!dueDate.outOfRange) {
      dueDate.proxy = dueDate.actual;
    }
  }

  return dueDate;
};

/**
 * @param {Object} roadmapItem (epic or milestone)
 * @param {string} presetType
 * @param {Array} timeframe
 */
export const computeDates = (rawRoadmapItem, presetType, timeframe) => {
  return {
    startDate: computeStartDate(rawRoadmapItem?.startDate, presetType, timeframe),
    dueDate: computeDueDate(rawRoadmapItem?.dueDate, presetType, timeframe),
  };
};

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
