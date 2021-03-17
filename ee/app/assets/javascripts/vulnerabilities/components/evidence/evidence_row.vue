<script>
export default {
  props: {
    label: {
      type: String,
      required: true,
    },
    isLastRow: {
      type: Boolean,
      required: false,
    },
  },
};
</script>
<template>
  <div
    class="row gl-py-5 gl-px-4 gl-border-b-1 gl-border-b-solid gl-border-gray-100"
    :class="{ 'gl-border-none!': isLastRow }"
  >
    <strong class="col-sm-1">{{ label }}</strong>
    <div class="col-sm-11">
      <slot></slot>
    </div>
  </div>
</template>
