import Vue from 'vue';
import { mapState, mapGetters, mapActions } from 'vuex';
import { GlToggle } from '@gitlab/ui';
import Tracking from '~/tracking';
import store from '~/boards/stores';
import LocalStorageSync from '~/vue_shared/components/local_storage_sync.vue';

export default () =>
  new Vue({
    el: document.getElementById('js-board-labels-toggle'),
    components: {
      GlToggle,
      LocalStorageSync,
    },
    store,
    computed: {
      ...mapState(['isShowingLabels']),
      ...mapGetters(['getLabelToggleState']),
    },
    methods: {
      ...mapActions(['setShowLabels']),

      onToggle(val) {
        this.setShowLabels(val);

        Tracking.event(document.body.dataset.page, 'toggle', {
          label: 'show_labels',
          property: this.getLabelToggleState,
        });
      },

      onStorageUpdate(val) {
        this.setShowLabels(JSON.parse(val));
      },
    },
    template: `
      <div class="board-labels-toggle-wrapper d-flex align-items-center gl-ml-3">
        <local-storage-sync storage-key="gl-show-board-labels" :value="JSON.stringify(isShowingLabels)" @input="onStorageUpdate" />
        <gl-toggle
          :value="isShowingLabels"
          label="Show labels"
          label-position="left"
          aria-describedby="board-labels-toggle-text"
          data-qa-selector="show_labels_toggle"
          @change="onToggle"
        />
      </div>
    `,
  });
