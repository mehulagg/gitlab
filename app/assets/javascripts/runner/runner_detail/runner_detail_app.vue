<script>
export default {
  props: {
    runnerId: {
      type: String,
      required: true,
    },
  },
};
</script>
<template>
  <h1 class="page-title">
    {{ sprintf(s__('Runners|Runner #%{runnerId}'), { runnerId }) }}
  </h1>
</template>
