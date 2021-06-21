<script>
import SecurityPolicyProjectSelector from './security_policy_project_selector.vue';

export default {
  components: { SecurityPolicyProjectSelector },
  props: {
    assignedPolicyProject: {
      type: Object,
      required: false,
      default: () => ({}),
    },
  },
};
</script>

<template>
  <security-policy-project-selector :assigned-policy-project="assignedPolicyProject" />
</template>
