import state from 'ee/vue_shared/metrics_reports/store/state';
import { summaryStatus, metrics } from 'ee/vue_shared/metrics_reports/store/getters';
import { LOADING, ERROR, SUCCESS } from 'ee/vue_shared/metrics_reports/constants';

describe('metrics reports getters', () => {
  describe('summaryStatus', () => {
    describe('when loading', () => {
      it('returns loading status', () => {
        const mockState = state();
        mockState.isLoading = true;

        expect(summaryStatus(mockState)).toEqual(LOADING);
      });
    });

    describe('when there are errors', () => {
      it('returns error status', () => {
        const mockState = state();
        mockState.hasError = true;
        mockState.numberOfChanges = 0;

        expect(summaryStatus(mockState)).toEqual(ERROR);
      });
    });

    describe('when there are changes', () => {
      it('returns changes status', () => {
        const mockState = state();
        mockState.numberOfChanges = 1;

        expect(summaryStatus(mockState)).toEqual(ERROR);
      });
    });

    describe('when successful', () => {
      it('returns loading status', () => {
        const mockState = state();
        mockState.numberOfChanges = 0;

        expect(summaryStatus(mockState)).toEqual(SUCCESS);
      });
    });
  });

  describe('metrics', () => {
    describe('when state has new metrics', () => {
      it('returns array with new metrics', () => {
        const mockState = state();
        mockState.newMetrics = [{ name: 'name', value: 'value' }];
        const metricsResult = metrics(mockState);

        expect(metricsResult.length).toEqual(1);
        expect(metricsResult[0].name).toEqual('name');
        expect(metricsResult[0].value).toEqual('value');
        expect(metricsResult[0].isNew).toEqual(true);
      });
    });

    describe('when state has existing metrics', () => {
      it('returns array with existing metrics', () => {
        const mockState = state();
        mockState.existingMetrics = [{ name: 'name', value: 'value', previous_value: 'prev' }];
        const metricsResult = metrics(mockState);

        expect(metricsResult.length).toEqual(1);
        expect(metricsResult[0].name).toEqual('name');
        expect(metricsResult[0].value).toEqual('value');
        expect(metricsResult[0].previous_value).toEqual('prev');
      });
    });

    describe('when state has removed metrics', () => {
      it('returns array with removed metrics', () => {
        const mockState = state();
        mockState.removedMetrics = [{ name: 'name', value: 'value' }];
        const metricsResult = metrics(mockState);

        expect(metricsResult.length).toEqual(1);
        expect(metricsResult[0].name).toEqual('name');
        expect(metricsResult[0].value).toEqual('value');
        expect(metricsResult[0].wasRemoved).toEqual(true);
      });
    });

    describe('when state has new, existing, and removed metrics', () => {
      it('returns array with new, existing, and removed metrics combined', () => {
        const mockState = state();
        mockState.newMetrics = [{ name: 'name1', value: 'value1' }];
        mockState.existingMetrics = [{ name: 'name2', value: 'value2', previous_value: 'prev' }];
        mockState.removedMetrics = [{ name: 'name3', value: 'value3' }];
        const metricsResult = metrics(mockState);

        expect(metricsResult.length).toEqual(3);
        expect(metricsResult[0].name).toEqual('name1');
        expect(metricsResult[0].value).toEqual('value1');
        expect(metricsResult[0].isNew).toEqual(true);
        expect(metricsResult[1].name).toEqual('name2');
        expect(metricsResult[1].value).toEqual('value2');
        expect(metricsResult[2].name).toEqual('name3');
        expect(metricsResult[2].value).toEqual('value3');
        expect(metricsResult[2].wasRemoved).toEqual(true);
      });
    });

    describe('when state has no metrics', () => {
      it('returns empty array', () => {
        const mockState = state();
        const metricsResult = metrics(mockState);

        expect(metricsResult.length).toEqual(0);
      });
    });
  });
});
