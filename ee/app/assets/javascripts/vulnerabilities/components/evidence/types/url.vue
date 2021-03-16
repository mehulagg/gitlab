<script>
export default {
  props: {
    message: {
      type: String,
      required: true,
    },
  },
};
</script>
<template>
  <!-- eslint-disable-next-line @gitlab/vue-require-i18n-strings -->
  <p class="gl-my-0!">url: {{ message }}</p>
</template>
