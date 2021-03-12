<script>
import Filters from 'ee/security_dashboard/components/first_class_vulnerability_filters.vue';
import SecurityDashboardLayout from 'ee/security_dashboard/components/security_dashboard_layout.vue';
import { vulnerabilitiesSeverityCountScopes } from '../constants';
import CsvExportButton from './csv_export_button.vue';
import DashboardNotConfigured from './empty_states/instance_dashboard_not_configured.vue';
import InstanceSecurityVulnerabilities from './first_class_instance_security_dashboard_vulnerabilities.vue';
import VulnerabilitiesCountList from './vulnerability_count_list.vue';

export default {
  components: {
    CsvExportButton,
    SecurityDashboardLayout,
    InstanceSecurityVulnerabilities,
    Filters,
    DashboardNotConfigured,
    VulnerabilitiesCountList,
  },
  inject: ['hasProjects'],
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
      <header class="gl-my-6 gl-display-flex gl-align-items-center" data-testid="header">
        <h2 class="gl-flex-grow-1 gl-my-0">
          {{ s__('SecurityReports|Vulnerability Report') }}
        </h2>
        <csv-export-button :vulnerabilities-export-endpoint="vulnerabilitiesExportEndpoint" />
      </header>
      <vulnerabilities-count-list
        :scope="$options.vulnerabilitiesSeverityCountScopes.instance"
        :filters="filters"
      />
    </template>
    <template #sticky>
      <filters @filterChange="handleFilterChange" />
    </template>
    <instance-security-vulnerabilities :filters="filters" />
  </security-dashboard-layout>

  <dashboard-not-configured v-else />
</template>
