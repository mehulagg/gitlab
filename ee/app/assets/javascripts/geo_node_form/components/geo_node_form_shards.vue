<script>
import { GlIcon, GlButton, GlDropdown } from '@gitlab/ui';
import { __, n__ } from '~/locale';
import { SELECTIVE_SYNC_SHARDS } from '../constants';

export default {
  name: 'GeoNodeFormShards',
  components: {
    GlIcon,
    GlButton,
    GlDropdown,
  },
  props: {
    syncShardsOptions: {
      type: Array,
      required: true,
    },
    selectedShards: {
      type: Array,
      required: true,
    },
  },
  computed: {
    dropdownTitle() {
      if (this.selectedShards.length === 0) {
        return __('Select shards to replicate');
      }

      return n__('%d shard selected', '%d shards selected', this.selectedShards.length);
    },
    noSyncShards() {
      return this.syncShardsOptions.length === 0;
    },
  },
  methods: {
    toggleShard(shard) {
      const index = this.selectedShards.findIndex(value => value === shard.value);
      if (index > -1) {
        this.$emit('removeSyncOption', { key: SELECTIVE_SYNC_SHARDS, index });
      } else {
        this.$emit('addSyncOption', { key: SELECTIVE_SYNC_SHARDS, value: shard.value });
      }
    },
    isSelected(shard) {
      return this.selectedShards.includes(shard.value);
    },
  },
};
</script>

<template>
  <gl-dropdown id="node-synchronization-shards-field" :text="dropdownTitle">
    <li
      v-for="shard in syncShardsOptions"
      :key="shard.value"
      class="gl-display-flex! gl-align-items-center"
    >
      <gl-icon
        class="gl-mx-3"
        :class="[{ invisible: !isSelected(shard) }]"
        name="mobile-issue-close"
      />
      <gl-button category="tertiary" @click="toggleShard(shard)">
        <span class="gl-white-space-normal">{{ shard.label }}</span>
      </gl-button>
    </li>
    <div v-if="noSyncShards" class="gl-text-gray-500 gl-p-3">{{ __('Nothing found…') }}</div>
  </gl-dropdown>
</template>
