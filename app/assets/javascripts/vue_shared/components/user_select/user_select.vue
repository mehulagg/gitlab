<script>
import {
  GlDropdown,
  GlDropdownForm,
  GlDropdownDivider,
  GlSearchBoxByType,
  GlDropdownItem,
  GlLoadingIcon,
} from '@gitlab/ui';
import searchUsers from '~/graphql_shared/queries/users_search.query.graphql';
import { __ } from '~/locale';
import SidebarParticipant from '~/sidebar/components/assignees/sidebar_participant.vue';
import { ASSIGNEES_DEBOUNCE_DELAY } from '~/sidebar/constants';
import issueParticipantsQuery from '~/vue_shared/components/sidebar/queries/get_issue_participants.query.graphql';

export default {
  i18n: {
    unassigned: __('Unassigned'),
  },
  components: {
    GlDropdownForm,
    GlDropdown,
    GlDropdownDivider,
    GlSearchBoxByType,
    GlDropdownItem,
    SidebarParticipant,
    GlLoadingIcon,
  },
  props: {
    headerText: {
      type: String,
      required: true,
    },
    text: {
      type: String,
      required: true,
    },
    fullPath: {
      type: String,
      required: true,
    },
    iid: {
      type: String,
      required: true,
    },
    value: {
      type: Array,
      required: true,
    },
    multipleAssignees: {
      type: Boolean,
      required: false,
      default: false,
    },
    currentUser: {
      type: Object,
      required: true,
    },
  },
  data() {
    return {
      search: '',
      participants: [],
      searchUsers: [],
      isSearching: false,
    };
  },
  apollo: {
    participants: {
      query() {
        return issueParticipantsQuery;
      },
      variables() {
        return {
          iid: this.iid,
          fullPath: this.fullPath,
        };
      },
      update(data) {
        return data.workspace?.issuable?.participants.nodes;
      },
      error() {
        this.$emit('error');
      },
    },
    searchUsers: {
      query: searchUsers,
      variables() {
        return {
          fullPath: this.fullPath,
          search: this.search,
          first: 20,
        };
      },
      update(data) {
        return data.workspace?.users?.nodes.map(({ user }) => user) || [];
      },
      debounce: ASSIGNEES_DEBOUNCE_DELAY,
      error() {
        this.$emit('error');
        this.isSearching = false;
      },
      result() {
        this.isSearching = false;
      },
    },
  },
  computed: {
    isLoading() {
      return this.$apollo.queries.searchUsers.loading;
    },
    users() {
      const mergedSearchResults = this.participants.reduce((acc, current) => {
        if (
          !acc.some((user) => current.username === user.username) &&
          (current.name.includes(this.search) || current.username.includes(this.search))
        ) {
          acc.push(current);
        }
        return acc;
      }, this.searchUsers);
      return this.moveCurrentUserToStart(mergedSearchResults);
    },
    isSearchEmpty() {
      return this.search === '';
    },
    isCurrentUserInList() {
      const isCurrentUser = (user) => user.username === this.currentUser.username;
      return this.users.some(isCurrentUser);
    },
    noUsersFound() {
      return !this.isSearchEmpty && this.users.length === 0;
    },
    showCurrentUser() {
      return (
        this.currentUser.username &&
        !this.isCurrentUserInList &&
        (this.isSearchEmpty || this.isSearching)
      );
    },
    selectedFiltered() {
      if (this.isSearchEmpty || this.isSearching) {
        return this.moveCurrentUserToStart(this.value);
      }

      const foundUsernames = this.users.map(({ username }) => username);
      const filtered = this.value.filter(({ username }) => foundUsernames.includes(username));
      return this.moveCurrentUserToStart(filtered);
    },
    selectedUserNames() {
      return this.value.map(({ username }) => username);
    },
    unselectedFiltered() {
      return this.users?.filter(({ username }) => !this.selectedUserNames.includes(username)) || [];
    },
    selectedIsEmpty() {
      return this.selectedFiltered.length === 0;
    },
  },
  watch: {
    // We need to add this watcher to track the moment when user is alredy typing
    // but query is still not started due to debounce
    search(newVal) {
      if (newVal) {
        this.isSearching = true;
      }
    },
  },
  methods: {
    selectAssignee(name) {
      let selected = [...this.value];
      if (!this.multipleAssignees) {
        selected = [name];
      } else {
        selected.push(name);
      }
      this.$emit('input', selected);
    },
    unselect(name) {
      const selected = this.value.filter((user) => user.username !== name);
      this.$emit('input', selected);
    },
    focusSearch() {
      this.$refs.search.focusInput();
    },
    showDivider(list) {
      return list.length > 0 && this.isSearchEmpty;
    },
    moveCurrentUserToStart(users) {
      if (!users) {
        return [];
      }
      const usersCopy = [...users];
      const currentUser = usersCopy.find((user) => user.username === this.currentUser.username);

      if (currentUser) {
        const index = usersCopy.indexOf(currentUser);
        usersCopy.splice(0, 0, usersCopy.splice(index, 1)[0]);
      }

      return usersCopy;
    },
  },
};
</script>

<template>
  <gl-dropdown class="show" :text="text">
    <template #header>
      <p class="gl-font-weight-bold gl-text-center gl-mt-2 gl-mb-4">{{ headerText }}</p>
      <gl-dropdown-divider />
      <gl-search-box-by-type ref="search" v-model.trim="search" class="js-dropdown-input-field" />
    </template>
    <gl-dropdown-form>
      <gl-loading-icon v-if="isLoading" data-testid="loading-participants" size="lg" />
      <template v-else>
        <template v-if="isSearchEmpty || isSearching">
          <gl-dropdown-item
            :is-checked="selectedIsEmpty"
            :is-check-centered="true"
            data-testid="unassign"
            @click="$emit('input', [])"
          >
            <span :class="selectedIsEmpty ? 'gl-pl-0' : 'gl-pl-6'" class="gl-font-weight-bold">{{
              $options.i18n.unassigned
            }}</span></gl-dropdown-item
          >
        </template>
        <gl-dropdown-divider v-if="showDivider(selectedFiltered)" />
        <gl-dropdown-item
          v-for="item in selectedFiltered"
          :key="item.id"
          is-checked
          is-check-centered
          data-testid="selected-participant"
          @click.stop="unselect(item.username)"
        >
          <sidebar-participant :user="item" />
        </gl-dropdown-item>
        <template v-if="showCurrentUser">
          <gl-dropdown-divider />
          <gl-dropdown-item data-testid="current-user" @click.stop="selectAssignee(currentUser)">
            <sidebar-participant :user="currentUser" class="gl-pl-6!" />
          </gl-dropdown-item>
        </template>
        <gl-dropdown-divider v-if="showDivider(unselectedFiltered)" />
        <gl-dropdown-item
          v-for="unselectedUser in unselectedFiltered"
          :key="unselectedUser.id"
          data-testid="unselected-participant"
          @click="selectAssignee(unselectedUser)"
        >
          <sidebar-participant :user="unselectedUser" class="gl-pl-6!" />
        </gl-dropdown-item>
        <gl-dropdown-item
          v-if="noUsersFound && !isSearching"
          data-testid="empty-results"
          class="gl-pl-6!"
        >
          {{ __('No matching results') }}
        </gl-dropdown-item>
      </template>
    </gl-dropdown-form>
    <template #footer>
      <slot name="footer"></slot>
    </template>
  </gl-dropdown>
</template>
