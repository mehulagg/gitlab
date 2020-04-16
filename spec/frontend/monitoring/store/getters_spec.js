import _ from 'lodash';
import * as getters from '~/monitoring/stores/getters';
import mutations from '~/monitoring/stores/mutations';
import * as types from '~/monitoring/stores/mutation_types';
import { metricStates } from '~/monitoring/constants';
import { environmentData, metricsResult } from '../mock_data';
import {
  metricsDashboardPayload,
  metricResultStatus,
  metricResultPods,
  metricResultEmpty,
} from '../fixture_data';

describe('Monitoring store Getters', () => {
  describe('getMetricStates', () => {
    let setupState;
    let state;
    let getMetricStates;

    const setMetricSuccess = ({ result = metricsResult, group = 0, panel = 0, metric = 0 }) => {
      const { metricId } = state.dashboard.panelGroups[group].panels[panel].metrics[metric];
      mutations[types.RECEIVE_METRIC_RESULT_SUCCESS](state, {
        metricId,
        result,
      });
    };

    const setMetricFailure = ({ group = 0, panel = 0, metric = 0 }) => {
      const { metricId } = state.dashboard.panelGroups[group].panels[panel].metrics[metric];
      mutations[types.RECEIVE_METRIC_RESULT_FAILURE](state, {
        metricId,
      });
    };

    beforeEach(() => {
      setupState = (initState = {}) => {
        state = initState;
        getMetricStates = getters.getMetricStates(state);
      };
    });

    it('has method-style access', () => {
      setupState();

      expect(getMetricStates).toEqual(expect.any(Function));
    });

    it('when dashboard has no panel groups, returns empty', () => {
      setupState({
        dashboard: {
          panelGroups: [],
        },
      });

      expect(getMetricStates()).toEqual([]);
    });

    describe('when the dashboard is set', () => {
      let groups;
      beforeEach(() => {
        setupState({
          dashboard: { panelGroups: [] },
        });
        mutations[types.RECEIVE_METRICS_DASHBOARD_SUCCESS](state, metricsDashboardPayload);
        groups = state.dashboard.panelGroups;
      });

      it('no loaded metric returns empty', () => {
        expect(getMetricStates()).toEqual([]);
      });

      it('on an empty metric with no result, returns NO_DATA', () => {
        mutations[types.RECEIVE_METRICS_DASHBOARD_SUCCESS](state, metricsDashboardPayload);
        setMetricSuccess({ result: [], group: 2 });

        expect(getMetricStates()).toEqual([metricStates.NO_DATA]);
      });

      it('on a metric with a result, returns OK', () => {
        mutations[types.RECEIVE_METRICS_DASHBOARD_SUCCESS](state, metricsDashboardPayload);
        setMetricSuccess({ group: 1 });

        expect(getMetricStates()).toEqual([metricStates.OK]);
      });

      it('on a metric with an error, returns an error', () => {
        mutations[types.RECEIVE_METRICS_DASHBOARD_SUCCESS](state, metricsDashboardPayload);
        setMetricFailure({});

        expect(getMetricStates()).toEqual([metricStates.UNKNOWN_ERROR]);
      });

      it('on multiple metrics with results, returns OK', () => {
        mutations[types.RECEIVE_METRICS_DASHBOARD_SUCCESS](state, metricsDashboardPayload);

        setMetricSuccess({ group: 1 });
        setMetricSuccess({ group: 1, panel: 1 });

        expect(getMetricStates()).toEqual([metricStates.OK]);

        // Filtered by groups
        expect(getMetricStates(state.dashboard.panelGroups[1].key)).toEqual([metricStates.OK]);
        expect(getMetricStates(state.dashboard.panelGroups[2].key)).toEqual([]);
      });
      it('on multiple metrics errors', () => {
        mutations[types.RECEIVE_METRICS_DASHBOARD_SUCCESS](state, metricsDashboardPayload);

        setMetricFailure({});
        setMetricFailure({ group: 1 });

        // Entire dashboard fails
        expect(getMetricStates()).toEqual([metricStates.UNKNOWN_ERROR]);
        expect(getMetricStates(groups[0].key)).toEqual([metricStates.UNKNOWN_ERROR]);
        expect(getMetricStates(groups[1].key)).toEqual([metricStates.UNKNOWN_ERROR]);
      });

      it('on multiple metrics with errors', () => {
        mutations[types.RECEIVE_METRICS_DASHBOARD_SUCCESS](state, metricsDashboardPayload);

        // An success in 1 group
        setMetricSuccess({ group: 1 });

        // An error in 2 groups
        setMetricFailure({ group: 1, panel: 1 });
        setMetricFailure({ group: 2, panel: 0 });

        expect(getMetricStates()).toEqual([metricStates.OK, metricStates.UNKNOWN_ERROR]);
        expect(getMetricStates(groups[1].key)).toEqual([
          metricStates.OK,
          metricStates.UNKNOWN_ERROR,
        ]);
        expect(getMetricStates(groups[2].key)).toEqual([metricStates.UNKNOWN_ERROR]);
      });
    });
  });

  describe('metricsWithData', () => {
    let metricsWithData;
    let setupState;
    let state;

    beforeEach(() => {
      setupState = (initState = {}) => {
        state = initState;
        metricsWithData = getters.metricsWithData(state);
      };
    });

    afterEach(() => {
      state = null;
    });

    it('has method-style access', () => {
      setupState();

      expect(metricsWithData).toEqual(expect.any(Function));
    });

    it('when dashboard has no panel groups, returns empty', () => {
      setupState({
        dashboard: {
          panelGroups: [],
        },
      });

      expect(metricsWithData()).toEqual([]);
    });

    describe('when the dashboard is set', () => {
      beforeEach(() => {
        setupState({
          dashboard: { panelGroups: [] },
        });
      });

      it('no loaded metric returns empty', () => {
        mutations[types.RECEIVE_METRICS_DASHBOARD_SUCCESS](state, metricsDashboardPayload);

        expect(metricsWithData()).toEqual([]);
      });

      it('an empty metric, returns empty', () => {
        mutations[types.RECEIVE_METRICS_DASHBOARD_SUCCESS](state, metricsDashboardPayload);
        mutations[types.RECEIVE_METRIC_RESULT_SUCCESS](state, metricResultEmpty);

        expect(metricsWithData()).toEqual([]);
      });

      it('a metric with results, it returns a metric', () => {
        mutations[types.RECEIVE_METRICS_DASHBOARD_SUCCESS](state, metricsDashboardPayload);
        mutations[types.RECEIVE_METRIC_RESULT_SUCCESS](state, metricResultStatus);

        expect(metricsWithData()).toEqual([metricResultStatus.metricId]);
      });

      it('multiple metrics with results, it return multiple metrics', () => {
        mutations[types.RECEIVE_METRICS_DASHBOARD_SUCCESS](state, metricsDashboardPayload);
        mutations[types.RECEIVE_METRIC_RESULT_SUCCESS](state, metricResultStatus);
        mutations[types.RECEIVE_METRIC_RESULT_SUCCESS](state, metricResultPods);

        expect(metricsWithData()).toEqual([metricResultStatus.metricId, metricResultPods.metricId]);
      });

      it('multiple metrics with results, it returns metrics filtered by group', () => {
        mutations[types.RECEIVE_METRICS_DASHBOARD_SUCCESS](state, metricsDashboardPayload);
        mutations[types.RECEIVE_METRIC_RESULT_SUCCESS](state, metricResultStatus);
        mutations[types.RECEIVE_METRIC_RESULT_SUCCESS](state, metricResultPods);

        // First group has metrics
        expect(metricsWithData(state.dashboard.panelGroups[1].key)).toEqual([
          metricResultStatus.metricId,
          metricResultPods.metricId,
        ]);

        // Second group has no metrics
        expect(metricsWithData(state.dashboard.panelGroups[2].key)).toEqual([]);
      });
    });
  });

  describe('filteredEnvironments', () => {
    let state;
    const setupState = (initState = {}) => {
      state = {
        ...state,
        ...initState,
      };
    };

    beforeAll(() => {
      setupState({
        environments: environmentData,
      });
    });

    afterAll(() => {
      state = null;
    });

    [
      {
        input: '',
        output: 17,
      },
      {
        input: '     ',
        output: 17,
      },
      {
        input: null,
        output: 17,
      },
      {
        input: 'does-not-exist',
        output: 0,
      },
      {
        input: 'noop-branch-',
        output: 15,
      },
      {
        input: 'noop-branch-9',
        output: 1,
      },
    ].forEach(({ input, output }) => {
      it(`filteredEnvironments returns ${output} items for ${input}`, () => {
        setupState({
          environmentsSearchTerm: input,
        });
        expect(getters.filteredEnvironments(state).length).toBe(output);
      });
    });
  });

  describe('metricsSavedToDb', () => {
    let metricsSavedToDb;
    let state;
    let mockData;

    beforeEach(() => {
      mockData = _.cloneDeep(metricsDashboardPayload);
      state = {
        dashboard: {
          panelGroups: [],
        },
      };
    });

    it('return no metrics when dashboard is not persisted', () => {
      mutations[types.RECEIVE_METRICS_DASHBOARD_SUCCESS](state, mockData);
      metricsSavedToDb = getters.metricsSavedToDb(state);

      expect(metricsSavedToDb).toEqual([]);
    });

    it('return a metric id when one metric is persisted', () => {
      const id = 99;

      const [metric] = mockData.panel_groups[0].panels[0].metrics;

      metric.metric_id = id;

      mutations[types.RECEIVE_METRICS_DASHBOARD_SUCCESS](state, mockData);
      metricsSavedToDb = getters.metricsSavedToDb(state);

      expect(metricsSavedToDb).toEqual([`${id}_${metric.id}`]);
    });

    it('return a metric id when two metrics are persisted', () => {
      const id1 = 101;
      const id2 = 102;

      const [metric1] = mockData.panel_groups[0].panels[0].metrics;
      const [metric2] = mockData.panel_groups[0].panels[1].metrics;

      // database persisted 2 metrics
      metric1.metric_id = id1;
      metric2.metric_id = id2;

      mutations[types.RECEIVE_METRICS_DASHBOARD_SUCCESS](state, mockData);
      metricsSavedToDb = getters.metricsSavedToDb(state);

      expect(metricsSavedToDb).toEqual([`${id1}_${metric1.id}`, `${id2}_${metric2.id}`]);
    });
  });
});
