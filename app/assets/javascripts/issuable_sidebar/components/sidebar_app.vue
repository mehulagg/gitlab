<script>
export default {
  props: {
    signedIn: {
      type: Boolean,
      required: true,
    },
    sidebarStatusClass: {
      type: String,
      required: false,
      default: '',
    },
  },

  emits: [],
};
</script>

<template>
  <aside
    :class="sidebarStatusClass"
    class="right-sidebar js-right-sidebar js-issuable-sidebar"
    aria-live="polite"
  ></aside>
</template>
