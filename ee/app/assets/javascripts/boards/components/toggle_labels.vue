<script>
import { mapState, mapActions } from 'vuex';
import { GlToggle } from '@gitlab/ui';
import { parseBoolean } from '~/lib/utils/common_utils';
import Tracking from '~/tracking';
import LocalStorageSync from '~/vue_shared/components/local_storage_sync.vue';

export default {
  components: {
    GlToggle,
    LocalStorageSync,
  },
  computed: {
    ...mapState(['isShowingLabels']),
  },
  methods: {
    ...mapActions(['setShowLabels']),
    onToggle(val) {
      this.setShowLabels(val);

      Tracking.event(document.body.dataset.page, 'toggle', {
        label: 'show_labels',
        property: this.isShowingLabels ? 'on' : 'off',
      });
    },

    onStorageUpdate(val) {
      this.setShowLabels(parseBoolean(val));
    },
  },
};
</script>

<template>
  <div class="board-labels-toggle-wrapper d-flex align-items-center gl-ml-3">
    <local-storage-sync
      storage-key="gl-show-board-labels"
      :value="JSON.stringify(isShowingLabels)"
      @input="onStorageUpdate"
    />
    <gl-toggle
      :value="isShowingLabels"
      :label="__('Show labels')"
      label-position="left"
      aria-describedby="board-labels-toggle-text"
      data-qa-selector="show_labels_toggle"
      @change="onToggle"
    />
  </div>
</template>
