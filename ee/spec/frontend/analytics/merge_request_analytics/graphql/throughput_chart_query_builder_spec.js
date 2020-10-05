import { print } from 'graphql/language/printer';
import throughputChartQueryBuilder from 'ee/analytics/merge_request_analytics/graphql/throughput_chart_query_builder';
import { throughputChartQuery } from '../mock_data';

describe('throughputChartQueryBuilder', () => {
  it('returns the query as expected', () => {
    const startDate = new Date('2020-05-17T00:00:00.000Z');
    const endDate = new Date('2020-07-17T00:00:00.000Z');

    const query = throughputChartQueryBuilder(startDate, endDate);

    expect(print(query)).toEqual(throughputChartQuery);
  });
});
