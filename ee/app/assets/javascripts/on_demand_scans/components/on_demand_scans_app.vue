<script>
import OnDemandScansForm from './on_demand_scans_form.vue';
import OnDemandScansEmptyState from './on_demand_scans_empty_state.vue';

export default {
  name: 'OnDemandScansApp',
  components: {
    OnDemandScansForm,
    OnDemandScansEmptyState,
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
    <template v-if="showForm">
      <on-demand-scans-form
        :help-page-path="helpPagePath"
        :project-path="projectPath"
        :default-branch="defaultBranch"
        @cancel="showForm = false"
      />
    </template>
    <on-demand-scans-empty-state
      v-else
      :help-page-path="helpPagePath"
      :empty-state-svg-path="emptyStateSvgPath"
      @createNewScan="showForm = true"
    />
  </div>
</template>
