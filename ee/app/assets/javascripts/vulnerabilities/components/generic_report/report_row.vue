<script>
export default {
  props: {
    label: {
      type: String,
      required: true,
    },
  },
};
</script>
<template>
  <div
    class="generic-report-row gl-display-grid gl-px-3 gl-py-5 gl-border-b-1 gl-border-b-solid gl-border-gray-100"
  >
    <strong>{{ label }}</strong>
    <div data-testid="reportContent">
      <slot></slot>
    </div>
  </div>
</template>
