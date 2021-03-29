<script>
export default {
  inject: {
    subscriptions: {
      default: [],
    },
  },
};
</script>

<template>
  <div>{{ subscriptions }}</div>
</template>
