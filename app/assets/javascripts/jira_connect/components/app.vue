<script>
export default {
  name: 'JiraConnectApp',
  computed: {
    state() {
      return this.$root.$data.state || {};
    },
    error() {
      return this.state.error;
    },
  },
};
</script>
<template>
  <div>
    <div v-if="error" class="gl-alert gl-alert-danger gl-mb-5">
      <div class="gl-alert-body">{{ error }}</div>
    </div>
  </div>
</template>
