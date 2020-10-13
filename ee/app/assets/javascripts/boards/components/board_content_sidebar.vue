<script>
import { mapState, mapActions, mapGetters } from 'vuex';
import { GlDrawer } from '@gitlab/ui';
import { ISSUABLE } from '~/boards/constants';
import { contentTop } from '~/lib/utils/common_utils';
import IssuableAssignees from '~/sidebar/components/assignees/issuable_assignees.vue';
import IssuableTitle from '~/boards/components/issuable_title.vue';
import BoardSidebarEpicSelect from './sidebar/board_sidebar_epic_select.vue';
import BoardSidebarMilestoneSelect from '~/boards/components/sidebar/board_sidebar_milestone_select.vue';

export default {
  headerHeight: `${contentTop()}px`,
  components: {
    IssuableAssignees,
    GlDrawer,
    IssuableTitle,
    BoardSidebarEpicSelect,
    BoardSidebarMilestoneSelect,
  },
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
      <board-sidebar-milestone-select />
    </template>
  </gl-drawer>
</template>
