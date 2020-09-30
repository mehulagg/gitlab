<script>
import { mapActions, mapGetters } from 'vuex';
import { GlDropdownItem, GlDropdownDivider } from '@gitlab/ui';
import IssuableAssignees from '~/sidebar/components/assignees/issuable_assignees.vue';
import BoardEditableItem from '~/boards/components/sidebar/board_editable_item.vue';
import AssigneesDropdown from '~/vue_shared/components/sidebar/assignees_dropdown.vue';
import AssigneeAvatarLink from '~/sidebar/components/assignees/assignee_avatar_link.vue';

export default {
  components: {
    BoardEditableItem,
    IssuableAssignees,
    AssigneesDropdown,
    GlDropdownItem,
    AssigneeAvatarLink,
    GlDropdownDivider,
  },
  data() {
    return {
      list: [],
      selected: this.$store.getters.getActiveIssue.assignees,
    };
  },
  computed: {
    ...mapGetters(['getActiveIssue']),
    unSelectedFiltered() {
      return this.list.filter(x => {
        return !this.selectedUserNames.includes(x.username);
      });
    },
    selectedUserNames() {
      if (this.selected.length === 0) {
        return [];
      }

      return this.selected.map(({ username }) => username);
    },
    selectedIsEmpty() {
      return this.selected.length === 0;
    },
  },
  mounted() {
    this.getIssueParticipants(`gid://gitlab/Issue/${this.getActiveIssue.iid}`).then(({ data }) => {
      this.list = data.issue.participants.edges.map(node => {
        return node.node;
      });
    });
  },
  methods: {
    ...mapActions(['getIssueParticipants', 'setAssignees']),
    clearSelected() {
      this.selected = [];
    },
    selectAssignee(name) {
      if (name === undefined) {
        this.clearSelected();
        return;
      }

      this.selected = this.selected.concat(name);
    },
    unSelect(name) {
      this.selected = this.selected.filter(user => user.username !== name);
    },
    saveAssignees() {
      this.setAssignees(this.selectedUserNames);
    },
    isChecked(id) {
      return this.selectedUserNames.includes(id);
    },
  },
};
</script>

<template>
  <board-editable-item @close="saveAssignees" :title="'Assignee'">
    <template #collapsed>
      <issuable-assignees :users="getActiveIssue.assignees" />
    </template>

    <template #default>
      <assignees-dropdown class="w-100" text="Assignees" header-text="Assign To">
        <template #items>
          <gl-dropdown-item :is-checked="selectedIsEmpty" class="mt-2" @click="selectAssignee()"
            ><li>Unassigned</li></gl-dropdown-item
          >
          <gl-dropdown-divider />
          <gl-dropdown-item
            v-for="item in selected"
            :key="item.id"
            :user="item"
            :is-checked="isChecked(item.username)"
            @click="unSelect(item.username)"
          >
            <assignee-avatar-link :user="item" rootPath="''">
              <span class="d-flex gl-flex-direction-column gl-overflow-hidden">
                <strong class="dropdown-menu-user-full-name">
                  {{ item.name }}
                </strong>
                <span class="dropdown-menu-user-username">@{{ item.username }}</span>
              </span>
            </assignee-avatar-link>
          </gl-dropdown-item>
          <gl-dropdown-divider v-if="selected.length > 0" />
          <gl-dropdown-item
            v-for="x in unSelectedFiltered"
            :key="x.id"
            :user="x"
            @click="selectAssignee(x)"
          >
            <assignee-avatar-link :user="x" rootPath="''">
              <!-- Abstract this out its being used in a few places -->
              <span class="d-flex gl-flex-direction-column gl-overflow-hidden">
                <strong class="dropdown-menu-user-full-name">
                  {{ x.name }}
                </strong>
                <span class="dropdown-menu-user-username">@{{ x.username }}</span>
              </span>
            </assignee-avatar-link>
          </gl-dropdown-item>
        </template>
      </assignees-dropdown>
    </template>
  </board-editable-item>
</template>
