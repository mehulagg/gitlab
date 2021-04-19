<script>
import BoardFilteredSearch from '~/boards/components/board_filtered_search.vue';
import { __ } from '~/locale';
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
  components: { BoardFilteredSearch },
  inject: ['fullPath'],
  computed: {
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
  },
  methods: {
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
  },
};
</script>

<template>
  <board-filtered-search :tokens="tokens" />
</template>
