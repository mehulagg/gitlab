<script>
import { GlDrawer } from '@gitlab/ui';
import { mapState, mapActions, mapGetters } from 'vuex';
import BoardSidebarDueDate from '~/boards/components/sidebar/board_sidebar_due_date.vue';
import BoardSidebarIssueTitle from '~/boards/components/sidebar/board_sidebar_issue_title.vue';
import BoardSidebarLabelsSelect from '~/boards/components/sidebar/board_sidebar_labels_select.vue';
import BoardSidebarMilestoneSelect from '~/boards/components/sidebar/board_sidebar_milestone_select.vue';
import BoardSidebarSubscription from '~/boards/components/sidebar/board_sidebar_subscription.vue';
import { ISSUABLE } from '~/boards/constants';
import { contentTop } from '~/lib/utils/common_utils';
import SidebarAssigneesWidget from '~/sidebar/components/assignees/sidebar_assignees_widget.vue';
import glFeatureFlagsMixin from '~/vue_shared/mixins/gl_feature_flags_mixin';
import BoardSidebarEpicSelect from './sidebar/board_sidebar_epic_select.vue';
import BoardSidebarIterationSelect from './sidebar/board_sidebar_iteration_select.vue';
import BoardSidebarTimeTracker from './sidebar/board_sidebar_time_tracker.vue';
import BoardSidebarWeightInput from './sidebar/board_sidebar_weight_input.vue';

export default {
  headerHeight: `${contentTop()}px`,
  components: {
    GlDrawer,
    BoardSidebarIssueTitle,
    BoardSidebarEpicSelect,
    SidebarAssigneesWidget,
    BoardSidebarTimeTracker,
    BoardSidebarWeightInput,
    BoardSidebarLabelsSelect,
    BoardSidebarDueDate,
    BoardSidebarSubscription,
    BoardSidebarMilestoneSelect,
    BoardSidebarIterationSelect,
  },
  mixins: [glFeatureFlagsMixin()],
  computed: {
    ...mapGetters(['isSidebarOpen', 'activeIssue']),
    ...mapState(['sidebarType']),
    isIssuableSidebar() {
      return this.sidebarType === ISSUABLE;
    },
    showSidebar() {
      return this.isIssuableSidebar && this.isSidebarOpen;
    },
  },
  methods: {
    ...mapActions(['toggleBoardItem', 'setAssignees']),
    updateAssignees(data) {
      const assignees = data.issueSetAssignees?.issue?.assignees?.nodes || [];
      this.setAssignees(assignees);
    },
    handleClose() {
      this.toggleBoardItem({ boardItem: this.activeIssue, sidebarType: this.sidebarType });
    },
  },
};
</script>

<template>
  <gl-drawer
    v-if="showSidebar"
    data-testid="sidebar-drawer"
    :open="isSidebarOpen"
    :header-height="$options.headerHeight"
    @close="handleClose"
  >
    <template #header>{{ __('Issue details') }}</template>
    <template #default>
      <board-sidebar-issue-title />
      <sidebar-assignees-widget
        :iid="activeIssue.iid"
        :full-path="activeIssue.referencePath.split('#')[0]"
        :initial-assignees="activeIssue.assignees"
        @assignees-updated="updateAssignees"
      />
      <board-sidebar-epic-select />
      <div>
        <board-sidebar-milestone-select />
        <board-sidebar-iteration-select class="gl-mt-5" />
      </div>
      <board-sidebar-time-tracker class="swimlanes-sidebar-time-tracker" />
      <board-sidebar-due-date />
      <board-sidebar-labels-select />
      <board-sidebar-weight-input v-if="glFeatures.issueWeights" />
      <board-sidebar-subscription />
    </template>
  </gl-drawer>
</template>
