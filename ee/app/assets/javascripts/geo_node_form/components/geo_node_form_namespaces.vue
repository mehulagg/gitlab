<script>
import { GlIcon, GlSearchBoxByType, GlDropdown } from '@gitlab/ui';
import { mapActions, mapState } from 'vuex';
import { __, n__ } from '~/locale';
import { SELECTIVE_SYNC_NAMESPACES } from '../constants';

export default {
  name: 'GeoNodeFormNamespaces',
  components: {
    GlIcon,
    GlSearchBoxByType,
    GlDropdown,
  },
  props: {
    selectedNamespaces: {
      type: Array,
      required: true,
    },
  },
  computed: {
    ...mapState(['synchronizationNamespaces']),
    dropdownTitle() {
      if (this.selectedNamespaces.length === 0) {
        return __('Select groups to replicate');
      }
      return n__('%d group selected', '%d groups selected', this.selectedNamespaces.length);
    },
    noSyncNamespaces() {
      return this.synchronizationNamespaces.length === 0;
    },
  },
  methods: {
    ...mapActions(['fetchSyncNamespaces']),
    toggleNamespace(namespace) {
      const index = this.selectedNamespaces.findIndex(id => id === namespace.id);
      if (index > -1) {
        this.$emit('removeSyncOption', { key: SELECTIVE_SYNC_NAMESPACES, index });
      } else {
        this.$emit('addSyncOption', { key: SELECTIVE_SYNC_NAMESPACES, value: namespace.id });
      }
    },
    isSelected(namespace) {
      return this.selectedNamespaces.includes(namespace.id);
    },
  },
};
</script>

<template>
  <gl-dropdown :text="dropdownTitle" @show="fetchSyncNamespaces('')">
    <gl-search-box-by-type class=".gl-m-3" :debounce="500" @input="fetchSyncNamespaces" />
    <button
      v-for="namespace in synchronizationNamespaces"
      :key="namespace.id"
      class="dropdown-item"
      type="button"
      @click="toggleNamespace(namespace)"
    >
      <gl-icon
        :class="[{ 'gl-visibility-hidden': !isSelected(namespace) }]"
        name="mobile-issue-close"
      />
      <span class="gl-ml-2">{{ namespace.name }}</span>
    </button>
    <div v-if="noSyncNamespaces" class="gl-text-gray-500 gl-p-3">{{ __('Nothing found…') }}</div>
  </gl-dropdown>
</template>
