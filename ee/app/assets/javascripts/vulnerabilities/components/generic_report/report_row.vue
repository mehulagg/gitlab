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
    class="row gl-py-5 gl-border-b-1 gl-border-b-solid gl-border-gray-100"
    :class="{ 'gl-border-none!': isLastRow }"
  >
    <strong class="col-sm-3">{{ label }}</strong>
    <div data-testid="reportContent" class="col-sm-9">
      <slot></slot>
    </div>
  </div>
</template>
