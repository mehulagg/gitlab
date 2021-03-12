<script>
import GroupSecurityVulnerabilities from 'ee/security_dashboard/components/first_class_group_security_dashboard_vulnerabilities.vue';
import Filters from 'ee/security_dashboard/components/first_class_vulnerability_filters.vue';
import SecurityDashboardLayout from 'ee/security_dashboard/components/security_dashboard_layout.vue';
import { vulnerabilitiesSeverityCountScopes } from '../constants';
import CsvExportButton from './csv_export_button.vue';
import DashboardNotConfigured from './empty_states/group_dashboard_not_configured.vue';
import VulnerabilitiesCountList from './vulnerability_count_list.vue';

export default {
  components: {
    SecurityDashboardLayout,
    GroupSecurityVulnerabilities,
    Filters,
    CsvExportButton,
    DashboardNotConfigured,
    VulnerabilitiesCountList,
  },
  inject: ['groupFullPath', 'hasProjects'],
  props: {
    vulnerabilitiesExportEndpoint: {
      type: String,
      required: true,
    },
  },
  data() {
    return {
      filters: {},
    };
  },
  methods: {
    handleFilterChange(filters) {
      this.filters = filters;
    },
  },
  vulnerabilitiesSeverityCountScopes,
};
</script>

<template>
  <security-dashboard-layout v-if="hasProjects">
    <template #header>
      <header class="gl-my-6 gl-display-flex gl-align-items-center">
        <h2 class="gl-flex-grow-1 gl-my-0">
          {{ s__('SecurityReports|Vulnerability Report') }}
        </h2>
        <csv-export-button :vulnerabilities-export-endpoint="vulnerabilitiesExportEndpoint" />
      </header>
      <vulnerabilities-count-list
        :scope="$options.vulnerabilitiesSeverityCountScopes.group"
        :full-path="groupFullPath"
        :filters="filters"
      />
    </template>
    <template #sticky>
      <filters @filterChange="handleFilterChange" />
    </template>
    <group-security-vulnerabilities :group-full-path="groupFullPath" :filters="filters" />
  </security-dashboard-layout>
  <dashboard-not-configured v-else />
</template>
