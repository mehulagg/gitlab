<script>
import { GlIcon, GlSearchBoxByType, GlDeprecatedDropdown, GlDeprecatedButton } from '@gitlab/ui';
import { mapActions, mapState } from 'vuex';
import { __, n__ } from '~/locale';
import { SELECTIVE_SYNC_NAMESPACES } from '../constants';

export default {
  name: 'GeoNodeFormNamespaces',
  components: {
    GlIcon,
    GlSearchBoxByType,
    GlDeprecatedDropdown,
    GlDeprecatedButton,
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

  emits: ['addSyncOption', 'removeSyncOption'],
};
</script>

<template>
  <gl-deprecated-dropdown :text="dropdownTitle" @show="fetchSyncNamespaces('')">
    <gl-search-box-by-type class="m-2" :debounce="500" @input="fetchSyncNamespaces" />
    <li v-for="namespace in synchronizationNamespaces" :key="namespace.id">
      <gl-deprecated-button class="d-flex align-items-center" @click="toggleNamespace(namespace)">
        <gl-icon :class="[{ invisible: !isSelected(namespace) }]" name="mobile-issue-close" />
        <span class="ml-1">{{ namespace.name }}</span>
      </gl-deprecated-button>
    </li>
    <div v-if="noSyncNamespaces" class="text-secondary p-2">{{ __('Nothing found…') }}</div>
  </gl-deprecated-dropdown>
</template>
