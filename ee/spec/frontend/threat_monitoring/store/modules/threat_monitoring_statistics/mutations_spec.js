import * as types from 'ee/threat_monitoring/store/modules/threat_monitoring_statistics/mutation_types';
import mutationsFactory from 'ee/threat_monitoring/store/modules/threat_monitoring_statistics/mutations';
import { mockNetworkPolicyStatisticsResponse } from '../../../mocks/mock_data';

describe('threatMonitoringStatistics mutations', () => {
  let state;

  const mutations = mutationsFactory((payload) => payload);
  beforeEach(() => {
    state = {};
  });

  describe(types.SET_ENDPOINT, () => {
    it('sets the endpoint', () => {
      mutations[types.SET_ENDPOINT](state, 'endpoint');
      expect(state.statisticsEndpoint).toEqual('endpoint');
    });
  });

  describe(types.REQUEST_STATISTICS, () => {
    const payload = { foo: true };

    beforeEach(() => {
      mutations[types.REQUEST_STATISTICS](state, payload);
    });

    it('sets isLoadingStatistics to true', () => {
      expect(state.isLoadingStatistics).toBe(true);
    });

    it('sets errorLoadingStatistics to false', () => {
      expect(state.errorLoadingStatistics).toBe(false);
    });

    it('sets timeRange to the payload', () => {
      expect(state.timeRange).toBe(payload);
    });
  });

  describe(types.RECEIVE_STATISTICS_SUCCESS, () => {
    beforeEach(() => {
      mutations[types.RECEIVE_STATISTICS_SUCCESS](state, mockNetworkPolicyStatisticsResponse);
    });

    it('sets statistics according to the payload', () => {
      expect(state.statistics).toEqual(mockNetworkPolicyStatisticsResponse);
    });

    it('sets isLoadingStatistics to false', () => {
      expect(state.isLoadingStatistics).toBe(false);
    });

    it('sets errorLoadingStatistics to false', () => {
      expect(state.errorLoadingStatistics).toBe(false);
    });

    describe('with null payload', () => {
      beforeEach(() => {
        mutations[types.RECEIVE_STATISTICS_SUCCESS](state, null);
      });

      it('sets statistics to the empty state', () => {
        expect(state.statistics).toEqual({
          total: 0,
          anomalous: 0,
          history: {
            nominal: [],
            anomalous: [],
          },
        });
      });

      it('sets isLoadingStatistics to false', () => {
        expect(state.isLoadingStatistics).toBe(false);
      });

      it('sets errorLoadingStatistics to false', () => {
        expect(state.errorLoadingStatistics).toBe(false);
      });
    });
  });

  describe(types.RECEIVE_STATISTICS_ERROR, () => {
    beforeEach(() => {
      mutations[types.RECEIVE_STATISTICS_ERROR](state);
    });

    it('sets isLoadingStatistics to false', () => {
      expect(state.isLoadingStatistics).toBe(false);
    });

    it('sets errorLoadingStatistics to true', () => {
      expect(state.errorLoadingStatistics).toBe(true);
    });
  });
});
