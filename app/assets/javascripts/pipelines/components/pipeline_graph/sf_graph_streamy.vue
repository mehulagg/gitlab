<script>
export default {
  props: {
    stageClasses: {
      type: String,
      required: false,
      default: '',
    },
    jobClasses: {
      type: String,
      required: false,
      default: '',
    },
  },
};
</script>
<template>
  <div class="gl-display-flex">

    <slot name="upstream"></slot>

    <slot name="main"></slot>

    <slot name="downstream"></slot>
  </div>
</template>
