import * as utils from 'ee/analytics/merge_request_analytics/utils';
import { expectedMonthData, throughputChartData, formattedThroughputChartData } from './mock_data';

describe('computeMonthRangeData', () => {
  const start = new Date('2020-05-17T00:00:00.000Z');
  const end = new Date('2020-07-17T00:00:00.000Z');

  it('returns the data as expected', () => {
    const monthData = utils.computeMonthRangeData(start, end);

    expect(monthData).toStrictEqual(expectedMonthData);
  });

  it('returns an empty array on an invalid date range', () => {
    const monthData = utils.computeMonthRangeData(end, start);

    expect(monthData).toStrictEqual([]);
  });
});

describe('formatThroughputChartData', () => {
  it('returns the data as expected', () => {
    const chartData = utils.formatThroughputChartData(throughputChartData);

    expect(chartData).toStrictEqual(formattedThroughputChartData);
  });

  it('returns an empty array if no data is passed to the util', () => {
    const chartData = utils.formatThroughputChartData();

    expect(chartData).toStrictEqual([]);
  });
});
