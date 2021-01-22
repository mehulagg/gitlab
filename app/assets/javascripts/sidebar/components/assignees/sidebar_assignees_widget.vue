<script>
import { cloneDeep } from 'lodash';
import Vue from 'vue';
import {
  GlDropdownItem,
  GlDropdownDivider,
  GlAvatarLabeled,
  GlAvatarLink,
  GlSearchBoxByType,
  GlLoadingIcon,
} from '@gitlab/ui';
import createFlash from '~/flash';
import { __, n__ } from '~/locale';
import IssuableAssignees from '~/sidebar/components/assignees/issuable_assignees.vue';
import SidebarEditableItem from '~/sidebar/components/sidebar_editable_item.vue';
import MultiSelectDropdown from '~/vue_shared/components/sidebar/multiselect_dropdown.vue';
import searchUsers from '~/graphql_shared/queries/users_search.query.graphql';

export const assigneesWidgetState = Vue.observable({
  updateAssignees: null,
});

export default {
  i18n: {
    unassigned: __('Unassigned'),
    assignee: __('Assignee'),
    assignees: __('Assignees'),
    assignTo: __('Assign to'),
  },
  components: {
    SidebarEditableItem,
    IssuableAssignees,
    MultiSelectDropdown,
    GlDropdownItem,
    GlDropdownDivider,
    GlAvatarLabeled,
    GlAvatarLink,
    GlSearchBoxByType,
    GlLoadingIcon,
  },
  props: {
    participantsQuery: {
      type: Object,
      required: true,
    },
    participantsQueryVariables: {
      type: Object,
      required: true,
    },
    updateAssigneesMutation: {
      type: Object,
      required: true,
    },
    updateAssigneesVariables: {
      type: Object,
      required: true,
    },
    initialAssignees: {
      type: Array,
      required: false,
      default: null,
    },
  },
  data() {
    return {
      search: '',
      issuable: {},
      selected: [],
      isSettingAssignees: false,
    };
  },
  apollo: {
    issuable: {
      query() {
        return this.participantsQuery;
      },
      variables() {
        return this.participantsQueryVariables;
      },
      update(data) {
        return data.issuable || data.project?.issuable;
      },
      result(res) {
        const issuable = res.data.issuable || res.data.project?.issuable;
        this.selected = cloneDeep(issuable.assignees.nodes);
      },
    },
    searchUsers: {
      query: searchUsers,
      variables() {
        return {
          search: this.search,
        };
      },
      update(data) {
        return data.users?.nodes || [];
      },
      debounce: 250,
      skip() {
        return this.isSearchEmpty;
      },
    },
  },
  computed: {
    assignees() {
      return this.issuable?.assignees?.nodes || this.initialAssignees || [];
    },
    participants() {
      return this.isSearchEmpty ? this.issuable?.participants?.nodes : this.searchUsers;
    },
    assigneeText() {
      return n__('Assignee', '%d Assignees', this.selected.length);
    },
    unselectedFiltered() {
      return this.participants
        ? this.participants.filter(({ username }) => !this.selectedUserNames.includes(username))
        : [];
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
    currentUser() {
      return gon?.current_username;
    },
  },
  created() {
    assigneesWidgetState.updateAssignees = this.updateAssignees;
  },
  destroyed() {
    assigneesWidgetState.updateAssignees = null;
  },
  methods: {
    updateAssignees(assigneeUsernames) {
      this.isSettingAssignees = true;
      return this.$apollo
        .mutate({
          mutation: this.updateAssigneesMutation,
          variables: {
            ...this.updateAssigneesVariables,
            assigneeUsernames,
          },
        })
        .then(({ data }) => {
          this.$emit('assigneesUpdated', data);
          return data;
        })
        .catch(() => {
          createFlash({ message: __('An error occurred while updating assignees.') });
        })
        .finally(() => {
          this.isSettingAssignees = false;
        });
    },
    async assignSelf() {
      const [currentUserObject] = await this.updateAssignees(this.currentUser);

      this.selectAssignee(currentUserObject);
    },
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
      this.selected = this.selected.filter((user) => user.username !== name);
    },
    saveAssignees() {
      this.updateAssignees(this.selectedUserNames);
    },
    isChecked(id) {
      return this.selectedUserNames.includes(id);
    },
  },
};
</script>

<template>
  <div
    v-if="!initialAssignees && this.$apollo.queries.issuable.loading"
    class="gl-display-flex gl-align-items-center"
  >
    {{ __('Assignee') }}
    <gl-loading-icon size="sm" class="gl-ml-2" />
  </div>
  <sidebar-editable-item
    v-else
    :loading="isSettingAssignees"
    :title="assigneeText"
    @close="saveAssignees"
  >
    <template #collapsed>
      <issuable-assignees :users="assignees" @assign-self="assignSelf" />
    </template>

    <template #default>
      <multi-select-dropdown
        class="w-100"
        :text="$options.i18n.assignees"
        :header-text="$options.i18n.assignTo"
      >
        <template #search>
          <gl-search-box-by-type v-model.trim="search" />
        </template>
        <template #items>
          <gl-loading-icon
            v-if="$apollo.queries.searchUsers.loading || $apollo.queries.issuable.loading"
            size="lg"
          />
          <template v-else>
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
                  :src="item.avatarUrl || item.avatar || item.avatar_url"
                />
              </gl-avatar-link>
            </gl-dropdown-item>
            <gl-dropdown-divider v-if="!selectedIsEmpty" data-testid="selected-user-divider" />
            <gl-dropdown-item
              v-for="unselectedUser in unselectedFiltered"
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
        </template>
      </multi-select-dropdown>
    </template>
  </sidebar-editable-item>
</template>
