<script>
export default {
  name: 'DefaultStageFields',
  props: {
    name: {
      type: String,
      required: true,
    },
    startEventIdentifier: {
      type: String,
      required: true,
    },
    endEventIdentifier: {
      type: String,
      required: true,
    },
    startEventLabel: {
      type: String,
      required: false,
      default: null,
    },
    endEventLabel: {
      type: String,
      required: false,
      default: null,
    },
  },
};
</script>
<template>
  <div></div>
</template>
