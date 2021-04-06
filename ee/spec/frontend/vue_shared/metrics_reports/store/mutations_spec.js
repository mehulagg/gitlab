import * as types from 'ee/vue_shared/metrics_reports/store/mutation_types';
import mutations from 'ee/vue_shared/metrics_reports/store/mutations';
import state from 'ee/vue_shared/metrics_reports/store/state';

describe('metrics reports mutations', () => {
  let mockState;

  beforeEach(() => {
    mockState = state();
  });

  describe('SET_ENDPOINT', () => {
    it('should set endpoint', () => {
      mutations[types.SET_ENDPOINT](mockState, 'endpoint');

      expect(mockState.endpoint).toEqual('endpoint');
    });
  });

  describe('REQUEST_METRICS', () => {
    it('should set isLoading to true', () => {
      mutations[types.REQUEST_METRICS](mockState);

      expect(mockState.isLoading).toEqual(true);
    });
  });

  describe('RECEIVE_METRICS_SUCCESS', () => {
    it('should set metrics with zero changes', () => {
      const data = {
        existing_metrics: [
          {
            name: 'name',
            value: 'value',
          },
        ],
      };
      mutations[types.RECEIVE_METRICS_SUCCESS](mockState, data);

      expect(mockState.unchangedMetrics).toEqual(data.existing_metrics);
      expect(mockState.numberOfChanges).toEqual(0);
      expect(mockState.isLoading).toEqual(false);
    });

    it('should set metrics with a new metric', () => {
      const data = {
        new_metrics: [
          {
            name: 'name',
            value: 'value',
          },
        ],
      };
      mutations[types.RECEIVE_METRICS_SUCCESS](mockState, data);

      expect(mockState.newMetrics).toEqual(data.new_metrics);
      expect(mockState.numberOfChanges).toEqual(1);
      expect(mockState.isLoading).toEqual(false);
    });

    it('should set metrics with one changes', () => {
      const data = {
        existing_metrics: [
          {
            name: 'name',
            value: 'value',
            previous_value: 'prev',
          },
        ],
      };
      mutations[types.RECEIVE_METRICS_SUCCESS](mockState, data);

      expect(mockState.changedMetrics).toEqual(data.existing_metrics);
      expect(mockState.numberOfChanges).toEqual(1);
      expect(mockState.isLoading).toEqual(false);
    });
  });

  describe('RECEIVE_METRICS_ERROR', () => {
    it('should set endpoint', () => {
      mutations[types.RECEIVE_METRICS_ERROR](mockState);

      expect(mockState.hasError).toEqual(true);
      expect(mockState.isLoading).toEqual(false);
    });
  });
});
