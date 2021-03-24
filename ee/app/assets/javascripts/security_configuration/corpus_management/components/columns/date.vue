<script>
export default {
  props: {
    date: {
      type: Date,
      required: true,
    },
  },
  computed: {
    monthDayYear() {
      return this.date.toLocaleDateString('en-CA');
    },
  },
};
</script>
<template>
  <span>{{ monthDayYear }}</span>
</template>
