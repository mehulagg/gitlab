<script>
import { mapActions } from 'vuex';
import { historyPushState } from '~/lib/utils/common_utils';
import { setUrlParams } from '~/lib/utils/url_utility';
import { __ } from '~/locale';
import FilteredSearch from '~/vue_shared/components/filtered_search_bar/filtered_search_bar_root.vue';
import LabelToken from './label_token.vue';

export default {
  i18n: {
    search: __('Search'),
  },
  components: { FilteredSearch },
  inject: ['search'],
  computed: {
    initialSearch() {
      return [{ type: 'filtered-search-term', value: { data: this.search } }];
    },
  },
  methods: {
    ...mapActions(['performSearch']),
    tokens() {
      return [];
    },
    handleSearch(filters = []) {
      const [item] = filters;
      const search = item?.value?.data || '';

      historyPushState(setUrlParams({ search }));

      this.performSearch();
    },
    tokens() {
      return [
        {
          icon: 'labels',
          title: __('Label'),
          type: 'labels',
          operators: [
            { value: '=', description: 'is' },
            { value: '!=', description: 'is not' }, // backend not ready yet..
          ],
          token: LabelToken,
          unique: true,
          symbol: '~',
        },
      ];
    },
  },
};
</script>

<template>
  <filtered-search
    class="gl-w-full"
    namespace=""
    :tokens="tokens()"
    :search-input-placeholder="$options.i18n.search"
    :initial-filter-value="initialSearch"
    @onFilter="handleSearch"
  />
</template>
