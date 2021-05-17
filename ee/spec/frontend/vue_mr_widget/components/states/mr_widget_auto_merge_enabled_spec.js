import { shallowMount } from '@vue/test-utils';
import MRWidgetAutoMergeEnabled from '~/vue_merge_request_widget/components/states/mr_widget_auto_merge_enabled.vue';
import {
  MWPS_MERGE_STRATEGY,
  MT_MERGE_STRATEGY,
  MTWPS_MERGE_STRATEGY,
} from '~/vue_merge_request_widget/constants';

describe('MRWidgetAutoMergeEnabled', () => {
  let wrapper;
  let vm;

  const service = {
    merge: () => {},
    poll: () => {},
  };

  const mr = {
    shouldRemoveSourceBranch: false,
    canRemoveSourceBranch: true,
    canCancelAutomaticMerge: true,
    mergeUserId: 1,
    currentUserId: 1,
    setToAutoMergeBy: {},
    sha: '1EA2EZ34',
    targetBranchPath: '/foo/bar',
    targetBranch: 'foo',
    autoMergeStrategy: MTWPS_MERGE_STRATEGY,
  };

  const factory = (mrUpdates = {}) => {
    wrapper = shallowMount(MRWidgetAutoMergeEnabled, {
      propsData: {
        mr: { ...mr, ...mrUpdates },
        service,
      },
    });

    ({ vm } = wrapper);
  };

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
  });

  describe('computed', () => {
    describe('statusTextBeforeAuthor', () => {
      it('should return "Added to the merge train by" if the pipeline has been added to the merge train', () => {
        factory({ autoMergeStrategy: MT_MERGE_STRATEGY });

        expect(vm.statusTextBeforeAuthor).toBe('Added to the merge train by');
      });

      it('should return "Set by" if the MTWPS is selected', () => {
        factory({ autoMergeStrategy: MTWPS_MERGE_STRATEGY });

        expect(vm.statusTextBeforeAuthor).toBe('Set by');
      });

      it('should return "Set by" if the MWPS is selected', () => {
        factory({ autoMergeStrategy: MWPS_MERGE_STRATEGY });

        expect(vm.statusTextBeforeAuthor).toBe('Set by');
      });
    });

    describe('statusTextAfterAuthor', () => {
      it('should return "to start a merge train..." if MTWPS is selected and there is no existing merge train', () => {
        factory({
          autoMergeStrategy: MTWPS_MERGE_STRATEGY,
          mergeTrainsCount: 0,
        });

        expect(vm.statusTextAfterAuthor).toBe('to start a merge train when the pipeline succeeds');
      });

      it('should return "to be added to the merge train..." if MTWPS is selected and there is an existing merge train', () => {
        factory({
          autoMergeStrategy: MTWPS_MERGE_STRATEGY,
          mergeTrainsCount: 1,
        });

        expect(vm.statusTextAfterAuthor).toBe(
          'to be added to the merge train when the pipeline succeeds',
        );
      });

      it('should return "to be merged automatically..." if MWPS is selected', () => {
        factory({ autoMergeStrategy: MWPS_MERGE_STRATEGY });

        expect(vm.statusTextAfterAuthor).toBe(
          'to be merged automatically when the pipeline succeeds',
        );
      });
    });

    describe('cancelButtonText', () => {
      it('should return "Cancel start merge train" if MTWPS is selected', () => {
        factory({ autoMergeStrategy: MTWPS_MERGE_STRATEGY });

        expect(vm.cancelButtonText).toBe('Cancel');
      });

      it('should return "Remove from merge train" if the pipeline has been added to the merge train', () => {
        factory({ autoMergeStrategy: MT_MERGE_STRATEGY });

        expect(vm.cancelButtonText).toBe('Remove from merge train');
      });

      it('should return "Cancel" if MWPS is selected', () => {
        factory({ autoMergeStrategy: MWPS_MERGE_STRATEGY });

        expect(vm.cancelButtonText).toBe('Cancel');
      });
    });
  });

  describe('template', () => {
    it('should render the status text as "...to start a merge train" if MTWPS is selected and there is no existing merge train', () => {
      factory({
        autoMergeStrategy: MTWPS_MERGE_STRATEGY,
        mergeTrainsCount: 0,
      });

      const statusText = wrapper.find('.js-status-text-after-author').text();

      expect(statusText).toBe('to start a merge train when the pipeline succeeds');
    });

    it('should render the status text as "...to be added to the merge train" MTWPS is selected and there is an existing merge train', () => {
      factory({
        autoMergeStrategy: MTWPS_MERGE_STRATEGY,
        mergeTrainsCount: 1,
      });

      const statusText = wrapper.find('.js-status-text-after-author').text();

      expect(statusText).toBe('to be added to the merge train when the pipeline succeeds');
    });

    it('should render the cancel button as "Cancel" if MTWPS is selected', () => {
      factory({ autoMergeStrategy: MTWPS_MERGE_STRATEGY });

      const cancelButtonText = wrapper.find('.js-cancel-auto-merge').text();

      expect(cancelButtonText).toBe('Cancel');
    });
  });

  it('should render the cancel button as "Remove from merge train" if the pipeline has been added to the merge train', () => {
    factory({ autoMergeStrategy: MT_MERGE_STRATEGY });

    const cancelButtonText = wrapper.find('.js-cancel-auto-merge').text();

    expect(cancelButtonText).toBe('Remove from merge train');
  });
});
