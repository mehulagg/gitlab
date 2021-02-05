<script>
export default {
  name: 'OnDemandScansProfileSummaryCell',
  props: {
    label: {
      type: String,
      required: true,
    },
    value: {
      type: String,
      required: true,
    },
  },
};
</script>

<template>
  <div class="col-md-6">
    <div class="row gl-my-2">
      <div class="col-md-4">{{ label }}:</div>
      <div class="col-md-8">
        <strong>{{ value }}</strong>
      </div>
    </div>
  </div>
</template>
