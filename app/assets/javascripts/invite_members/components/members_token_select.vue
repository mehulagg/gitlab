<script>
import { GlTokenSelector, GlAvatar } from '@gitlab/ui';
import Api from '~/api';

export default {
  components: {
    GlTokenSelector,
    GlAvatar,
  },
  props: {
    groupId: {
      type: Number,
      required: false,
      default: 0,
    },
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
      hideErrorMessage: false,
      allowUserDefined: false,
      query: '',
      queryOptions: { exclude_internal: true },
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

      return Api.users(this.query, this.queryOptions)
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
      this.$children.find(() => 'textInput').inputText = '';
    },
  },
};
</script>

<template>
  <gl-token-selector
    v-model="selectedTokens"
    :dropdown-items="filteredUsers"
    :loading="loading"
    :allow-user-defined-tokens="allowUserDefined"
    :hide-dropdown-with-no-items="hideErrorMessage"
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
      <div class="gl-display-flex">
        <gl-avatar :src="dropdownItem.avatar_url" :size="32" />
        <div>
          <p class="gl-m-0">{{ dropdownItem.name }}</p>
          <p class="gl-m-0 gl-text-gray-700">{{ dropdownItem.username }}</p>
        </div>
      </div>
    </template>
  </gl-token-selector>
</template>
