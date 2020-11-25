<script>
import OnDemandScansForm from './on_demand_scans_form.vue';

export default {
  name: 'OnDemandScansApp',
  components: {
    OnDemandScansForm,
  },
  props: {
    helpPagePath: {
      type: String,
      required: true,
    },
    projectPath: {
      type: String,
      required: true,
    },
    defaultBranch: {
      type: String,
      required: true,
    },
    emptyStateSvgPath: {
      type: String,
      required: true,
    },
  },
  data() {
    return {
      showForm: false,
    };
  },
};
</script>

<template>
  <div>
    <on-demand-scans-form
      :help-page-path="helpPagePath"
      :project-path="projectPath"
      :default-branch="defaultBranch"
    />
  </div>
</template>
