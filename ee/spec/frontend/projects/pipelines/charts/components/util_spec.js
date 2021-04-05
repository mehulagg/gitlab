import { apiDataToChartSeries } from 'ee/projects/pipelines/charts/components/util';

describe('ee/projects/pipelines/charts/components/util.js', () => {
  describe('apiDataToChartSeries', () => {
    it('transforms the data from the API into data the chart component can use', () => {
      const apiData = [
        // This is the date format we expect from the API
        { value: 5, date: '2015-06-28' },

        // But we should support _any_ date format
        { value: 1, date: '2015-06-28T20:00:00.000-0400' },
        { value: 8, date: '2015-07-01T00:00:00.000Z' },
      ];

      const startDate = new Date(2015, 5, 26, 10);
      const endDate = new Date(2015, 6, 4, 10);

      const expected = [
        {
          name: 'Deployments',
          data: [
            ['Jun 26', 0],
            ['Jun 27', 0],
            ['Jun 28', 5],
            ['Jun 29', 1],
            ['Jun 30', 0],
            ['Jul 1', 8],
            ['Jul 2', 0],
            ['Jul 3', 0],
          ],
        },
      ];

      expect(apiDataToChartSeries(apiData, startDate, endDate)).toEqual(expected);
    });
  });
});
