<script>
export default {
  props: {
    error: {
      type: String,
      required: true,
    },
    chartName: {
      type: String,
      required: true,
    },
    title: {
      type: String,
      required: true,
    },
    summary: {
      type: String,
      required: true,
    },
  },

  emits: [],
};
</script>
<template>
  <div class="row js-empty-state empty-state">
    <div class="col-12">
      <div class="text-content">
        <h4 class="content-title">{{ title }}: "{{ chartName }}"</h4>
        <p class="content-summary">{{ summary }}</p>
        <p class="content-summary">{{ error }}</p>
      </div>
    </div>
  </div>
</template>
