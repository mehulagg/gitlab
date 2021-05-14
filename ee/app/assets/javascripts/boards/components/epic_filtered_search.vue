<script>
import BoardFilteredSearch from '~/boards/components/board_filtered_search.vue';
import issueBoardFilter from '~/boards/issue_board_filters';
import { __ } from '~/locale';
import AuthorToken from '~/vue_shared/components/filtered_search_bar/tokens/author_token.vue';
import LabelToken from '~/vue_shared/components/filtered_search_bar/tokens/label_token.vue';

export default {
  i18n: {
    search: __('Search'),
    label: __('Label'),
    author: __('Author'),
    is: __('is'),
    isNot: __('is not'),
  },
  components: { BoardFilteredSearch },
  props: {
    fullPath: {
      required: true,
    },
    boardType: {
      required: true,
    }
  },
  computed: {
    tokens() {
      const { fetchLabels, fetchAuthors } = issueBoardFilter(this.$apollo, this.fullPath, this.boardType);

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
          symbol: '~',
          fetchLabels,
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
          fetchAuthors,
        },
      ];
    },
  }
};
</script>

<template>
  <board-filtered-search data-testid="epic-filtered-search" :tokens="tokens" />
</template>
