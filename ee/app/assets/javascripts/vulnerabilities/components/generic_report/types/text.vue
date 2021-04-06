<script>
export default {
  props: {
    text: {
      type: String,
      required: true,
    },
  },
};
</script>

<template>
  <span>{{ text }}</span>
</template>
