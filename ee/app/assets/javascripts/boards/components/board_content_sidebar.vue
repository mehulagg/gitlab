<script>
import { mapState, mapActions, mapGetters } from 'vuex';
import { GlDrawer, GlDropdown, GlSearchBoxByType } from '@gitlab/ui';
import { ISSUABLE } from '~/boards/constants';
import { contentTop } from '~/lib/utils/common_utils';
import IssuableAssignees from '~/sidebar/components/assignees/issuable_assignees.vue';
import IssuableTitle from '~/boards/components/issuable_title.vue';
import BoardSidebarEpicSelect from './sidebar/board_sidebar_epic_select.vue';
import BoardEditableItem from '~/boards/components/sidebar/board_editable_item.vue';

export default {
  headerHeight: `${contentTop()}px`,
  components: {
    IssuableAssignees,
    GlDrawer,
    IssuableTitle,
    BoardSidebarEpicSelect,
    BoardEditableItem,
    GlDropdown,
    GlSearchBoxByType,
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
      <board-editable-item :title="'Assignee'">
        <template #collapsed>
          <issuable-assignees :users="getActiveIssue.assignees" />
        </template>

        <template #default>
          <gl-dropdown class="show w-100" text="Assignees" header-text="Assign to">
            <b-dropdown-form class="w-100">
              <gl-search-box-by-type />
            </b-dropdown-form>
          </gl-dropdown>
        </template>
      </board-editable-item>
    </template>

    <template>
      <board-sidebar-epic-select />
    </template>
  </gl-drawer>
</template>
