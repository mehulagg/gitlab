<script>
import AlertManagementEmptyState from './alert_management_empty_state.vue';
import AlertManagementTable from './alert_management_table.vue';

export default {
  components: {
    AlertManagementEmptyState,
    AlertManagementTable,
  },
  inject: [
    'projectPath',
    'textQuery',
    'authorUsernamesQuery',
    'assigneeUsernamesQuery',
    'enableAlertManagementPath',
    'populatingAlertsHelpUrl',
    'emptyAlertSvgPath',
    'alertManagementEnabled',
    'userCanEnableAlertManagement',
    'opsgenieMvcTargetUrl',
    'opsgenieMvcEnabled',
  ],
};
</script>
<template>
  <div>
    <alert-management-table v-if="alertManagementEnabled" />
    <alert-management-empty-state v-else />
  </div>
</template>
