import { isNumber, isString } from 'lodash';
import { MTWPS_MERGE_STRATEGY, MT_MERGE_STRATEGY } from '~/vue_merge_request_widget/constants';
import { __ } from '~/locale';
import base from '~/vue_merge_request_widget/mixins/ready_to_merge';

export const MERGE_DISABLED_TEXT_UNAPPROVED = __(
  'You can only merge once this merge request is approved.',
);
export const PIPELINE_MUST_SUCCEED_CONFLICT_TEXT = __(
  'A CI/CD pipeline must run and be successful before merge.',
);

export default {
  computed: {
    isApprovalNeeded() {
      return this.mr.hasApprovalsAvailable ? !this.mr.isApproved : false;
    },
    isMergeButtonDisabled() {
      const { commitMessage } = this;
      return Boolean(
        !commitMessage.length ||
          !this.shouldShowMergeControls ||
          this.isMakingRequest ||
          this.isApprovalNeeded ||
          this.mr.preventMerge,
      );
    },
    mergeDisabledText() {
      if (this.isApprovalNeeded) {
        return MERGE_DISABLED_TEXT_UNAPPROVED;
      }

      return base.computed.mergeDisabledText.call(this);
    },
    pipelineMustSucceedConflictText() {
      return PIPELINE_MUST_SUCCEED_CONFLICT_TEXT;
    },
    autoMergeText() {
      if (this.preferredAutoMergeStrategy === MTWPS_MERGE_STRATEGY) {
        if (this.stateData.mergeTrainsCount === 0) {
          return __('Start merge train when pipeline succeeds');
        }
        return __('Add to merge train when pipeline succeeds');
      } else if (this.preferredAutoMergeStrategy === MT_MERGE_STRATEGY) {
        if (this.stateData.mergeTrainsCount === 0) {
          return __('Start merge train');
        }
        return __('Add to merge train');
      }
      return __('Merge when pipeline succeeds');
    },
    shouldRenderMergeTrainHelperText() {
      return (
        this.pipeline &&
        isNumber(this.pipeline.id) &&
        isString(this.pipeline.path) &&
        this.preferredAutoMergeStrategy === MTWPS_MERGE_STRATEGY &&
        !this.stateData.autoMergeEnabled
      );
    },
    shouldShowMergeImmediatelyDropdown() {
      if (this.preferredAutoMergeStrategy === MT_MERGE_STRATEGY) {
        return true;
      }

      return this.isPipelineActive && !this.stateData.onlyAllowMergeIfPipelineSucceeds;
    },
    isMergeImmediatelyDangerous() {
      return [MT_MERGE_STRATEGY, MTWPS_MERGE_STRATEGY].includes(this.preferredAutoMergeStrategy);
    },
  },
};
