<script>
import { mapState, mapActions, mapGetters } from 'vuex';
import { GlDrawer } from '@gitlab/ui';
import { ISSUABLE } from '~/boards/constants';
import { contentTop } from '~/lib/utils/common_utils';
import IssuableAssignees from '~/sidebar/components/assignees/issuable_assignees.vue';
import IssuableTitle from '~/boards/components/issuable_title.vue';
import glFeatureFlagsMixin from '~/vue_shared/mixins/gl_feature_flags_mixin';
import BoardSidebarEpicSelect from './sidebar/board_sidebar_epic_select.vue';
import BoardSidebarTimeTracker from './sidebar/board_sidebar_time_tracker.vue';
import BoardSidebarWeightInput from './sidebar/board_sidebar_weight_input.vue';
import BoardSidebarLabelsSelect from '~/boards/components/sidebar/board_sidebar_labels_select.vue';
import BoardSidebarDueDate from '~/boards/components/sidebar/board_sidebar_due_date.vue';

export default {
  headerHeight: `${contentTop()}px`,
  components: {
    IssuableAssignees,
    GlDrawer,
    IssuableTitle,
    BoardSidebarEpicSelect,
    BoardSidebarTimeTracker,
    BoardSidebarWeightInput,
    BoardSidebarLabelsSelect,
    BoardSidebarDueDate,
  },
  mixins: [glFeatureFlagsMixin()],
  computed: {
    ...mapGetters(['isSidebarOpen', 'getActiveIssue']),
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
    <template #header>
      <issuable-title :ref-path="getActiveIssue.referencePath" :title="getActiveIssue.title" />
    </template>

    <template>
      <issuable-assignees :users="getActiveIssue.assignees" />
      <board-sidebar-epic-select />
      <board-sidebar-time-tracker class="swimlanes-sidebar-time-tracker" />
      <board-sidebar-weight-input v-if="glFeatures.issueWeights" />
      <board-sidebar-labels-select />
      <board-sidebar-due-date />
    </template>
  </gl-drawer>
</template>
