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
  <div class="generic-report-row">
    <strong class="generic-report-column">{{ label }}</strong>
    <div class="generic-report-column" data-testid="reportContent">
      <slot></slot>
    </div>
  </div>
</template>
