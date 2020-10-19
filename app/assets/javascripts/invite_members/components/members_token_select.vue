<script>
import { debounce } from 'lodash';
import { USER_SEARCH_DELAY } from '../constants';
import { GlTokenSelector, GlAvatar, GlAvatarLabeled } from '@gitlab/ui';
import Api from '~/api';

export default {
  components: {
    GlTokenSelector,
    GlAvatar,
    GlAvatarLabeled,
  },
  props: {
    label: {
      type: String,
      required: true,
      default: '',
    },
    placeholder: {
      type: String,
      required: false,
      default: '',
    },
  },
  data() {
    return {
      loading: false,
      query: '',
      filteredUsers: [],
      users: [],
      selectedTokens: [],
    };
  },
  computed: {
    newUsersToInvite() {
      return this.selectedTokens
        .map(obj => {
          return obj.id;
        })
        .join(',');
    },
    debouncedHandleTextInput() {
      return debounce(this.handleTextInput, USER_SEARCH_DELAY);
    },
  },
  watch: {
    selectedTokens(newValue) {
      this.filteredUsers = newValue.map(token => ({
        id: token.id,
        name: token.name,
        username: token.username,
        avatar_url: token.avatar_url,
      }));
    },
  },
  created() {
    this.retrieveUsers('');
  },
  methods: {
    retrieveUsers(query) {
      this.loading = true;

      return Api.users(query, this.$options.queryOptions)
        .then(response => {
          this.users = response.data.map(token => ({
            id: token.id,
            name: token.name,
            username: token.username,
            avatar_url: token.avatar_url,
          }));
          this.loading = false;
        })
        .catch((error) => {
          this.loading = false;
          throw error;
        });
    },
    filterUsers() {
      if (this.query === '') return this.users;

      return this.users
        .filter(token => {
          return (
            token.name.toLowerCase().includes(this.query.toLowerCase()) ||
            token.username.toLowerCase().includes(this.query.toLowerCase())
          );
        })
        .sort();
    },
    handleTextInput(value) {
      this.query = value;

      if (this.query === '') {
        this.users = this.retrieveUsers('');
      } else {
        this.users = this.filterUsers(this.query);
      }

      return this.users;
    },
    handleQueryFilter() {
      if (this.query) {
        return this.filterUsers();
      }

      return this.users;
    },
    handleInput() {
      this.$emit('input', this.newUsersToInvite);
      this.filteredUsers = this.retrieveUsers(this.query);
    },
    handleBlur() {
      const textInput = this.$el.querySelector('input[type="text"]');

      textInput.value = '';
      textInput.dispatchEvent(new Event('input'));
    },
  },
  queryOptions: { exclude_internal: true, active: true },
};
</script>

<template>
  <gl-token-selector
    v-model="selectedTokens"
    :dropdown-items="users"
    :loading="loading"
    :allow-user-defined-tokens="false"
    :hide-dropdown-with-no-items="false"
    :placeholder="placeholder"
    :aria-labelledby="label"
    @focus="handleQueryFilter"
    @blur="handleBlur"
    @keydown.enter="handleQueryFilter"
    @text-input="debouncedHandleTextInput"
    @input="handleInput"
  >
    <template #token-content="{ token }">
      <gl-avatar v-if="token.avatar_url" :src="token.avatar_url" :size="16" />
      {{ token.name }}
    </template>

    <template #dropdown-item-content="{ dropdownItem }">
      <gl-avatar-labeled
        :src="dropdownItem.avatar_url"
        :size="32"
        :label="dropdownItem.name"
        :sub-label="dropdownItem.username"
      />
    </template>
  </gl-token-selector>
</template>
