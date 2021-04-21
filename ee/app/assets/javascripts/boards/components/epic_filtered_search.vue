<script>
import { mapActions, mapState } from 'vuex';
import { updateHistory, setUrlParams } from '~/lib/utils/url_utility';
import { __ } from '~/locale';
import FilteredSearch from '~/vue_shared/components/filtered_search_bar/filtered_search_bar_root.vue';
import AuthorToken from '~/vue_shared/components/filtered_search_bar/tokens/author_token.vue';
import LabelToken from '~/vue_shared/components/filtered_search_bar/tokens/label_token.vue';
import groupLabelsQuery from '../graphql/group_labels.query.graphql';
import groupUsersQuery from '../graphql/group_members.query.graphql';

export default {
  i18n: {
    search: __('Search'),
    label: __('Label'),
    author: __('Author'),
  },
  components: { FilteredSearch },
  inject: ['initialFilterParams'],
  data() {
    return {
      filterParams: this.initialFilterParams,
    };
  },
  computed: {
    ...mapState(['fullPath']),
    tokens() {
      return [
        {
          icon: 'labels',
          title: this.$options.i18n.label,
          type: 'label_name',
          operators: [{ value: '=', description: 'is' }],
          token: LabelToken,
          unique: false,
          symbol: '~',
          fetchLabels: this.fetchLabels,
        },
        {
          icon: 'pencil',
          title: this.$options.i18n.author,
          type: 'author_username',
          operators: [{ value: '=', description: 'is' }],
          symbol: '@',
          token: AuthorToken,
          unique: true,
          fetchAuthors: this.fetchAuthors,
        },
      ];
    },
    urlParams() {
      const { authorUsername, labelName, search } = this.filterParams;

      return {
        author_username: authorUsername,
        'label_name[]': labelName,
        search,
      };
    },
  },
  methods: {
    ...mapActions(['performSearch']),
    getFilteredSearchValue() {
      const { authorUsername, labelName, search } = this.filterParams;
      const filteredSearchValue = [];

      if (authorUsername) {
        filteredSearchValue.push({
          type: 'author_username',
          value: { data: authorUsername },
        });
      }

      if (labelName?.length) {
        filteredSearchValue.push(
          ...labelName.map((label) => ({
            type: 'label_name',
            value: { data: label },
          })),
        );
      }

      if (search) {
        filteredSearchValue.push(search);
      }

      return filteredSearchValue;
    },
    getFilterParams(filters = []) {
      const filterParams = {};
      const labels = [];
      const plainText = [];

      filters.forEach((filter) => {
        switch (filter.type) {
          case 'author_username':
            filterParams.authorUsername = filter.value.data;
            break;
          case 'label_name':
            labels.push(filter.value.data);
            break;
          case 'filtered-search-term':
            if (filter.value.data) plainText.push(filter.value.data);
            break;
          default:
            break;
        }
      });

      if (labels.length) {
        filterParams.labelName = labels;
      }

      if (plainText.length) {
        filterParams.search = plainText.join(' ');
      }
      return filterParams;
    },
    fetchAuthors(authorsSearchTerm) {
      return this.$apollo
        .query({
          query: groupUsersQuery,
          variables: {
            fullPath: this.fullPath,
            search: authorsSearchTerm,
          },
        })
        .then(({ data }) => data.group?.groupMembers.nodes.map((item) => item.user));
    },
    fetchLabels(labelSearchTerm) {
      return this.$apollo
        .query({
          query: groupLabelsQuery,
          variables: {
            fullPath: this.fullPath,
            search: labelSearchTerm,
          },
        })
        .then(({ data }) => data.group?.labels.nodes || []);
    },
    handleFilterEpics(filters) {
      this.filterParams = this.getFilterParams(filters);
      updateHistory({
        url: setUrlParams(this.urlParams, window.location.href, true, false, true),
        title: document.title,
        replace: true,
      });

      this.performSearch();
    },
  },
};
</script>

<template>
  <filtered-search
    data-testid="epic-filtered-search"
    class="gl-w-full"
    namespace=""
    :tokens="tokens"
    :search-input-placeholder="$options.i18n.search"
    :initial-filter-value="getFilteredSearchValue()"
    @onFilter="handleFilterEpics"
  />
</template>
