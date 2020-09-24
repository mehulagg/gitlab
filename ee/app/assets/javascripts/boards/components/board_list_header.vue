<script>
import { mapState, mapActions, mapGetters } from 'vuex';
import BoardListHeaderFoss from '~/boards/components/board_list_header.vue';
import { __, sprintf, s__, n__ } from '~/locale';
import boardsStore from '~/boards/stores/boards_store';
import { inactiveId, LIST } from '~/boards/constants';
import eventHub from '~/sidebar/event_hub';

export default {
  extends: BoardListHeaderFoss,
  data() {
    return {
      weightFeatureAvailable: boardsStore.weightFeatureAvailable,
    };
  },
  computed: {
    ...mapState(['activeId', 'issuesByListId']),
    ...mapGetters(['isSwimlanesOn']),
    issuesCount() {
      if (this.isSwimlanesOn) {
        return this.issuesByListId[this.list.id] ? this.issuesByListId[this.list.id].length : 0;
      }

      return this.list.issuesSize;
    },
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
    issuesTooltipLabel() {
      return n__(`%d issue`, `%d issues`, this.issuesCount);
    },
    weightCountToolTip() {
      const { totalWeight } = this.list;

      if (this.weightFeatureAvailable) {
        return sprintf(s__('%{totalWeight} total weight'), { totalWeight });
      }

      return null;
    },
  },
  methods: {
    ...mapActions(['setActiveId']),
    openSidebarSettings() {
      if (this.activeId === inactiveId) {
        eventHub.$emit('sidebar.closeAll');
      }

      this.setActiveId({ id: this.list.id, sidebarType: LIST });
    },
  },
};
</script>
