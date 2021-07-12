<script>
import BoardFilteredSearch from '~/boards/components/board_filtered_search.vue';
import { TYPE_USER } from '~/graphql_shared/constants';
import { convertToGraphQLId } from '~/graphql_shared/utils';
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
    is: __('is'),
    isNot: __('is not'),
  },
  components: { BoardFilteredSearch },
  inject: ['fullPath'],
  computed: {
    tokens() {
      const { label, is, isNot, author } = this.$options.i18n;
      return [
        {
          icon: 'labels',
          title: label,
          type: 'label_name',
          operators: [
            { value: '=', description: is },
            { value: '!=', description: isNot },
          ],
          token: LabelToken,
          unique: false,
          // eslint-disable-next-line @gitlab/require-i18n-strings
          defaultLabels: [{ value: 'No label', text: __('No label') }],
          fetchLabels: this.fetchLabels,
        },
        {
          icon: 'pencil',
          title: author,
          type: 'author_username',
          operators: [
            { value: '=', description: is },
            { value: '!=', description: isNot },
          ],
          symbol: '@',
          token: AuthorToken,
          unique: true,
          fetchAuthors: this.fetchAuthors,
          preloadedAuthors: this.preloadedAuthors(),
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
        .then(({ data }) =>
          data.group?.groupMembers.nodes.filter((x) => x?.user).map(({ user }) => user),
        );
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
    preloadedAuthors() {
      return gon?.current_user_id
        ? [
            {
              id: convertToGraphQLId(TYPE_USER, gon.current_user_id),
              name: gon.current_user_fullname,
              username: gon.current_username,
              avatarUrl: gon.current_user_avatar_url,
            },
          ]
        : [];
    },
  },
};
</script>

<template>
  <board-filtered-search data-testid="epic-filtered-search" :tokens="tokens" />
</template>
