<script>
import { mapActions, mapGetters } from 'vuex';
import { GlDropdownItem, GlDropdownDivider, GlAvatarLabeled, GlAvatarLink } from '@gitlab/ui';
import { __ } from '~/locale';
import IssuableAssignees from '~/sidebar/components/assignees/issuable_assignees.vue';
import BoardEditableItem from '~/boards/components/sidebar/board_editable_item.vue';
import AssigneesDropdown from '~/vue_shared/components/sidebar/assignees_dropdown.vue';

export default {
  unassignText: __('Unassign'),
  assigneeText: __('Assignee'),
  components: {
    BoardEditableItem,
    IssuableAssignees,
    AssigneesDropdown,
    GlDropdownItem,
    GlDropdownDivider,
    GlAvatarLabeled,
    GlAvatarLink,
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
      return this.list.filter(({ username }) => {
        return !this.selectedUserNames.includes(username);
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
  <board-editable-item @close="saveAssignees" :title="$options.assigneeText">
    <template #collapsed>
      <issuable-assignees :users="getActiveIssue.assignees" />
    </template>

    <template #default>
      <assignees-dropdown class="w-100" text="Assignees" header-text="Assign To">
        <template #items>
          <gl-dropdown-item :is-checked="selectedIsEmpty" class="mt-2" @click="selectAssignee()"
            ><li>{{ $options.unassignText }}</li></gl-dropdown-item
          >
          <gl-dropdown-divider />
          <gl-dropdown-item
            v-for="item in selected"
            :key="item.id"
            :user="item"
            :is-checked="isChecked(item.username)"
            @click="unSelect(item.username)"
          >
            <gl-avatar-link>
              <gl-avatar-labeled
                :size="32"
                :label="item.name"
                :sub-label="item.username"
                :src="item.avatarUrl || item.avatar"
              />
            </gl-avatar-link>
          </gl-dropdown-item>
          <gl-dropdown-divider v-if="selected.length > 0" />
          <gl-dropdown-item
            v-for="unselectedUser in unSelectedFiltered"
            :key="unselectedUser.id"
            :user="unselectedUser"
            @click="selectAssignee(unselectedUser)"
          >
            <gl-avatar-link>
              <gl-avatar-labeled
                :size="32"
                :label="unselectedUser.name"
                :sub-label="unselectedUser.username"
                :src="unselectedUser.avatarUrl || unselectedUser.avatar"
              />
            </gl-avatar-link>
          </gl-dropdown-item>
        </template>
      </assignees-dropdown>
    </template>
  </board-editable-item>
</template>
