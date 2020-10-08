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
      <div class="col-md-3">{{ label }}:</div>
      <div class="col-md-9">
        <strong>{{ value }}</strong>
      </div>
    </div>
  </div>
</template>
