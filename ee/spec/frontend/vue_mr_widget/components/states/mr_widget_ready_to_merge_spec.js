import { shallowMount, createLocalVue } from '@vue/test-utils';
import { MERGE_DISABLED_TEXT_UNAPPROVED } from 'ee/vue_merge_request_widget/mixins/ready_to_merge';
import MergeImmediatelyConfirmationDialog from 'ee/vue_merge_request_widget/components/merge_immediately_confirmation_dialog.vue';
import ReadyToMerge from '~/vue_merge_request_widget/components/states/ready_to_merge.vue';
import {
  MWPS_MERGE_STRATEGY,
  MT_MERGE_STRATEGY,
  MTWPS_MERGE_STRATEGY,
} from '~/vue_merge_request_widget/constants';
import { MERGE_DISABLED_TEXT } from '~/vue_merge_request_widget/mixins/ready_to_merge';

describe('ReadyToMerge', () => {
  const localVue = createLocalVue();
  let wrapper;
  let vm;

  const service = {
    merge: () => {},
    poll: () => {},
  };

  const mr = {
    isPipelineActive: false,
    pipeline: null,
    isPipelineFailed: false,
    isPipelinePassing: false,
    isMergeAllowed: true,
    onlyAllowMergeIfPipelineSucceeds: false,
    ffOnlyEnabled: false,
    hasCI: false,
    ciStatus: null,
    sha: '12345678',
    squash: false,
    commitMessage: 'This is the commit message',
    squashCommitMessage: 'This is the squash commit message',
    commitMessageWithDescription: 'This is the commit message description',
    shouldRemoveSourceBranch: true,
    canRemoveSourceBranch: false,
    targetBranch: 'master',
    preferredAutoMergeStrategy: MWPS_MERGE_STRATEGY,
    availableAutoMergeStrategies: [MWPS_MERGE_STRATEGY],
    mergeImmediatelyDocsPath: 'path/to/merge/immediately/docs',
  };

  const factory = (mrUpdates = {}) => {
    wrapper = shallowMount(localVue.extend(ReadyToMerge), {
      propsData: {
        mr: { ...mr, ...mrUpdates },
        service,
      },
      localVue,
      sync: false,
      stubs: {
        MergeImmediatelyConfirmationDialog,
      },
    });

    ({ vm } = wrapper);
  };

  const findResolveItemsMessage = () => wrapper.find('.js-resolve-mr-widget-items-message');
  const findMergeButton = () => wrapper.find('.qa-merge-button');
  const findMergeButtonDropdown = () => wrapper.find('.js-merge-moment');
  const findMergeImmediatelyButton = () => wrapper.find('.js-merge-immediately-button');

  afterEach(() => {
    wrapper.destroy();
  });

  describe('computed', () => {
    describe('mergeButtonText', () => {
      it('should return "Merge" when no auto merge strategies are available', () => {
        factory({ availableAutoMergeStrategies: [] });

        expect(vm.mergeButtonText).toEqual('Merge');
      });

      it('should return "Merge in progress"', () => {
        factory();
        localVue.set(vm, 'isMergingImmediately', true);

        expect(vm.mergeButtonText).toEqual('Merge in progress');
      });

      it('should return "Merge when pipeline succeeds" when the MWPS auto merge strategy is available', () => {
        factory({
          preferredAutoMergeStrategy: MWPS_MERGE_STRATEGY,
        });

        expect(vm.mergeButtonText).toEqual('Merge when pipeline succeeds');
      });

      it('should return "Start merge train" when the merge train auto merge stategy is available and there is no existing merge train', () => {
        factory({
          preferredAutoMergeStrategy: MT_MERGE_STRATEGY,
          mergeTrainsCount: 0,
        });

        expect(vm.mergeButtonText).toEqual('Start merge train');
      });

      it('should return "Add to merge train" when the merge train auto merge stategy is available and a merge train already exists', () => {
        factory({
          preferredAutoMergeStrategy: MT_MERGE_STRATEGY,
          mergeTrainsCount: 1,
        });

        expect(vm.mergeButtonText).toEqual('Add to merge train');
      });

      it('should return "Start merge train when pipeline succeeds" when the MTWPS auto merge strategy is available and there is no existing merge train', () => {
        factory({
          preferredAutoMergeStrategy: MTWPS_MERGE_STRATEGY,
          mergeTrainsCount: 0,
        });

        expect(vm.mergeButtonText).toEqual('Start merge train when pipeline succeeds');
      });

      it('should return "Add to merge train when pipeline succeeds" when the MTWPS auto merge strategy is available and a merge train already exists', () => {
        factory({
          preferredAutoMergeStrategy: MTWPS_MERGE_STRATEGY,
          mergeTrainsCount: 1,
        });

        expect(vm.mergeButtonText).toEqual('Add to merge train when pipeline succeeds');
      });
    });

    describe('autoMergeText', () => {
      it('should return Merge when pipeline succeeds', () => {
        factory({ preferredAutoMergeStrategy: MWPS_MERGE_STRATEGY });

        expect(vm.autoMergeText).toEqual('Merge when pipeline succeeds');
      });

      it('should return Start merge train when pipeline succeeds', () => {
        factory({
          preferredAutoMergeStrategy: MTWPS_MERGE_STRATEGY,
          mergeTrainsCount: 0,
        });

        expect(vm.autoMergeText).toEqual('Start merge train when pipeline succeeds');
      });

      it('should return Add to merge train when pipeline succeeds', () => {
        factory({
          preferredAutoMergeStrategy: MTWPS_MERGE_STRATEGY,
          mergeTrainsCount: 1,
        });

        expect(vm.autoMergeText).toEqual('Add to merge train when pipeline succeeds');
      });
    });

    describe('isMergeImmediatelyDangerous', () => {
      it('should return false if the preferred auto merge strategy is not merge train-related', () => {
        factory({ preferredAutoMergeStrategy: MWPS_MERGE_STRATEGY });

        expect(vm.isMergeImmediatelyDangerous).toBe(false);
      });

      it('should return true if the preferred auto merge strategy is merge trains', () => {
        factory({ preferredAutoMergeStrategy: MT_MERGE_STRATEGY });

        expect(vm.isMergeImmediatelyDangerous).toBe(true);
      });

      it('should return true if the preferred auto merge strategy is merge trains when pipeline succeeds', () => {
        factory({ preferredAutoMergeStrategy: MTWPS_MERGE_STRATEGY });

        expect(vm.isMergeImmediatelyDangerous).toBe(true);
      });
    });
  });

  describe('shouldShowMergeImmediatelyDropdown', () => {
    it('should return false if no pipeline is active', () => {
      factory({
        isPipelineActive: false,
        onlyAllowMergeIfPipelineSucceeds: false,
      });

      expect(vm.shouldShowMergeImmediatelyDropdown).toBe(false);
    });

    it('should return false if "Pipelines must succeed" is enabled for the current project', () => {
      factory({
        isPipelineActive: true,
        onlyAllowMergeIfPipelineSucceeds: true,
      });

      expect(vm.shouldShowMergeImmediatelyDropdown).toBe(false);
    });

    it('should return true if the MR\'s pipeline is active and "Pipelines must succeed" is not enabled for the current project', () => {
      factory({
        isPipelineActive: true,
        onlyAllowMergeIfPipelineSucceeds: false,
      });

      expect(vm.shouldShowMergeImmediatelyDropdown).toBe(true);
    });

    it('should return true when the merge train auto merge stategy is available ', () => {
      factory({
        preferredAutoMergeStrategy: MT_MERGE_STRATEGY,
        isPipelineActive: false,
        onlyAllowMergeIfPipelineSucceeds: true,
      });

      expect(vm.shouldShowMergeImmediatelyDropdown).toBe(true);
    });
  });

  describe('merge immediately warning dialog', () => {
    let dialog;

    const clickMergeImmediately = () => {
      dialog = wrapper.find(MergeImmediatelyConfirmationDialog);

      expect(dialog.exists()).toBe(true);
      dialog.vm.show = jest.fn();
      vm.handleMergeButtonClick = jest.fn();
      findMergeButtonDropdown().trigger('click');
      return wrapper.vm.$nextTick().then(() => {
        findMergeImmediatelyButton().trigger('click');
        return wrapper.vm.$nextTick();
      });
    };

    it('should show a warning dialog asking for confirmation if the user is trying to skip the merge train', () => {
      factory({ preferredAutoMergeStrategy: MT_MERGE_STRATEGY });
      return clickMergeImmediately().then(() => {
        expect(dialog.vm.show).toHaveBeenCalled();
        expect(vm.handleMergeButtonClick).not.toHaveBeenCalled();
      });
    });

    it('should perform the merge when the user confirms their intent to merge immediately', () => {
      factory({ preferredAutoMergeStrategy: MT_MERGE_STRATEGY });
      return clickMergeImmediately()
        .then(() => {
          dialog.vm.$emit('mergeImmediately');
          return wrapper.vm.$nextTick();
        })
        .then(() => {
          expect(vm.handleMergeButtonClick).toHaveBeenCalled();
        });
    });

    it('should not ask for confirmation in non-merge train scenarios', () => {
      factory({ isPipelineActive: true, onlyAllowMergeIfPipelineSucceeds: false });
      return clickMergeImmediately().then(() => {
        expect(dialog.vm.show).not.toHaveBeenCalled();
        expect(vm.handleMergeButtonClick).toHaveBeenCalled();
      });
    });
  });

  describe('cannot merge', () => {
    describe('when isMergeAllowed=false', () => {
      beforeEach(() => {
        factory({ isMergeAllowed: false, availableAutoMergeStrategies: [] });
      });

      it('should show cannot merge text', () => {
        expect(findResolveItemsMessage().text()).toEqual(MERGE_DISABLED_TEXT);
      });

      it('should show disabled merge button', () => {
        const button = findMergeButton();

        expect(button.exists()).toBe(true);
        expect(button.attributes('disabled')).toBe('disabled');
      });
    });
  });

  describe('when needs approval', () => {
    beforeEach(() => {
      factory({
        isMergeAllowed: false,
        availableAutoMergeStrategies: [],
        hasApprovalsAvailable: true,
        isApproved: false,
      });
    });

    it('should show approvals needed text', () => {
      expect(findResolveItemsMessage().text()).toEqual(MERGE_DISABLED_TEXT_UNAPPROVED);
    });
  });
});
