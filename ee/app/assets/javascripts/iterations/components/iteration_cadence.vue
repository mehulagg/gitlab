<script>
export default {
  props: {
    title: {
      type: String,
      required: true,
    },
  },
};
</script>

<template>
  <li>
    {{ title }}
  </li>
</template>
