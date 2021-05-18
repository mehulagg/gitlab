<script>
import { GlFilteredSearchToken } from '@gitlab/ui';
import { __, s__ } from '~/locale';
import { OPERATOR_IS_ONLY } from '~/vue_shared/components/filtered_search_bar/constants';
import FilteredSearch from '~/vue_shared/components/filtered_search_bar/filtered_search_bar_root.vue';

import {
  STATUS_ACTIVE,
  STATUS_PAUSED,
  STATUS_ONLINE,
  STATUS_OFFLINE,
  STATUS_NOT_CONNECTED,
  INSTANCE_TYPE,
  GROUP_TYPE,
  PROJECT_TYPE,
} from '../constants';

const TOKEN_STATUS = 'TOKEN_STATUS';
const TOKEN_RUNNER_TYPE = 'TOKEN_RUNNER_TYPE';

export default {
  components: {
    FilteredSearch,
  },
  computed: {
    tokens() {
      return [
        {
          icon: 'status',
          title: __('Status'),
          type: TOKEN_STATUS,
          token: GlFilteredSearchToken,
          unique: true,
          options: [
            { value: STATUS_ACTIVE, title: s__('Runners|Active') },
            { value: STATUS_PAUSED, title: s__('Runners|Paused') },
            { value: STATUS_ONLINE, title: s__('Runners|Online') },
            { value: STATUS_OFFLINE, title: s__('Runners|Offline') },
            { value: STATUS_NOT_CONNECTED, title: s__('Runners|Not connected') },
          ],
          // TODO In principle we could support more complex search rules,
          // this can be added to a separate issue.
          operators: OPERATOR_IS_ONLY,
        },

        {
          icon: 'file-tree',
          title: __('Type'),
          type: TOKEN_RUNNER_TYPE,
          token: GlFilteredSearchToken,
          unique: true,
          options: [
            { value: INSTANCE_TYPE, title: s__('Runners|shared') },
            { value: GROUP_TYPE, title: s__('Runners|group') },
            { value: PROJECT_TYPE, title: s__('Runners|project') },
          ],
          // TODO We should support more complex search rules,
          // search for multiple states (OR) or have NOT operators
          operators: OPERATOR_IS_ONLY,
        },

        // TODO Support tags
      ];
    },
  },
  methods: {
    onFilter(filters) {
      const filterParameters = filters.reduce((acc, filter) => {
        if (filter.type === TOKEN_STATUS) {
          acc.status = filter.value.data;
        }
        if (filter.type === TOKEN_RUNNER_TYPE) {
          acc.type = filter.value.data;
        }
        return acc;
      }, {});
      this.$emit('onFilter', filterParameters);
    },
  },
};
</script>
<template>
  <filtered-search
    v-bind="$attrs"
    recent-searches-storage-key="runners-search"
    :tokens="tokens"
    :search-input-placeholder="__('Search or filter results...')"
    @onFilter="onFilter"
  />
</template>
