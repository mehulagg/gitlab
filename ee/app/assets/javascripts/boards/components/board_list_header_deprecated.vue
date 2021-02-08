<script>
// This is a false violation of @gitlab/no-runtime-template-compiler, since it
// extends a valid Vue single file component.
/* eslint-disable @gitlab/no-runtime-template-compiler */
import BoardListHeaderFoss from '~/boards/components/board_list_header_deprecated.vue';
import { __, sprintf, s__ } from '~/locale';
import boardsStore from '~/boards/stores/boards_store';

export default {
  extends: BoardListHeaderFoss,
  data() {
    return {
      weightFeatureAvailable: boardsStore.weightFeatureAvailable,
    };
  },
  computed: {
    issuesTooltip() {
      const { maxIssueCount } = this.list;

      if (maxIssueCount > 0) {
        return sprintf(__('%{issuesCount} issues with a limit of %{maxIssueCount}'), {
          issuesCount: this.issuesCount,
          maxIssueCount,
        });
      }

      // TODO: Remove this pattern.
      return BoardListHeaderFoss.computed.issuesTooltip.call(this);
    },
    weightCountToolTip() {
      const { totalWeight } = this.list;

      if (this.weightFeatureAvailable) {
        return sprintf(s__('%{totalWeight} total weight'), { totalWeight });
      }

      return null;
    },
  },
};
</script>
