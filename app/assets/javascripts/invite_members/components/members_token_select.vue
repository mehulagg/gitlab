<script>
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
    retrieveUsers() {
      this.loading = true;

      return Api.users(this.query, this.$options.queryOptions)
        .then(response => {
          this.filteredUsers = response.data.map(token => ({
            id: token.id,
            name: token.name,
            username: token.username,
            avatar_url: token.avatar_url,
          }));
          this.loading = false;
        })
        .catch(() => {
          return this.filteredUsers;
        });
    },
    filterUsers() {
      if (this.query === '') return this.filteredUsers;

      return this.filteredUsers
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

      return this.handleQueryFilter();
    },
    handleQueryFilter() {
      if (this.query) {
        this.filteredUsers = this.filterUsers();
        return this.filteredUsers;
      }

      return this.retrieveUsers();
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
  queryOptions: { exclude_internal: true },
};
</script>

<template>
  <gl-token-selector
    v-model="selectedTokens"
    :dropdown-items="filteredUsers"
    :loading="loading"
    :allow-user-defined-tokens="false"
    :hide-dropdown-with-no-items="false"
    :placeholder="placeholder"
    :aria-labelledby="label"
    @focus="handleQueryFilter"
    @blur="handleBlur"
    @keydown.enter="handleQueryFilter"
    @text-input="handleTextInput"
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
