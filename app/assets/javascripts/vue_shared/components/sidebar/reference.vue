<script>
import { GlLoadingIcon } from '@gitlab/ui';
import { __ } from '~/locale';
import ClipboardButton from '~/vue_shared/components/clipboard_button.vue';

export default {
  name: 'SidebarReference',
  components: {
    GlLoadingIcon,
    ClipboardButton,
  },
  props: {
    reference: {
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
        text: this.reference,
        title: this.$options.i18n.copyTitle,
      };
    },
  },
  i18n: {
    copyTitle: __('Copy reference'),
    text: __('Reference:'),
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
      class="gl-display-flex gl-align-items-center gl-justify-content-space-between gl-mb-2 hide-collapsed"
    >
      <span>
        {{ $options.i18n.text }}
        <cite :title="reference">{{ reference }}</cite>
        <gl-loading-icon v-if="isLoading" inline :label="$options.i18n.text" />
      </span>

      <clipboard-button size="small" css-class="gl-mr-1" v-bind="clipboardProps" />
    </div>
  </div>
</template>
