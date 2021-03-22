<script>
import {
  GlToken,
  GlFilteredSearchToken,
  GlFilteredSearchSuggestion,
  GlLoadingIcon,
  GlAvatar,
} from '@gitlab/ui';
import { stripQuotes } from '~/vue_shared/components/filtered_search_bar/filtered_search_utils';
import GroupUsersQuery from '../graphql/group_members.query.graphql';

export default {
  components: {
    GlToken,
    GlFilteredSearchToken,
    GlFilteredSearchSuggestion,
    GlLoadingIcon,
    GlAvatar,
  },
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
  apollo: {
    users: {
      query: GroupUsersQuery,
      debounce: 250,
      variables() {
        return {
          fullPath: this.config.fullPath,
          search: this.search,
        };
      },
      update(data) {
        return data.group.groupMembers.nodes.map((item) => item.user);
      },
    },
  },
  data() {
    return {
      users: [],
      search: '',
    };
  },
  // current user on top only on page load
  // ticket on load populates search with pills
  // should users be able to search label from value not in dropdown?
  computed: {
    currentValue() {
      return this.value.data.toLowerCase();
    },
    activeUsers() {
      return this.users.find(
        (label) => label.username.toLowerCase() === stripQuotes(this.currentValue),
      );
    },
  },
  methods: {
    searchForToken(searchTerm) {
      this.search = searchTerm?.data;
    },
  },
};
</script>

<template>
  <gl-filtered-search-token
    :config="config"
    v-bind="{ ...$props, ...$attrs }"
    v-on="$listeners"
    @input="searchForToken"
  >
    <template #view-token="{ listeners }">
      <gl-token variant="search-value" v-on="listeners">
        <gl-avatar :size="16" :src="activeUsers.avatarUrl" />{{
          activeUsers.username
        }}</gl-token
      >
    </template>
    <template #suggestions>
      <gl-loading-icon v-if="$apollo.loading" />
      <template v-else>
        <gl-filtered-search-suggestion
          v-for="author in users"
          :key="author.username"
          :value="author.username"
        >
          <div class="gl-display-flex">
            <gl-avatar :size="32" :src="author.avatarUrl" />
            <div>
              <div>{{ author.name }}</div>
              <div>@{{ author.username }}</div>
            </div>
          </div>
        </gl-filtered-search-suggestion>
      </template>
    </template>
  </gl-filtered-search-token>
</template>
