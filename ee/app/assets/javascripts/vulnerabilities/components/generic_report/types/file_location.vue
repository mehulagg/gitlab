<script>
export default {
  inheritAttrs: false,
  props: {
    fileName: {
      type: String,
      required: true,
    },
    lineStart: {
      type: Number,
      required: true,
    },
    lineEnd: {
      type: Number,
      required: false,
      default: null,
    },
  },
  computed: {
    lineStr() {
      return this.lineEnd ? `${this.lineStart}-${this.lineEnd}` : this.lineStart;
    },
  },
};
</script>
<template>
  <span>{{ fileName }}:{{ lineStr }}</span>
</template>
