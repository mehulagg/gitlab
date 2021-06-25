<script>
import {
  GlDropdown,
  GlDropdownItem,
  GlSearchBoxByType,
  GlTokenSelector,
  GlAvatar,
  GlAvatarLabeled,
  GlAvatarLink,
} from '@gitlab/ui';
import searchProjectMembersQuery from '~/graphql_shared/queries/project_user_members_search.query.graphql';
import { s__, __ } from '~/locale';

export default {
  components: {
    GlDropdown,
    GlDropdownItem,
    GlSearchBoxByType,
    GlTokenSelector,
    GlAvatar,
    GlAvatarLabeled,
    GlAvatarLink,
  },
  inject: ['projectPath'],

  i18n: {
    placeholder: s__('EscalationPolicies|Search for user'),
    noResults: __('No matching results'),
  },
  apollo: {
    users: {
      query: searchProjectMembersQuery,
      variables() {
        return {
          fullPath: this.projectPath,
          search: this.search,
        };
      },
      update({ project: { projectMembers: { nodes = [] } = {} } = {} } = {}) {
        return nodes.filter((x) => x?.user).map(({ user }) => ({ ...user }));
      },
      error(error) {
        this.error = error;
      },
      debounce: 250,
    },
  },
  data() {
    return {
      users: [],
      user: {},
      selectedUsers: [],
      search: '',
      show: false,
    };
  },
  computed: {
    userListId() {
      return this.strategy?.userList?.id ?? '';
    },
    dropdownText() {
      return this.strategy?.userList?.name ?? this.$options.translations.defaultDropdownText;
    },
    loading() {
      return this.$apollo.queries.users.loading;
    },
    placeholderText() {
      return this.selectedUsers.length ? '' : this.$options.i18n.placeholder;
    },
  },
  methods: {
    onUserListChange(list) {
      this.$emit('change', {
        userList: list,
      });
    },
    isSelectedUserList({ id }) {
      return id === this.userListId;
    },
    filterUsers(searchTerm) {
      this.search = searchTerm;
    },
    setSelectedUser(user) {
      if (user.id === this.user.id) {
        this.user = null;
      } else {
        this.user = user;
      }
      this.$emit('select-user', this.user);
    },
    setFocus(e) {
      if (this.selectedUsers.length) {
        e.prevetDefault();
      }
    },
    isSelected(userId) {
      return this.user.id === userId;
    },
    showDropdown() {
      // this.$refs.dropdown.show();
      this.show = true;
    },
    hideDropdown() {
      // this.$refs.dropdown.hide();
      this.show = false;
    },
    emitSelectedUser() {
      this.$emit('select-user', this.user);
    },
  },
};
</script>
<template>
  <gl-token-selector
    v-model="selectedUsers"
    :dropdown-items="users"
    :loading="loading"
    :placeholder="placeholderText"
    @text-input="filterUsers"
    @blur="emitSelectedUser"
    @input="emitSelectedUser"
    @focus="setFocus"
  >
    <template #token-content="{ token }">
      <gl-avatar v-if="token.avatarUrl" :src="token.avatarUrl" :size="16" />
      {{ token.name }}
    </template>
    <template #dropdown-item-content="{ dropdownItem }">
      <gl-avatar-labeled
        :src="dropdownItem.avatarUrl"
        :size="32"
        :label="dropdownItem.name"
        :sub-label="dropdownItem.username"
      />
    </template>
  </gl-token-selector>
  <!--  <div>
    <gl-dropdown :aria-label="$options.i18n.placeholder"
                 :text="user.name || $options.i18n.placeholder"
                 :header-text="$options.i18n.placeholder">
      <gl-search-box-by-type @focus="showDropdown" @blur="hideDropdown" v-model="search"/>
      <gl-dropdown-item
        v-for="user in users"
        :key="user.id"
        :is-checked="isSelected(user.id)"
        is-check-item
        @click="setSelectedUser(user)"
      >
        <gl-avatar-link target="blank" :href="user.avatarUrl">
          <gl-avatar-labeled
            :size="32"
            :entity-name="user.name"
            :label="user.name"
            :sub-label="user.username"
          />
        </gl-avatar-link>
      </gl-dropdown-item>
      <gl-dropdown-item v-if="!users.length">
        {{ $options.i18n.noResults }}
      </gl-dropdown-item>
    </gl-dropdown>
  </div>-->
</template>
