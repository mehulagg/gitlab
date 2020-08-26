<script>
import { GlIcon, GlDeprecatedDropdown, GlDeprecatedButton } from '@gitlab/ui';
import { __, n__ } from '~/locale';
import { SELECTIVE_SYNC_SHARDS } from '../constants';

export default {
  name: 'GeoNodeFormShards',
  components: {
    GlIcon,
    GlDeprecatedDropdown,
    GlDeprecatedButton,
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

  emits: ['addSyncOption', 'removeSyncOption'],
};
</script>

<template>
  <gl-deprecated-dropdown :text="dropdownTitle">
    <li v-for="shard in syncShardsOptions" :key="shard.value">
      <gl-deprecated-button class="d-flex align-items-center" @click="toggleShard(shard)">
        <gl-icon :class="[{ invisible: !isSelected(shard) }]" name="mobile-issue-close" />
        <span class="ml-1">{{ shard.label }}</span>
      </gl-deprecated-button>
    </li>
    <div v-if="noSyncShards" class="text-secondary p-2">{{ __('Nothing found…') }}</div>
  </gl-deprecated-dropdown>
</template>
