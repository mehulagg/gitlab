<script>
import { mapState, mapActions, mapGetters } from 'vuex';
import { GlDrawer } from '@gitlab/ui';
import { ISSUABLE } from '~/boards/constants';
import { contentTop } from '~/lib/utils/common_utils';
import IssuableTitle from '~/boards/components/issuable_title.vue';
import BoardSidebarEpicSelect from './sidebar/board_sidebar_epic_select.vue';
import BoardEditableItem from '~/boards/components/sidebar/board_editable_item.vue';
import AssigneesDropdown from '~/vue_shared/components/sidebar/assignees_dropdown.vue';

export default {
  headerHeight: `${contentTop()}px`,
  components: {
    GlDrawer,
    IssuableTitle,
    BoardSidebarEpicSelect,
    BoardEditableItem,
    AssigneesDropdown,
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
      <board-editable-item :title="'Assignee'">
        <template #collapsed>
          <issuable-assignees :users="getActiveIssue.assignees" />
        </template>

        <template #default>
          <assignees-dropdown />
        </template>
      </board-editable-item>
    </template>

    <template>
      <board-sidebar-epic-select />
    </template>
  </gl-drawer>
</template>
