<script>
export default {
  props: {
    things: {
      type: Array,
      required: true,
    },
    loading: {
      type: Boolean,
      required: false,
    },
  },
};
</script>

<template>
  <div>
    <p v-for="thing in things" :key="thing.foo">{{ thing.foo }} - {{ thing.bar }}</p>
  </div>
</template>
