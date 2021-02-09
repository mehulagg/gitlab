<script>
import { GlFilteredSearchToken } from '@gitlab/ui';
import { mapActions, mapGetters } from 'vuex';
import { s__, __ } from '~/locale';
import MilestoneToken from '~/vue_shared/components/filtered_search_bar/tokens/milestone_token.vue';
import LabelToken from '~/vue_shared/components/filtered_search_bar/tokens/label_token.vue';
import FilteredSearch from '~/vue_shared/components/filtered_search_bar/filtered_search_bar_root.vue';
import { setUrlParams, queryToObject } from '~/lib/utils/url_utility';
import { historyPushState } from '~/lib/utils/common_utils';

export default {
  components: { GlFilteredSearchToken, FilteredSearch },
  props: {
    search: {
      type: String,
      required: false,
      default: '',
    },
    inputAttrs: {
      type: Object,
      required: true,
    },
  },
  data() {
    return {
      val: [],
    };
  },
  computed: {
    ...mapGetters(['isSwimlanesOn']),
  },
  methods: {
    ...mapActions(['setFilters', 'performSearch']),
    handleSearch(filters) {
      let itemValue = '';

      const [item] = filters; // change how this is done

      if (filters.length === 0) {
        itemValue = '';
      } else {
        itemValue = item?.value?.data;
      }
      // set history too.
      historyPushState(setUrlParams({ search: itemValue }, window.location.href));
      this.performSearch();
    },
  },
};
</script>

<template>
  <filtered-search
    v-if="isSwimlanesOn"
    @onFilter="handleSearch"
    class="gl-w-full"
    namespace=""
    :tokens="[]"
    :search-input-placeholder="'Search'"
    :initial-filter-value="[{ type: 'filtered-search-term', value: { data: search } }]"
  />
  <ul v-else class="tokens-container list-unstyled">
    <li class="input-token">
      <input
        v-bind="inputAttrs"
        data-dropdown-trigger="#js-dropdown-hint"
        class="form-control filtered-search"
      />
    </li>
  </ul>
</template>
