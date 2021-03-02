<script>
import { __ } from '~/locale';

import ClipboardButton from '~/vue_shared/components/clipboard_button.vue';

export default {
  name: 'JiraIssuesSidebarReference',
  components: {
    ClipboardButton,
  },
  props: {
    reference: {
      type: String,
      required: true,
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
  },
};
</script>

<template>
  <div class="block">
    <div class="sidebar-collapsed-icon dont-change-state">
      <clipboard-button css-class="btn-clipboard" v-bind="clipboardProps" />
    </div>

    <div class="cross-project-reference hide-collapsed">
      <span
        >{{ __('Reference:') }}
        <cite :title="reference">{{ reference }}</cite>
      </span>
      <clipboard-button size="small" v-bind="clipboardProps" />
    </div>
  </div>
</template>
