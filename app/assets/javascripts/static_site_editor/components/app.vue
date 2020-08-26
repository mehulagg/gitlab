<script>
export default {
  props: {
    mergeRequestsIllustrationPath: {
      type: String,
      required: true,
    },
  },

  emits: [],
};
</script>
<template>
  <router-view :merge-requests-illustration-path="mergeRequestsIllustrationPath" />
</template>
