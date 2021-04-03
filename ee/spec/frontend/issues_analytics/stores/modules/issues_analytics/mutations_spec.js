import * as types from 'ee/issues_analytics/stores/modules/issue_analytics/mutation_types';
import mutations from 'ee/issues_analytics/stores/modules/issue_analytics/mutations';
import createState from 'ee/issues_analytics/stores/modules/issue_analytics/state';

describe('Issue Analytics mutations', () => {
  let state;

  beforeEach(() => {
    state = createState();
  });

  describe(types.SET_LOADING_STATE, () => {
    it('sets loading state', () => {
      mutations[types.SET_LOADING_STATE](state, true);

      expect(state.loading).toBe(true);
    });
  });

  describe(types.SET_CHART_DATA, () => {
    it('adds chart data to state', () => {
      const chartData = { '2017-11': 0, '2017-12': 2 };
      mutations[types.SET_CHART_DATA](state, chartData);

      expect(state.chartData).toEqual(chartData);
    });
  });

  describe(types.SET_FILTERS, () => {
    it('adds applied filters to  state', () => {
      const filter = '?state=opened&assignee_username=someone';
      mutations[types.SET_FILTERS](state, filter);

      expect(state.filters).toEqual(filter);
    });
  });
});
