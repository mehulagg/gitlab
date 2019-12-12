import { isString } from 'underscore';
import dateFormat from 'dateformat';
import { convertObjectPropsToCamelCase } from '~/lib/utils/common_utils';
import { convertToSnakeCase } from '~/lib/utils/text_utility';
import { newDate, dayAfter, secondsToDays } from '~/lib/utils/datetime_utility';
import { dateFormats } from '../shared/constants';

const EVENT_TYPE_LABEL = 'label';

export const isStartEvent = ev => Boolean(ev) && Boolean(ev.canBeStartEvent) && ev.canBeStartEvent;

export const eventToOption = (obj = null) => {
  if (!obj || (!obj.text && !obj.identifier)) return null;
  const { name: text = '', identifier: value = null } = obj;
  return { text, value };
};

export const getAllowedEndEvents = (events = [], targetIdentifier = null) => {
  if (!targetIdentifier || !events.length) return [];
  const st = events.find(({ identifier }) => identifier === targetIdentifier);
  return st && st.allowedEndEvents ? st.allowedEndEvents : [];
};

export const eventsByIdentifier = (events = [], targetIdentifier = []) => {
  if (!targetIdentifier || !targetIdentifier.length || !events.length) return [];
  return events.filter(({ identifier = '' }) => targetIdentifier.includes(identifier));
};

export const isLabelEvent = (labelEvents = [], ev = null) =>
  Boolean(ev) && labelEvents.length && labelEvents.includes(ev);

export const getLabelEventsIdentifiers = (events = []) =>
  events.filter(ev => ev.type && ev.type === EVENT_TYPE_LABEL).map(i => i.identifier);

/**
 * Checks if the specified stage is in memory or persisted to storage based on the id
 *
 * Default cycle analytics stages are initially stored in memory, when they are first
 * created the id for the stage is the name of the stage in lowercase. This string id
 * is used to fetch stage data (events, median calculation)
 *
 * When either a custom stage is created or an edit is made to a default stage then the
 * default stages get persisted to storage and will have a numeric id. The new numeric
 * id should then be used to access stage data
 *
 * This will be fixed in https://gitlab.com/gitlab-org/gitlab/merge_requests/19278
 */

export const transformRawStages = (stages = []) =>
  stages
    .map(({ id, title, custom = false, ...rest }) => ({
      ...convertObjectPropsToCamelCase(rest, { deep: true }),
      id,
      title,
      slug: custom ? id : convertToSnakeCase(title),
      custom,
      name: title, // editing a stage takes 'name' as a parameter, but the api returns title
    }))
    .sort((a, b) => a.id > b.id);

export const nestQueryStringKeys = (obj = null, targetKey = '') => {
  if (!obj || !isString(targetKey) || !targetKey.length) return {};
  return Object.entries(obj).reduce((prev, [key, value]) => {
    const customKey = `${targetKey}[${key}]`;
    return { ...prev, [customKey]: value };
  }, {});
};

/**
 * Takes the duration data for selected stages, transforms the date values and returns
 * the data in a flattened array
 *
 * The received data is expected to be the following format; One top level object in the array per stage,
 * each potentially having multiple data entries.
 * [
 *   {
 *    slug: 'issue',
 *    selected: true,
 *    data: [
 *      {
 *        'duration_in_seconds': 1234,
 *        'finished_at': '2019-09-02T18:25:43.511Z'
 *      },
 *      ...
 *    ]
 *   },
 *   ...
 * ]
 *
 * The data is then transformed and flattened into the following format;
 * [
 *  {
 *    'duration_in_seconds': 1234,
 *    'finished_at': '2019-09-02'
 *  },
 *  ...
 * ]
 *
 * @param {Array} data - The duration data for selected stages
 * @returns {Array} An array with each item being an object containing the duration_in_seconds and finished_at values for an event
 */
export const flattenDurationChartData = data =>
  data
    .map(stage =>
      stage.data.map(event => {
        const date = new Date(event.finished_at);
        return {
          ...event,
          finished_at: dateFormat(date, dateFormats.isoDate),
        };
      }),
    )
    .flat();

/**
 * Takes the duration data for selected stages, groups the data by day and calculates the total duration
 * per day.
 *
 * The received data is expected to be the following format; One top level object in the array per stage,
 * each potentially having multiple data entries.
 * [
 *   {
 *    slug: 'issue',
 *    selected: true,
 *    data: [
 *      {
 *        'duration_in_seconds': 1234,
 *        'finished_at': '2019-09-02T18:25:43.511Z'
 *      },
 *      ...
 *    ]
 *   },
 *   ...
 * ]
 *
 * The data is then computed and transformed into a format that can be passed to the chart:
 * [
 *  ['2019-09-02', 7, '2019-09-02'],
 *  ['2019-09-03', 10, '2019-09-03'],
 *  ['2019-09-04', 8, '2019-09-04'],
 *  ...
 * ]
 *
 * In the data above, each array i represents a point in the scatterplot with the following data:
 * i[0] = date, displayed on x axis
 * i[1] = metric, displayed on y axis
 * i[2] = date, used in the tooltip
 *
 * @param {Array} data - The duration data for selected stages
 * @param {Date} startDate - The globally selected cycle analytics start date
 * @param {Date} endDate - The globally selected cycle analytics stendart date
 * @returns {Array} An array with each item being another arry of three items (plottable date, computed total, tooltip display date)
 */
export const getDurationChartData = (data, startDate, endDate) => {
  const flattenedData = flattenDurationChartData(data);
  const eventData = [];

  for (
    let currentDate = newDate(startDate);
    currentDate <= endDate;
    currentDate = dayAfter(currentDate)
  ) {
    const currentISODate = dateFormat(newDate(currentDate), dateFormats.isoDate);
    const valuesForDay = flattenedData.filter(object => object.finished_at === currentISODate);
    const summedData = valuesForDay.reduce((total, value) => total + value.duration_in_seconds, 0);
    const summedDataInDays = secondsToDays(summedData);

    if (summedDataInDays) eventData.push([currentISODate, summedDataInDays, currentISODate]);
  }

  return eventData;
};
