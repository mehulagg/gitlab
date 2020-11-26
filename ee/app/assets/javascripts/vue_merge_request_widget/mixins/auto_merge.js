import {
  MT_MERGE_STRATEGY,
  MTWPS_MERGE_STRATEGY,
  MWPS_MERGE_STRATEGY,
} from '~/vue_merge_request_widget/constants';
import { s__ } from '~/locale';

export default {
  computed: {
    statusTextBeforeAuthor() {
      if (this.mr.autoMergeStrategy === MT_MERGE_STRATEGY) {
        return s__('mrWidget|Added to the merge train by');
      }

      return s__('mrWidget|Set by');
    },
    statusTextAfterAuthor() {
      if (this.mr.autoMergeStrategy === MTWPS_MERGE_STRATEGY && this.mr.mergeTrainsCount === 0) {
        return s__('mrWidget|to start a merge train when the pipeline succeeds');
      } else if (
        this.mr.autoMergeStrategy === MTWPS_MERGE_STRATEGY &&
        this.mr.mergeTrainsCount !== 0
      ) {
        return s__('mrWidget|to be added to the merge train when the pipeline succeeds');
      } else if (this.mr.autoMergeStrategy === MWPS_MERGE_STRATEGY) {
        return s__('mrWidget|to be merged automatically when the pipeline succeeds');
      }

      return '';
    },
    cancelButtonText() {
      if (this.mr.autoMergeStrategy === MT_MERGE_STRATEGY) {
        return s__('mrWidget|Remove from merge train');
      }

      return s__('mrWidget|Cancel automatic merge');
    },
  },
};
