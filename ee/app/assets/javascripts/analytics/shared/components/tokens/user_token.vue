<script>
import {
  GlAvatar,
  GlFilteredSearchToken,
  GlFilteredSearchSuggestion,
  GlLoadingIcon,
} from '@gitlab/ui';
import { debounce } from 'lodash';
import { DEBOUNCE_DELAY } from '~/vue_shared/components/filtered_search_bar/constants';

export default {
  components: {
    GlAvatar,
    GlFilteredSearchToken,
    GlFilteredSearchSuggestion,
    GlLoadingIcon,
  },
  inheritAttrs: false,
  props: {
    config: {
      type: Object,
      required: true,
    },
    value: {
      type: Object,
      required: true,
    },
  },
  computed: {
    selectedUser() {
      return this.value?.data
        ? this.config.users.find(({ username }) => username === this.value.data)
        : {};
    },
  },
  created() {
    this.searchUsers(this.value);
  },
  methods: {
    searchUsers: debounce(function debouncedSearch({ data = '' }) {
      this.config.fetchData(data);
    }, DEBOUNCE_DELAY),
  },

  emits: [],
};
</script>
<template>
  <gl-filtered-search-token
    :config="config"
    v-bind="{ ...$props, ...$attrs }"
    v-on="$listeners"
    @input="searchUsers"
  >
    <template #view="{ inputValue }">
      <div v-if="selectedUser" data-testid="selected-user">
        <gl-avatar :size="16" :src="selectedUser.avatar_url" />
        <span>{{ inputValue }}</span>
      </div>
    </template>
    <template #suggestions>
      <gl-loading-icon v-if="config.isLoading" />
      <template v-else>
        <gl-filtered-search-suggestion
          v-for="user in config.users"
          :key="user.username"
          :value="user.username"
          data-testid="user-item"
        >
          <div class="d-flex">
            <gl-avatar :size="32" :src="user.avatar_url" />
            <div>
              <div>{{ user.name }}</div>
              <div>@{{ user.username }}</div>
            </div>
          </div>
        </gl-filtered-search-suggestion>
      </template>
    </template>
  </gl-filtered-search-token>
</template>
