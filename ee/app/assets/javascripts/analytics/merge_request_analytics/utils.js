import dateFormat from 'dateformat';
import {
  getMonthNames,
  dateFromParams,
  getDateInPast,
  getDayDifference,
} from '~/lib/utils/datetime_utility';
import { dateFormats } from '../shared/constants';
import { THROUGHPUT_CHART_STRINGS, DEFAULT_NUMBER_OF_DAYS } from './constants';

/**
 * A utility function which accepts a date range and returns
 * computed month data which is required to build the GraphQL
 * query for the Throughput Analytics chart
 *
 * @param {Date} startDate the startDate for the data range
 * @param {Date} endDate the endDate for the data range
 * @param {String} format the date format to be used
 *
 * @return {Array} the computed month data
 */
export const computeMonthRangeData = (startDate, endDate, format = dateFormats.isoDate) => {
  const monthData = [];
  const monthNames = getMonthNames(true);

  for (
    let dateCursor = new Date(endDate);
    dateCursor >= startDate;
    dateCursor.setMonth(dateCursor.getMonth(), 0)
  ) {
    const monthIndex = dateCursor.getMonth();
    const year = dateCursor.getFullYear();

    const mergedAfter = dateFromParams(year, monthIndex, 1);
    const mergedBefore = dateFromParams(year, monthIndex + 1, 1);

    monthData.unshift({
      year,
      month: monthNames[monthIndex],
      mergedAfter: dateFormat(mergedAfter, format),
      mergedBefore: dateFormat(mergedBefore, format),
    });
  }

  if (monthData.length) {
    monthData[0].mergedAfter = dateFormat(startDate, format); // Set first item to startDate
    monthData[monthData.length - 1].mergedBefore = dateFormat(endDate, format); // Set last item to endDate
  }

  return monthData;
};

/**
 * A utility function which accepts the raw throughput chart data
 * and transforms it into the format required for the area chart.
 *
 * @param {Object} chartData the raw chart data
 *
 * @return {Array} the formatted chart data
 */
export const formatThroughputChartData = (chartData) => {
  if (!chartData) return [];

  const data = Object.keys(chartData)
    .slice(0, -1) // Remove the __typeName key
    .map((value) => [value.split('_').join(' '), chartData[value].count]); // key: Aug_2020 => Aug 2020

  return [
    {
      name: THROUGHPUT_CHART_STRINGS.Y_AXIS_TITLE,
      data,
    },
  ];
};

/**
 * A utility function which accepts start and end date params
 * and validates that the date range does not exceed the bounds
 *
 * @param {Date} startDate the startDate for the data range
 * @param {Date} endDate the endDate for the data range
 *
 * @return {Object} an object containing the startDate and endDate
 */
export const parseAndValidateDates = (startDateParam, endDateParam) => {
  let startDate = new Date(startDateParam);
  let endDate = new Date(endDateParam);
  const numberOfDays = getDayDifference(startDate, endDate);

  if (!startDateParam.length || numberOfDays > DEFAULT_NUMBER_OF_DAYS || endDate < startDate) {
    startDate = getDateInPast(new Date(), DEFAULT_NUMBER_OF_DAYS);
    endDate = new Date();
  }

  return { startDate, endDate };
};
