<script>
export default {
  props: {
    heading: {
      type: String,
      required: true,
    },
  },
};
</script>

<template>
  <p class="gl-text-gray-500 gl-border-b-solid gl-border-b-2 gl-border-b-gray-100 gl-mb-0 gl-p-5">
    {{ heading }}
  </p>
</template>
