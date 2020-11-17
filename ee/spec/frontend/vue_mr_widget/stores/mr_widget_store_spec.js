import MergeRequestStore from 'ee/vue_merge_request_widget/stores/mr_widget_store';
import mockData from 'ee_jest/vue_mr_widget/mock_data';
import { stateKey } from '~/vue_merge_request_widget/stores/state_maps';

describe('MergeRequestStore', () => {
  let store;

  beforeEach(() => {
    store = new MergeRequestStore(mockData);
  });

  describe('isNothingToMergeState', () => {
    it('returns true when nothingToMerge', () => {
      store.state = stateKey.nothingToMerge;

      expect(store.isNothingToMergeState).toEqual(true);
    });

    it('returns false when not nothingToMerge', () => {
      store.state = 'state';

      expect(store.isNothingToMergeState).toEqual(false);
    });
  });

  describe('setData', () => {
    describe('mergePipelinesEnabled', () => {
      it('should set mergePipelinesEnabled = true when merge_pipelines_enabled is true', () => {
        store.setData({ ...mockData, merge_pipelines_enabled: true });

        expect(store.mergePipelinesEnabled).toBe(true);
      });

      it('should set mergePipelinesEnabled = false when merge_pipelines_enabled is not provided', () => {
        store.setData({ ...mockData, merge_pipelines_enabled: undefined });

        expect(store.mergePipelinesEnabled).toBe(false);
      });
    });

    describe('mergeTrainsCount', () => {
      it('should set mergeTrainsCount when merge_trains_count is provided', () => {
        store.setData({ ...mockData, merge_trains_count: 3 });

        expect(store.mergeTrainsCount).toBe(3);
      });

      it('should set mergeTrainsCount = 0 when merge_trains_count is not provided', () => {
        store.setData({ ...mockData, merge_trains_count: undefined });

        expect(store.mergeTrainsCount).toBe(0);
      });
    });

    describe('mergeTrainIndex', () => {
      it('should set mergeTrainIndex when merge_train_index is provided', () => {
        store.setData({ ...mockData, merge_train_index: 3 });

        expect(store.mergeTrainIndex).toBe(3);
      });

      it('should not set mergeTrainIndex when merge_train_index is not provided', () => {
        store.setData({ ...mockData, merge_train_index: undefined });

        expect(store.mergeTrainIndex).toBeUndefined();
      });
    });
  });
});
