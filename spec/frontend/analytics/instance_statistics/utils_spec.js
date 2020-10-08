import { getAverageByMonth } from '~/analytics/instance_statistics/utils';
import {
  mockIssueCounts,
  mockMergeRequestCounts,
  issuesMonthlyChartData,
  mergeRequestsMonthlyChartData,
} from './mock_data';

describe('getAverageByMonth', () => {
  it('collects data into average by months', () => {
    expect(getAverageByMonth(mockIssueCounts)).toStrictEqual(issuesMonthlyChartData);
    expect(getAverageByMonth(mockMergeRequestCounts)).toStrictEqual(mergeRequestsMonthlyChartData);
  });

  it('it transforms a data point to the first of the month', () => {
    const item = mockIssueCounts[0];
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
