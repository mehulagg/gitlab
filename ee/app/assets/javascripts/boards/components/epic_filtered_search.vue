<script>
import { mapActions, mapState } from 'vuex';
import { historyPushState } from '~/lib/utils/common_utils';
import { setUrlParams } from '~/lib/utils/url_utility';
import { __ } from '~/locale';
import FilteredSearch from '~/vue_shared/components/filtered_search_bar/filtered_search_bar_root.vue';
import AuthorToken from '~/vue_shared/components/filtered_search_bar/tokens/author_token.vue';
import LabelToken from '~/vue_shared/components/filtered_search_bar/tokens/label_token.vue';
import groupLabelsQuery from '../graphql/group_labels.query.graphql';
import groupUsersQuery from '../graphql/group_members.query.graphql';

export default {
  i18n: {
    search: __('Search'),
  },
  components: { FilteredSearch },
  inject: ['search'],
  computed: {
    ...mapState(['fullPath']),
    initialSearch() {
      return [{ type: 'filtered-search-term', value: { data: this.search } }];
    },
    tokens() {
      return [
        {
          icon: 'labels',
          title: __('Label'),
          type: 'labels',
          operators: [{ value: '=', description: 'is' }],
          token: LabelToken,
          unique: false,
          symbol: '~',
          fetchLabels: this.fetchLabels,
        },
        {
          icon: 'pencil',
          title: __('Author'),
          type: 'author',
          operators: [{ value: '=', description: 'is' }],
          symbol: '@',
          token: AuthorToken,
          unique: true,
          fetchAuthors: this.fetchAuthors,
        },
      ];
    },
  },
  methods: {
    ...mapActions(['performSearch']),
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
    handleSearch(filters = []) {
      const [item] = filters;
      const search = item?.value?.data || '';

      historyPushState(setUrlParams({ search }));

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
    :initial-filter-value="initialSearch"
    @onFilter="handleSearch"
  />
</template>
