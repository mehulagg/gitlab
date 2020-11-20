<script>
import { mapState } from 'vuex';
import { GlFilteredSearchToken } from '@gitlab/ui';
import { setUrlParams, queryToObject } from '~/lib/utils/url_utility';
import { getParameterByName } from '~/lib/utils/common_utils';
import { __ } from '~/locale';
import FilteredSearchBar from '~/vue_shared/components/filtered_search_bar/filtered_search_bar_root.vue';
import { SEARCH_TOKEN_TYPE } from '../../constants';

export default {
  name: 'MembersFilteredSearchBar',
  components: { FilteredSearchBar },
  availableTokens: [
    {
      type: 'two_factor',
      icon: 'lock',
      title: __('2FA'),
      token: GlFilteredSearchToken,
      unique: true,
      operators: [{ value: '=', description: 'is', default: 'true' }],
      options: [
        { value: 'enabled', title: __('Enabled') },
        { value: 'disabled', title: __('Disabled') },
      ],
      requiredPermissions: 'canManageMembers',
    },
    {
      type: 'with_inherited_permissions',
      icon: 'group',
      title: __('Membership'),
      token: GlFilteredSearchToken,
      unique: true,
      operators: [{ value: '=', description: 'is', default: 'true' }],
      options: [
        { value: 'exclude', title: __('Direct') },
        { value: 'only', title: __('Inherited') },
      ],
    },
  ],
  data() {
    return {
      initialFilterValue: [],
    };
  },
  computed: {
    ...mapState(['sourceId', 'filteredSearchBarOptions', 'canManageMembers']),
    tokens() {
      return this.$options.availableTokens.filter(token => {
        if (
          Object.prototype.hasOwnProperty.call(token, 'requiredPermissions') &&
          !this[token.requiredPermissions]
        ) {
          return false;
        }

        return this.filteredSearchBarOptions.tokens?.includes(token.type);
      });
    },
  },
  created() {
    const query = queryToObject(window.location.search);

    const tokens = this.tokens
      .filter(token => query[token.type])
      .map(token => ({
        type: token.type,
        value: {
          data: query[token.type],
          operator: '=',
        },
      }));

    if (query[this.filteredSearchBarOptions.searchParam]) {
      tokens.push({
        type: SEARCH_TOKEN_TYPE,
        value: {
          data: query[this.filteredSearchBarOptions.searchParam],
        },
      });
    }

    this.initialFilterValue = tokens;
  },
  methods: {
    handleFilter(tokens) {
      const params = tokens.reduce((accumulator, token) => {
        const { type, value } = token;

        if (!type || !value) {
          return accumulator;
        }

        if (type === SEARCH_TOKEN_TYPE) {
          if (value.data !== '') {
            return {
              ...accumulator,
              [this.filteredSearchBarOptions.searchParam]: value.data,
            };
          }
        } else {
          return {
            ...accumulator,
            [type]: value.data,
          };
        }

        return accumulator;
      }, {});

      const sortParam = getParameterByName('sort');

      if (sortParam) {
        window.location.href = setUrlParams(
          { ...params, sort: sortParam },
          window.location.href,
          true,
        );
      } else {
        window.location.href = setUrlParams(params, window.location.href, true);
      }
    },
  },
};
</script>

<template>
  <filtered-search-bar
    :namespace="sourceId.toString()"
    :tokens="tokens"
    :recent-searches-storage-key="filteredSearchBarOptions.recentSearchesStorageKey"
    :search-input-placeholder="filteredSearchBarOptions.placeholder"
    :initial-filter-value="initialFilterValue"
    @onFilter="handleFilter"
  />
</template>
