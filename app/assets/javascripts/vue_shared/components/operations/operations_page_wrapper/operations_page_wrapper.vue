<script>
import Api from '~/api';
import { __ } from '~/locale';
import { urlParamsToObject } from '~/lib/utils/common_utils';
import {
  updateHistory,
  setUrlParams,
} from '~/lib/utils/url_utility';
import AuthorToken from '~/vue_shared/components/filtered_search_bar/tokens/author_token.vue';

export default {
  components: {},
  data() {
    return {
      searchTerm: '',
      authorUsername: '',
      assigneeUsernames: '',
      filterParams: {},
    };
  },
  computed: {
  filteredSearchTokens() {
      return [
        {
          type: 'author_username',
          icon: 'user',
          title: __('Author'),
          unique: true,
          symbol: '@',
          token: AuthorToken,
          operators: [{ value: '=', description: __('is'), default: 'true' }],
          fetchPath: this.projectPath,
          fetchAuthors: Api.projectUsers.bind(Api),
        },
        {
          type: 'assignee_username',
          icon: 'user',
          title: __('Assignees'),
          unique: true,
          symbol: '@',
          token: AuthorToken,
          operators: [{ value: '=', description: __('is'), default: 'true' }],
          fetchPath: this.projectPath,
          fetchAuthors: Api.projectUsers.bind(Api),
        },
      ];
    },
    filteredSearchValue() {
      const value = [];

      if (this.authorUsername) {
        value.push({
          type: 'author_username',
          value: { data: this.authorUsername },
        });
      }

      if (this.assigneeUsernames) {
        value.push({
          type: 'assignee_username',
          value: { data: this.assigneeUsernames },
        });
      }

      if (this.searchTerm) {
        value.push(this.searchTerm);
      }

      return value;
    },
  },
  methods: {
    handleFilterIncidents(filters) {
      this.resetPagination();
      const filterParams = { authorUsername: '', assigneeUsername: '', search: '' };

      filters.forEach(filter => {
        if (typeof filter === 'object') {
          switch (filter.type) {
            case 'author_username':
              filterParams.authorUsername = filter.value.data;
              break;
            case 'assignee_username':
              filterParams.assigneeUsername = filter.value.data;
              break;
            case 'filtered-search-term':
              if (filter.value.data !== '') filterParams.search = filter.value.data;
              break;
            default:
              break;
          }
        }
      });

      this.filterParams = filterParams;
      this.updateUrl();
      this.searchTerm = filterParams?.search;
      this.authorUsername = filterParams?.authorUsername;
      this.assigneeUsernames = filterParams?.assigneeUsername;
    },
    updateUrl() {
      const queryParams = urlParamsToObject(window.location.search);
      const { authorUsername, assigneeUsername, search } = this.filterParams || {};

      if (authorUsername) {
        queryParams.author_username = authorUsername;
      } else {
        delete queryParams.author_username;
      }

      if (assigneeUsername) {
        queryParams.assignee_username = assigneeUsername;
      } else {
        delete queryParams.assignee_username;
      }

      if (search) {
        queryParams.search = search;
      } else {
        delete queryParams.search;
      }

      updateHistory({
        url: setUrlParams(queryParams, window.location.href, true),
        title: document.title,
        replace: true,
      });
    },
  },
};
</script>
<template>
  <div class="incident-management-list">
    <slot v-if="!loading" name="alert"></slot>

    <slot v-if="!loading" name="header"></slot>

    <slot v-if="!loading" name="filter"></slot>

    <slot v-if="!loading" name="title"></slot>
    
    <slot v-if="!loading" name="table"></slot>

    <slot v-if="!loading" name="emtpy-state"></slot>

    <slot v-if="!loading" name="pagination"></slot>
  </div>
</template>
