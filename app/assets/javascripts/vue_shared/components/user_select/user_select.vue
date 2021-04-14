<script>
import {
  GlDropdown,
  GlDropdownForm,
  GlDropdownDivider,
  GlSearchBoxByType,
  GlDropdownItem,
} from '@gitlab/ui';
import searchUsers from '~/graphql_shared/queries/users_search.query.graphql';
import issueParticipantsQuery from '~/vue_shared/components/sidebar/queries/get_issue_participants.query.graphql';
import { ASSIGNEES_DEBOUNCE_DELAY } from '~/sidebar/constants';
import { __ } from '~/locale';
import SidebarParticipant from '~/sidebar/components/assignees/sidebar_participant.vue';

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
  },
  data() {
    return {
      search: '',
      users: [],
      searchUsers,
      isSearching: false,
    };
  },
  apollo: {
    users: {
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
        };
      },
      update(data) {
        const searchResults = data.workspace?.users?.nodes.map(({ user }) => user) || [];
        const mergedSearchResults = this.users.reduce((acc, current) => {
          if (
            !acc.some((user) => current.username === user.username) &&
            (current.name.includes(this.search) || current.username.includes(this.search))
          ) {
            acc.push(current);
          }
          return acc;
        }, searchResults);
        return mergedSearchResults;
      },
      debounce: ASSIGNEES_DEBOUNCE_DELAY,
      skip() {
        return this.isSearchEmpty;
      },
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
    isSearchEmpty() {
      return this.search === '';
    },
    currentUser() {
      return {
        username: gon?.current_username,
        name: gon?.current_user_fullname,
        avatarUrl: gon?.current_user_avatar_url,
      };
    },
    isCurrentUserInList() {
      const isCurrentUser = (user) => user.username === this.currentUser.username;
      return this.users.some(isCurrentUser);
    },
    noUsersFound() {
      return !this.isSearchEmpty && this.users.length === 0;
    },
    signedIn() {
      return this.currentUser.username !== undefined;
    },
    showCurrentUser() {
      return (
        this.signedIn &&
        !this.isCurrentUserInParticipants &&
        (this.isSearchEmpty || this.isSearching)
      );
    },
    selectedFiltered() {
      if (this.isSearchEmpty || this.isSearching) {
        return this.value;
      }

      const foundUsernames = this.users.map(({ username }) => username);
      return this.value.filter(({ username }) => foundUsernames.includes(username));
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
            @click="this.$emit('input', [])"
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
