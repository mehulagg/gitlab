<script>
import { debounce } from 'lodash';
import { GlTokenSelector, GlAvatar, GlAvatarLabeled } from '@gitlab/ui';
import { USER_SEARCH_DELAY } from '../constants';
import axios from '~/lib/utils/axios_utils';
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
  methods: {
    handleTextInput(query) {
      this.query = query;
      this.loading = true;
      this.retrieveUsers(query);
    },
    retrieveUsers: debounce(function debouncedRetrieveUsers() {
      return axios
        .get(this.$options.apiUrl, {
          params: { ...this.$options.queryOptions, search: this.query },
        })
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
    }, USER_SEARCH_DELAY),
    handleInput() {
      this.$emit('input', this.newUsersToInvite);
    },
    handleBlur() {
      const textInput = this.$el.querySelector('input[type="text"]');

      textInput.value = '';
      textInput.dispatchEvent(new Event('input'));
    },
    handleFocus() {
      this.loading = true;
      this.retrieveUsers();
    },
  },
  queryOptions: { exclude_internal: true, active: true },
  apiUrl: `${gon.relative_url_root.replace(/\/$/, '')}/-/autocomplete/users.json`,
};
</script>

<template>
  <gl-token-selector
    v-model="selectedTokens"
    :dropdown-items="users"
    :loading="loading"
    :allow-user-defined-tokens="false"
    :placeholder="placeholderText"
    :aria-labelledby="label"
    @blur="handleBlur"
    @text-input="handleTextInput"
    @input="handleInput"
    @focus="handleFocus"
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
