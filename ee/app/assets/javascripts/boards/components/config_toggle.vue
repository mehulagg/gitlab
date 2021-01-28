<script>
import { GlButton, GlModalDirective, GlTooltipDirective } from '@gitlab/ui';
import { s__, __ } from '~/locale';

export default {
  components: {
    GlButton,
  },
  directives: {
    GlTooltip: GlTooltipDirective,
    GlModalDirective,
  },
  props: {
    boardsStore: {
      type: Object,
      required: true,
    },
    canAdminList: {
      type: Boolean,
      required: true,
    },
    hasScope: {
      type: Boolean,
      required: true,
    },
  },
  data() {
    return {
      state: this.boardsStore.state,
    };
  },
  computed: {
    buttonText() {
      return this.canAdminList ? s__('Boards|Edit board') : s__('Boards|View scope');
    },
    tooltipTitle() {
      return this.hasScope ? __("This board's scope is reduced") : '';
    },
  },
  methods: {
    showPage(page) {
      return this.boardsStore.showPage(page);
    },
  },
};
</script>

<template>
  <div class="gl-ml-3">
    <gl-button
      v-gl-modal-directive="'board-config-modal'"
      v-gl-tooltip
      :title="tooltipTitle"
      :class="{ 'dot-highlight': hasScope }"
      data-qa-selector="boards_config_button"
      @click.prevent="showPage('edit')"
    >
      {{ buttonText }}
    </gl-button>
  </div>
</template>
};
