<script>
import { __, sprintf } from '~/locale';
import ClipboardButton from '~/vue_shared/components/clipboard_button.vue';

export default {
  components: {
    ClipboardButton,
  },
  props: {
    copyText: {
      type: String,
      required: true,
    },
  },
  computed: {
    emailText() {
      return sprintf(__('Issue email: %{copyText}'), { copyText: this.copyText });
    },
  },
};
</script>

<template>
  <div
    class="copy-email-address gl-display-flex align-items-center gl-justify-content-space-between"
  >
    <span
      style="width: 85%"
      class="gl-overflow-hidden gl-text-overflow-ellipsis gl-white-space-nowrap hide-collapsed"
      >{{ emailText }}</span
    >
    <clipboard-button
      class="copy-email-button gl-bg-none!"
      category="tertiary"
      :title="'Copy email'"
      :text="copyText"
      tooltip-placement="left"
    />
  </div>
</template>
