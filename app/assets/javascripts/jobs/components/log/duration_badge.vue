<script>
export default {
  props: {
    duration: {
      type: String,
      required: true,
    },
  },

  emits: [],
};
</script>
<template>
  <div class="log-duration-badge rounded align-self-start px-2 ml-2 flex-shrink-0 ws-normal">
    {{ duration }}
  </div>
</template>
