<script>
import { debounce } from 'lodash';
import { GlTokenSelector, GlAvatar, GlAvatarLabeled } from '@gitlab/ui';
import { USER_SEARCH_DELAY } from '../constants';
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
      users: [],
      filteredUsers: [],
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
    placeholderText() {
      if (this.selectedTokens.length === 0) {
        return this.placeholder;
      }
      return '';
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
    this.retrieveUsers();
  },
  methods: {
    debouncedHandleTextInput() {
      return debounce(this.handleTextInput, USER_SEARCH_DELAY);
    },
    retrieveUsers() {
      this.loading = true;

      return Api.users('', this.$options.queryOptions)
        .then(response => {
          this.users = response.data.map(token => ({
            id: token.id,
            name: token.name,
            username: token.username,
            avatar_url: token.avatar_url,
          }));
          this.loading = false;
        })
        .catch(error => {
          this.loading = false;
          throw error;
        });
    },
    filterUsers() {
      if (!this.query) return this.retrieveUsers();

      this.filteredUsers = this.users
        .filter(token => {
          return (
            token.name.toLowerCase().includes(this.query.toLowerCase()) ||
            token.username.toLowerCase().includes(this.query.toLowerCase())
          );
        })
        .sort();

      return this.filteredUsers;
    },
    handleTextInput(value) {
      this.query = value;
      this.handleQueryFilter();
    },
    handleQueryFilter() {
      this.retrieveUsers();

      if (this.query) {
        this.filterUsers();
      }

      return this.filteredUusers;
    },
    handleInput() {
      this.$emit('input', this.newUsersToInvite);
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
    :hide-dropdown-with-no-items="true"
    :placeholder="placeholderText"
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
