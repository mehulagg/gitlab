<script>
import { mapState, mapActions, mapGetters } from 'vuex';
import { GlDrawer } from '@gitlab/ui';
import { ISSUABLE } from '~/boards/constants';
import { contentTop } from '~/lib/utils/common_utils';
import glFeatureFlagsMixin from '~/vue_shared/mixins/gl_feature_flags_mixin';
import BoardSidebarEpicSelect from './sidebar/board_sidebar_epic_select.vue';
import BoardAssigneeDropdown from '~/boards/components/board_assignee_dropdown.vue';
import BoardSidebarTimeTracker from './sidebar/board_sidebar_time_tracker.vue';
import BoardSidebarWeightInput from './sidebar/board_sidebar_weight_input.vue';
import BoardSidebarLabelsSelect from '~/boards/components/sidebar/board_sidebar_labels_select.vue';
import BoardSidebarIssueTitle from '~/boards/components/sidebar/board_sidebar_issue_title.vue';
import BoardSidebarDueDate from '~/boards/components/sidebar/board_sidebar_due_date.vue';
import BoardSidebarSubscription from '~/boards/components/sidebar/board_sidebar_subscription.vue';
import BoardSidebarMilestoneSelect from '~/boards/components/sidebar/board_sidebar_milestone_select.vue';

export default {
  headerHeight: `${contentTop()}px`,
  components: {
    GlDrawer,
    BoardSidebarIssueTitle,
    BoardSidebarEpicSelect,
    BoardAssigneeDropdown,
    BoardSidebarTimeTracker,
    BoardSidebarWeightInput,
    BoardSidebarLabelsSelect,
    BoardSidebarDueDate,
    BoardSidebarSubscription,
    BoardSidebarMilestoneSelect,
  },
  mixins: [glFeatureFlagsMixin()],
  computed: {
    ...mapGetters(['isSidebarOpen', 'activeIssue']),
    ...mapState(['sidebarType']),
    showSidebar() {
      return this.sidebarType === ISSUABLE;
    },
  },
  methods: {
    ...mapActions(['unsetActiveId']),
  },
};
</script>

<template>
  <gl-drawer
    v-if="showSidebar"
    :open="isSidebarOpen"
    :header-height="$options.headerHeight"
    @close="unsetActiveId"
  >
    <template #header>{{ __('Issue details') }}</template>

    <board-sidebar-issue-title />
    <board-assignee-dropdown />
    <board-sidebar-epic-select />
    <board-sidebar-milestone-select />
    <board-sidebar-time-tracker class="swimlanes-sidebar-time-tracker" />
    <board-sidebar-due-date />
    <board-sidebar-labels-select />
    <board-sidebar-weight-input v-if="glFeatures.issueWeights" />
    <board-sidebar-subscription />
  </gl-drawer>
</template>
