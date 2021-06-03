<script>
import {
  GlSearchBoxByType,
  GlDropdown,
  GlDropdownItem,
  GlButton,
  GlModal,
  GlSprintf,
  GlModalDirective,
} from '@gitlab/ui';
import { mapActions, mapState, mapGetters } from 'vuex';
import { s__, __, sprintf } from '~/locale';
import { DEFAULT_SEARCH_DELAY, ACTION_TYPES, FILTER_STATES } from '../constants';

export default {
  name: 'GeoReplicableFilterBar',
  i18n: {
    modalBody: s__(
      'Geo|This will resync all %{replicableType}. It may take some time to complete. Are you sure you want to continue?',
    ),
  },
  components: {
    GlSearchBoxByType,
    GlDropdown,
    GlDropdownItem,
    GlButton,
    GlModal,
    GlSprintf,
  },
  directives: {
    GlModalDirective,
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
  MODAL_PRIMARY_ACTION: {
    text: s__('Geo|Resync all'),
  },
  MODAL_CANCEL_ACTION: {
    text: __('Cancel'),
  },
  MODAL_ID: 'resync-all-geo',
};
</script>

<template>
  <nav class="bg-secondary border-bottom border-secondary-100 p-3">
    <div class="row d-flex flex-column flex-sm-row">
      <div class="col">
        <div class="d-sm-flex mx-n1">
          <gl-dropdown :text="__('Filter by status')" class="px-1 my-1 my-sm-0 w-100">
            <gl-dropdown-item
              v-for="(filter, index) in filterOptions"
              :key="index"
              :class="{ 'bg-secondary-100': index === currentFilterIndex }"
              @click="filterChange(index)"
            >
              <span v-if="filter === $options.filterStates.ALL"
                >{{ filter.label }} {{ replicableTypeName }}</span
              >
              <span v-else>{{ filter.label }}</span>
            </gl-dropdown-item>
          </gl-dropdown>
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
        <gl-button v-gl-modal-directive="$options.MODAL_ID">{{ __('Resync all') }}</gl-button>
      </div>
    </div>
    <gl-modal
      :modal-id="$options.MODAL_ID"
      :title="resyncText"
      :action-primary="$options.MODAL_PRIMARY_ACTION"
      :action-cancel="$options.MODAL_CANCEL_ACTION"
      size="sm"
      @primary="initiateAllReplicableSyncs($options.actionTypes.RESYNC)"
    >
      <gl-sprintf :message="$options.i18n.modalBody">
        <template #replicableType>{{ replicableTypeName }}</template>
      </gl-sprintf>
    </gl-modal>
  </nav>
</template>
