import { getAverageByMonth, sortByDate } from '~/analytics/instance_statistics/utils';
import {
  mockCountsData1,
  mockCountsData2,
  countsMonthlyChartData1,
  countsMonthlyChartData2,
} from './mock_data';

describe('getAverageByMonth', () => {
  it('collects data into average by months', () => {
    expect(getAverageByMonth(mockCountsData1)).toStrictEqual(countsMonthlyChartData1);
    expect(getAverageByMonth(mockCountsData2)).toStrictEqual(countsMonthlyChartData2);
  });

  it('it transforms a data point to the first of the month', () => {
    const item = mockCountsData1[0];
    const firstOfTheMonth = item.recordedAt.replace(/-[0-9]{2}$/, '-01');
    expect(getAverageByMonth([item])).toStrictEqual([[firstOfTheMonth, item.count]]);
  });

  it('it uses sane defaults', () => {
    expect(getAverageByMonth()).toStrictEqual([]);
  });

  it('it errors when passing null', () => {
    expect(() => {
      getAverageByMonth(null);
    }).toThrow();
  });
});

describe('sortByDate', () => {
  it('sorts the array by date', () => {
    expect(sortByDate(countsMonthlyChartData1)).toStrictEqual([
      countsMonthlyChartData1[1],
      countsMonthlyChartData1[0],
    ]);
  });

  it('does not modify the original array', () => {
    expect(sortByDate(countsMonthlyChartData1) === countsMonthlyChartData1).toBe(false);
  });
});
