<script>
import AlertManagementEmptyState from './alert_management_empty_state.vue';
import AlertManagementTable from './alert_management_table.vue';

export default {
  components: {
    AlertManagementEmptyState,
    AlertManagementTable,
  },
  inject: ['projectPath'],
  props: {
    alertManagementEnabled: {
      type: Boolean,
      required: true,
    },
    enableAlertManagementPath: {
      type: String,
      required: true,
    },
    populatingAlertsHelpUrl: {
      type: String,
      required: true,
    },
    userCanEnableAlertManagement: {
      type: Boolean,
      required: true,
    },
    emptyAlertSvgPath: {
      type: String,
      required: true,
    },
    opsgenieMvcEnabled: {
      type: Boolean,
      required: false,
      default: false,
    },
    opsgenieMvcTargetUrl: {
      type: String,
      required: false,
      default: '',
    },
  },
};
</script>
<template>
  <div>
    <alert-management-table
      v-if="alertManagementEnabled"
      :populating-alerts-help-url="populatingAlertsHelpUrl"
      :project-path="projectPath"
    />
    <alert-management-empty-state
      v-else
      :empty-alert-svg-path="emptyAlertSvgPath"
      :enable-alert-management-path="enableAlertManagementPath"
      :user-can-enable-alert-management="userCanEnableAlertManagement"
      :opsgenie-mvc-enabled="opsgenieMvcEnabled"
      :opsgenie-mvc-target-url="opsgenieMvcTargetUrl"
    />
  </div>
</template>
