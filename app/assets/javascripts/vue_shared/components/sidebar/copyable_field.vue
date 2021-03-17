<script>
import { GlLoadingIcon } from '@gitlab/ui';
import { __, sprintf } from '~/locale';
import ClipboardButton from '~/vue_shared/components/clipboard_button.vue';

export default {
  name: 'CopyableField',
  components: {
    GlLoadingIcon,
    ClipboardButton,
  },
  props: {
    text: {
      type: String,
      required: true,
    },
    value: {
      type: String,
      required: true,
    },
    name: {
      type: String,
      required: true,
    },
    isLoading: {
      type: Boolean,
      required: false,
      default: false,
    },
  },
  computed: {
    clipboardProps() {
      return {
        category: 'tertiary',
        tooltipBoundary: 'viewport',
        tooltipPlacement: 'left',
        text: this.value,
        title: sprintf(__('Copy %{name}'), { name: this.name }),
      };
    },
  },
};
</script>

<template>
  <div>
    <clipboard-button
      v-if="!isLoading"
      css-class="sidebar-collapsed-icon dont-change-state"
      v-bind="clipboardProps"
    />

    <div
      class="gl-display-flex gl-align-items-center gl-justify-content-space-between hide-collapsed"
    >
      <gl-loading-icon v-if="isLoading" inline :label="text" />
      <template v-else>
        <span class="gl-overflow-hidden gl-text-overflow-ellipsis gl-white-space-nowrap">
          {{ text }}
        </span>

        <clipboard-button size="small" v-bind="clipboardProps" />
      </template>
    </div>
  </div>
</template>
