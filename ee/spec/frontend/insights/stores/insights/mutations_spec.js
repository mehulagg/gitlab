import { CHART_TYPES } from 'ee/insights/constants';
import * as types from 'ee/insights/stores/modules/insights/mutation_types';
import mutations from 'ee/insights/stores/modules/insights/mutations';
import createState from 'ee/insights/stores/modules/insights/state';

import { configData } from 'ee_jest/insights/mock_data';

describe('Insights mutations', () => {
  let state;
  const chart = {
    title: 'Bugs Per Team',
    type: CHART_TYPES.STACKED_BAR,
    description: 'Chart Description',
    query: {
      name: 'filter_issues_by_label_category',
      filter_label: 'bug',
      category_labels: ['Plan', 'Create', 'Manage'],
      group_by: 'month',
      issuable_type: 'issue',
    },
  };

  beforeEach(() => {
    state = createState();
  });

  describe(types.REQUEST_CONFIG, () => {
    it('sets configLoading state when starting request', () => {
      mutations[types.REQUEST_CONFIG](state);

      expect(state.configLoading).toBe(true);
    });

    it('resets configData state when starting request', () => {
      mutations[types.REQUEST_CONFIG](state);

      expect(state.configData).toBe(null);
    });
  });

  describe(types.RECEIVE_CONFIG_SUCCESS, () => {
    it('sets configLoading state to false on success', () => {
      mutations[types.RECEIVE_CONFIG_SUCCESS](state, configData);

      expect(state.configLoading).toBe(false);
    });

    it('sets configData state to incoming data on success', () => {
      mutations[types.RECEIVE_CONFIG_SUCCESS](state, configData);

      const expected = { ...configData };
      delete expected.invalid;

      expect(state.configData).toEqual(expected);
    });
  });

  describe(types.RECEIVE_CONFIG_ERROR, () => {
    it('sets configLoading state to false on error', () => {
      mutations[types.RECEIVE_CONFIG_ERROR](state);

      expect(state.configLoading).toBe(false);
    });

    it('sets configData state to null on error', () => {
      mutations[types.RECEIVE_CONFIG_ERROR](state);

      expect(state.configData).toBe(null);
    });
  });

  describe(types.SET_ACTIVE_TAB, () => {
    it('sets activeTab state', () => {
      mutations[types.SET_ACTIVE_TAB](state, 'key');

      expect(state.activeTab).toBe('key');
    });
  });

  describe(types.SET_ACTIVE_PAGE, () => {
    const pageData = { key: 'page' };

    it('sets activePage state', () => {
      mutations[types.SET_ACTIVE_PAGE](state, pageData);

      expect(state.activePage).toBe(pageData);
    });
  });

  describe(types.RECEIVE_CHART_SUCCESS, () => {
    const incomingData = {
      labels: ['January', 'February'],
      datasets: [
        {
          label: 'Dataset 1',
          fill: true,
          backgroundColor: ['rgba(255, 99, 132)'],
          data: [1],
        },
        {
          label: 'Dataset 2',
          fill: true,
          backgroundColor: ['rgba(54, 162, 235)'],
          data: [2],
        },
      ],
    };

    const transformedData = {
      datasets: [
        { name: 'Dataset 1', data: [1] },
        { name: 'Dataset 2', data: [2] },
      ],
      labels: ['January', 'February'],
      xAxisTitle: 'Months',
      yAxisTitle: 'Issues',
      seriesNames: [],
    };

    beforeEach(() => {
      mutations[types.INIT_CHART_DATA](state, [chart.title]);
    });

    it('sets charts loaded state to true on success', () => {
      mutations[types.RECEIVE_CHART_SUCCESS](state, { chart, data: incomingData });

      const { chartData } = state;

      expect(chartData[chart.title].loaded).toBe(true);
    });

    it('sets charts data to transformed data on success', () => {
      mutations[types.RECEIVE_CHART_SUCCESS](state, { chart, data: incomingData });

      const { chartData } = state;

      expect(chartData[chart.title].data).toStrictEqual(transformedData);
    });

    it('sets charts type to incoming type on success', () => {
      mutations[types.RECEIVE_CHART_SUCCESS](state, { chart, data: incomingData });

      const { chartData } = state;

      expect(chartData[chart.title].type).toBe(chart.type);
    });

    it('sets charts description to incoming type on success', () => {
      mutations[types.RECEIVE_CHART_SUCCESS](state, { chart, data: incomingData });

      const { chartData } = state;

      expect(chartData[chart.title].description).toBe(chart.description);
    });
  });

  describe(types.RECEIVE_CHART_ERROR, () => {
    const error = 'myError';

    it('sets charts loaded state to false on error', () => {
      mutations[types.RECEIVE_CHART_ERROR](state, { chart, error });

      const { chartData } = state;

      expect(chartData[chart.title].loaded).toBe(false);
    });

    it('sets charts data state to an empty object on error', () => {
      mutations[types.RECEIVE_CHART_ERROR](state, { chart, error });

      const { chartData } = state;

      expect(Object.keys(chartData[chart.title].data)).toHaveLength(0);
    });

    it('sets charts type to incoming type on error', () => {
      mutations[types.RECEIVE_CHART_ERROR](state, { chart, error });

      const { chartData } = state;

      expect(chartData[chart.title].type).toBe(chart.type);
    });

    it('sets charts error state to error message on error', () => {
      mutations[types.RECEIVE_CHART_ERROR](state, { chart, error });

      const { chartData } = state;

      expect(chartData[chart.title].error).toBe(error);
    });
  });

  describe(types.INIT_CHART_DATA, () => {
    const keys = ['a', 'b'];

    it('sets chartData state', () => {
      mutations[types.INIT_CHART_DATA](state, keys);

      expect(state.chartData).toEqual({ a: {}, b: {} });
    });
  });
});
