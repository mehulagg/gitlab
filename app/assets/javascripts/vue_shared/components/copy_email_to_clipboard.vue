<script>
import { __ } from '~/locale';
import ClipboardButton from '~/vue_shared/components/clipboard_button.vue';

export default {
  i18n: {
    issueEmail: __('Issue email'),
  },
  components: {
    ClipboardButton,
  },
  props: {
    copyText: {
      type: String,
      required: false,
      default: 'xxxxxxxxxxxxxxxxx',
    },
  },
};
</script>

<template>
  <div class="gl-display-flex align-items-center gl-justify-content-space-between">
    <span
      style="width: 85%"
      class="gl-overflow-hidden gl-text-overflow-ellipsis gl-white-space-nowrap"
      >{{ `${$options.i18n.issueEmail}: ${copyText}` }}</span
    >
    <clipboard-button
      category="tertiary"
      :title="'Copy email'"
      :text="copyText"
      tooltip-placement="left"
    />
  </div>
</template>
