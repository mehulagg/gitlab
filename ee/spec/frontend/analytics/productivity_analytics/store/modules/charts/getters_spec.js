import createState from 'ee/analytics/productivity_analytics/store/modules/charts/state';
import * as getters from 'ee/analytics/productivity_analytics/store/modules/charts/getters';
import {
  chartKeys,
  columnHighlightStyle,
  maxColumnChartItemsPerPage,
  scatterPlotAddonQueryDays,
} from 'ee/analytics/productivity_analytics/constants';
import { getScatterPlotData, getMedianLineData } from 'ee/analytics/productivity_analytics/utils';
import { mockHistogramData, mockScatterplotData } from '../../../mock_data';

jest.mock('ee/analytics/productivity_analytics/utils');
jest.mock('~/lib/utils/datetime_utility', () => ({
  getDateInPast: jest.fn().mockReturnValue('2019-07-16T00:00:00.00Z'),
}));

describe('Productivity analytics chart getters', () => {
  let state;

  const groupNamespace = 'gitlab-org';
  const projectPath = 'gitlab-test';

  beforeEach(() => {
    state = createState();
  });

  describe('chartLoading', () => {
    it('returns true', () => {
      state.charts[chartKeys.main].isLoading = true;

      const result = getters.chartLoading(state)(chartKeys.main);

      expect(result).toBe(true);
    });
  });

  describe('getColumnChartData', () => {
    it("parses the column chart's data and adds a color property to selected items", () => {
      const chartKey = chartKeys.main;
      state.charts[chartKey] = {
        data: {
          '1': 32,
          '5': 17,
        },
        selected: ['5'],
      };

      const chartData = {
        full: [
          { value: ['1', 32], itemStyle: {} },
          { value: ['5', 17], itemStyle: columnHighlightStyle },
        ],
      };

      expect(getters.getColumnChartData(state)(chartKey)).toEqual(chartData);
    });
  });

  describe('getScatterPlotMainData', () => {
    it('calls getScatterPlotData with the raw scatterplot data and the date in past', () => {
      state.charts.scatterplot.data = mockScatterplotData;

      const rootState = {
        filters: {
          daysInPast: 30,
        },
      };

      getters.getScatterPlotMainData(state, null, rootState);

      expect(getScatterPlotData).toHaveBeenCalledWith(
        mockScatterplotData,
        '2019-07-16T00:00:00.00Z',
      );
    });
  });

  describe('getScatterPlotMedianData', () => {
    it('calls getMedianLineData with the raw scatterplot data, the getScatterPlotMainData getter and the an additional days offset', () => {
      state.charts.scatterplot.data = mockScatterplotData;

      const mockGetters = {
        getScatterPlotMainData: jest.fn(),
      };

      getters.getScatterPlotMedianData(state, mockGetters);

      expect(getMedianLineData).toHaveBeenCalledWith(
        mockScatterplotData,
        mockGetters.getScatterPlotMainData,
        scatterPlotAddonQueryDays,
      );
    });
  });

  describe('getMetricDropdownLabel', () => {
    it('returns the correct label for the "time_to_last_commit" metric', () => {
      state.charts[chartKeys.timeBasedHistogram].params = {
        metricType: 'time_to_last_commit',
      };

      expect(getters.getMetricDropdownLabel(state)(chartKeys.timeBasedHistogram)).toBe(
        'Time from first comment to last commit',
      );
    });
  });

  describe('getFilterParams', () => {
    const rootGetters = {};

    rootGetters['filters/getCommonFilterParams'] = () => {
      const params = {
        group_id: groupNamespace,
        project_id: projectPath,
      };
      return params;
    };

    describe('main chart', () => {
      it('returns the correct params object', () => {
        const expected = {
          group_id: groupNamespace,
          project_id: projectPath,
          chart_type: state.charts[chartKeys.main].params.chartType,
        };

        expect(getters.getFilterParams(state, null, null, rootGetters)(chartKeys.main)).toEqual(
          expected,
        );
      });
    });

    describe('timeBasedHistogram charts', () => {
      const chartKey = chartKeys.timeBasedHistogram;

      describe('main chart has selected items', () => {
        it('returns the params object including "days_to_merge"', () => {
          state.charts = {
            [chartKeys.main]: {
              selected: ['5'],
            },
            [chartKeys.timeBasedHistogram]: {
              params: {
                chartType: 'histogram',
              },
            },
          };

          const expected = {
            group_id: groupNamespace,
            project_id: projectPath,
            chart_type: state.charts[chartKey].params.chartType,
            days_to_merge: ['5'],
          };

          expect(getters.getFilterParams(state, null, null, rootGetters)(chartKey)).toEqual(
            expected,
          );
        });
      });

      describe('chart has a metricType', () => {
        it('returns the params object including metric_type', () => {
          state.charts = {
            [chartKeys.main]: {
              selected: [],
            },
            [chartKeys.timeBasedHistogram]: {
              params: {
                chartType: 'histogram',
                metricType: 'time_to_first_comment',
              },
            },
          };

          const expected = {
            group_id: groupNamespace,
            project_id: projectPath,
            chart_type: state.charts[chartKey].params.chartType,
            days_to_merge: [],
            metric_type: 'time_to_first_comment',
          };

          expect(getters.getFilterParams(state, null, null, rootGetters)(chartKey)).toEqual(
            expected,
          );
        });
      });
    });
  });

  describe('getColumnChartOption', () => {
    const chartKey = chartKeys.main;

    describe(`data exceeds threshold of ${maxColumnChartItemsPerPage[chartKey]} items`, () => {
      it('returns a dataZoom property and computes the end interval correctly', () => {
        state.charts[chartKey].data = mockHistogramData;

        const intervalEnd = 98;

        const expected = {
          dataZoom: [
            {
              type: 'slider',
              bottom: 10,
              start: 0,
              end: intervalEnd,
            },
            {
              type: 'inside',
              start: 0,
              end: intervalEnd,
            },
          ],
        };

        expect(getters.getColumnChartOption(state)(chartKeys.main)).toEqual(expected);
      });
    });

    describe(`does not exceed threshold of ${maxColumnChartItemsPerPage[chartKey]} items`, () => {
      it('returns an empty dataZoom property', () => {
        state.charts[chartKey].data = { '1': 1, '2': 2, '3': 3 };

        expect(getters.getColumnChartOption(state)(chartKeys.main)).toEqual({});
      });
    });
  });
});
