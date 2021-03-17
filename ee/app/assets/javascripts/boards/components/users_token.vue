<script>
import {
  GlToken,
  GlFilteredSearchToken,
  GlFilteredSearchSuggestion,
  GlDropdownDivider,
  GlLoadingIcon,
  GlAvatar,
} from '@gitlab/ui';
import { deprecatedCreateFlash as createFlash } from '~/flash';
import { convertObjectPropsToCamelCase } from '~/lib/utils/common_utils';
import { __ } from '~/locale';

import GroupUsersQuery from '../graphql/group_members.query.graphql';
import { stripQuotes } from '~/vue_shared/components/filtered_search_bar/filtered_search_utils';

export default {
  avatarSize: 16,
  components: {
    GlToken,
    GlFilteredSearchToken,
    GlFilteredSearchSuggestion,
    GlDropdownDivider,
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
  // sub group
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
    <template #view-token="{ inputValue, cssClasses, listeners }">
      <gl-token variant="search-value" :class="cssClasses" v-on="listeners">
        <gl-avatar :size="$options.avatarSize" :src="activeUsers.avatarUrl" />{{
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
          <div class="d-flex">
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
