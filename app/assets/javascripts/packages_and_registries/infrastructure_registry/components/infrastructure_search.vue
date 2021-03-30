<script>
import { mapState, mapActions } from 'vuex';
import getTableHeaders from '~/packages/list/utils';
import RegistrySearch from '~/vue_shared/components/registry/registry_search.vue';

export default {
  components: { RegistrySearch },
  computed: {
    ...mapState({
      isGroupPage: (state) => state.config.isGroupPage,
      sorting: (state) => state.sorting,
      filter: (state) => state.filter,
    }),
    sortableFields() {
      return getTableHeaders(this.isGroupPage);
    },
  },
  methods: {
    ...mapActions(['setSorting', 'setFilter']),
    updateSorting(newValue) {
      this.setSorting(newValue);
      this.$emit('update');
    },
  },
};
</script>

<template>
  <registry-search
    :filter="filter"
    :sorting="sorting"
    :tokens="[]"
    :sortable-fields="sortableFields"
    @sorting:changed="updateSorting"
    @filter:changed="setFilter"
    @filter:submit="$emit('update')"
  />
</template>
