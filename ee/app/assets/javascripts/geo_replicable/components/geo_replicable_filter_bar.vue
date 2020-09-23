<script>
import { mapActions, mapState, mapGetters } from 'vuex';
import {
  GlSearchBoxByType,
  GlDeprecatedDropdown,
  GlDeprecatedDropdownItem,
  GlButton,
} from '@gitlab/ui';
import { __, sprintf } from '~/locale';
import { DEFAULT_SEARCH_DELAY, ACTION_TYPES, FILTER_STATES } from '../constants';

export default {
  name: 'GeoReplicableFilterBar',
  components: {
    GlSearchBoxByType,
    GlDeprecatedDropdown,
    GlDeprecatedDropdownItem,
    GlButton,
  },
  computed: {
    ...mapState(['currentFilterIndex', 'filterOptions', 'searchFilter']),
    ...mapGetters(['replicableTypeName']),
    search: {
      get() {
        return this.searchFilter;
      },
      set(val) {
        this.setSearch(val);
        this.fetchReplicableItems();
      },
    },
    resyncText() {
      return sprintf(__('Resync all %{replicableType}'), {
        replicableType: this.replicableTypeName,
      });
    },
  },
  methods: {
    ...mapActions(['setFilter', 'setSearch', 'fetchReplicableItems', 'initiateAllReplicableSyncs']),
    filterChange(filterIndex) {
      this.setFilter(filterIndex);
      this.fetchReplicableItems();
    },
  },
  actionTypes: ACTION_TYPES,
  filterStates: FILTER_STATES,
  debounce: DEFAULT_SEARCH_DELAY,
};
</script>

<template>
  <nav class="bg-secondary border-bottom border-secondary-100 p-3">
    <div class="row d-flex flex-column flex-sm-row">
      <div class="col">
        <div class="d-sm-flex mx-n1">
          <gl-deprecated-dropdown :text="__('Filter by status')" class="px-1 my-1 my-sm-0 w-100">
            <gl-deprecated-dropdown-item
              v-for="(filter, index) in filterOptions"
              :key="index"
              :class="{ 'bg-secondary-100': index === currentFilterIndex }"
              @click="filterChange(index)"
            >
              <span v-if="filter === $options.filterStates.ALL"
                >{{ filter.label }} {{ replicableTypeName }}</span
              >
              <span v-else>{{ filter.label }}</span>
            </gl-deprecated-dropdown-item>
          </gl-deprecated-dropdown>
          <gl-search-box-by-type
            v-model="search"
            :debounce="$options.debounce"
            class="px-1 my-1 my-sm-0 bg-white w-100"
            type="text"
            :placeholder="__('Filter by name')"
          />
        </div>
      </div>
      <div class="col col-sm-5 d-flex justify-content-end my-1 my-sm-0 w-100">
        <gl-button @click="initiateAllReplicableSyncs($options.actionTypes.RESYNC)">{{
          __('Resync all')
        }}</gl-button>
      </div>
    </div>
  </nav>
</template>
