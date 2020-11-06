<script>
import { mapActions, mapGetters } from 'vuex';
import {
  GlDropdownItem,
  GlDropdownDivider,
  GlAvatarLabeled,
  GlAvatarLink,
  GlSearchBoxByType,
} from '@gitlab/ui';
import { __, n__ } from '~/locale';
import IssuableAssignees from '~/sidebar/components/assignees/issuable_assignees.vue';
import BoardEditableItem from '~/boards/components/sidebar/board_editable_item.vue';
import AssigneesDropdown from '~/vue_shared/components/sidebar/assignees_dropdown.vue';
import getIssueParticipants from '~/vue_shared/components/sidebar/queries/getIssueParticipants.query.graphql';
import searchUsers from '~/boards/queries/users_search.query.graphql';

export default {
  i18n: {
    unassigned: __('Unassigned'),
    assignee: __('Assignee'),
    assignees: __('Assignees'),
    assignTo: __('Assign to'),
  },
  components: {
    BoardEditableItem,
    IssuableAssignees,
    AssigneesDropdown,
    GlDropdownItem,
    GlDropdownDivider,
    GlAvatarLabeled,
    GlAvatarLink,
    GlSearchBoxByType,
  },
  data() {
    return {
      search: '',
      participants: [],
      selected: this.$store.getters.getActiveIssue.assignees,
    };
  },
  apollo: {
    participants: {
      query() {
        if (this.isSearchEmpty) {
          return getIssueParticipants;
        }

        return searchUsers;
      },
      variables() {
        if (this.isSearchEmpty) {
          return {
            id: `gid://gitlab/Issue/${this.getActiveIssue.iid}`,
          };
        }
        return {
          search: this.search,
        };
      },
      update(data) {
        if (this.isSearchEmpty) {
          return data.issue?.participants?.nodes || [];
        }

        return data.users?.nodes || [];
      },
      debounce() {
        return 0 ? this.isSearchEmpty : 250;
      },
    },
  },
  computed: {
    ...mapGetters(['getActiveIssue']),
    assigneeText() {
      return n__('Assignee', '%d Assignees', this.selected.length);
    },
    unSelectedFiltered() {
      return this.participants.filter(({ username }) => {
        return !this.selectedUserNames.includes(username);
      });
    },
    selectedIsEmpty() {
      return this.selected.length === 0;
    },
    selectedUserNames() {
      return this.selected.map(({ username }) => username);
    },
    isSearchEmpty() {
      return this.search === '';
    },
  },
  methods: {
    ...mapActions(['setAssignees']),
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
    unselect(name) {
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
  <board-editable-item :title="assigneeText" @close="saveAssignees">
    <template #collapsed>
      <issuable-assignees :users="getActiveIssue.assignees" />
    </template>

    <template #default>
      <assignees-dropdown
        class="w-100"
        :text="$options.i18n.assignees"
        :header-text="$options.i18n.assignTo"
      >
        <template #search>
          <gl-search-box-by-type v-model="search" clear-search-title />
        </template>
        <template #items>
          <gl-dropdown-item
            :is-checked="selectedIsEmpty"
            data-testid="unassign"
            class="mt-2"
            @click="selectAssignee()"
            >{{ $options.i18n.unassigned }}</gl-dropdown-item
          >
          <gl-dropdown-divider data-testid="unassign-divider" />
          <gl-dropdown-item
            v-for="item in selected"
            :key="item.id"
            :is-checked="isChecked(item.username)"
            @click="unselect(item.username)"
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
          <gl-dropdown-divider v-if="!selectedIsEmpty" data-testid="selected-user-divider" />
          <gl-dropdown-item
            v-for="unselectedUser in unSelectedFiltered"
            :key="unselectedUser.id"
            :data-testid="`item_${unselectedUser.name}`"
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
