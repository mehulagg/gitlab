import * as utils from 'ee/analytics/merge_request_analytics/utils';
import { expectedMonthData } from './mock_data';

describe('computeMonthRangeData', () => {
  const start = new Date('2020-05-17T00:00:00.000Z');

  it.each`
    startDate | endDate
    ${start}  | ${new Date('2020-07-17T00:00:00.000Z')}
    ${start}  | ${new Date('2020-07-31T00:00:00.000Z')}
  `('returns the data as expected', ({ startDate, endDate }) => {
    const monthData = utils.computeMonthRangeData(startDate, endDate);

    expect(monthData).toStrictEqual(expectedMonthData);
  });

  it('returns an empty array on an invalid date range', () => {
    const startDate = new Date('2021-05-17T00:00:00.000Z');
    const endDate = new Date('2020-07-17T00:00:00.000Z');

    const monthData = utils.computeMonthRangeData(startDate, endDate);

    expect(monthData).toStrictEqual([]);
  });
});
