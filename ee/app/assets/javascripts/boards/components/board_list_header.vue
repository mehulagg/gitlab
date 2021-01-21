<script>
import BoardListHeaderFoss from '~/boards/components/board_list_header.vue';
import { __, sprintf, s__ } from '~/locale';

export default {
  extends: BoardListHeaderFoss,
  inject: ['weightFeatureAvailable'],
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
