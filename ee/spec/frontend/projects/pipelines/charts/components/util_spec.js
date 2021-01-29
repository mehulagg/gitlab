import { useFakeDate } from 'helpers/fake_date';
import { apiDataToChartSeries } from 'ee/projects/pipelines/charts/components/util';

describe('ee/projects/pipelines/charts/components/util.js', () => {
  useFakeDate(2015, 6, 3, 10);

  describe('apiDataToChartSeries', () => {
    it('transforms the data from the API into data the chart component can use', () => {
      const apiData = [
        { value: 5, from: '2015-06-28', to: '2015-06-29' },
        { value: 1, from: '2015-06-29', to: '2015-06-30' },
        { value: 8, from: '2015-07-01', to: '2015-07-02' },
      ];

      const startDate = new Date(2015, 5, 26, 10);

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

      expect(apiDataToChartSeries(apiData, startDate)).toEqual(expected);
    });
  });
});
