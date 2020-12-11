<script>
import createFlash from '~/flash';
import securityReportDownloadPathsQuery from '~/vue_shared/security_reports/queries/security_report_download_paths.query.graphql';
import SecurityReportDownloadDropdown from '~/vue_shared/security_reports/components/security_report_download_dropdown.vue';

import {
  reportTypeToSecurityReportTypeEnum,
} from 'ee/vue_shared/security_reports/constants';

import { extractSecurityReportArtifacts } from '~/vue_shared/security_reports/utils.js';

import { s__ } from '~/locale';

export default {
  components: {
    SecurityReportDownloadDropdown
  },
  props:{
    reportTypes: {
      type: Array,
      required: true,
      //TODO: ADD Validations
    },
    targetProjectFullPath: {
      type: String,
      required: false,
      default: '',
    },
    mrIid: {
      type: Number,
      required: false,
      default: 0,
    },    
  },
  data() {
    return {
      reportArtifacts: [],
    };
  },  
  apollo: {
    reportArtifacts: {
      query: securityReportDownloadPathsQuery,
      variables() {
        return {
          projectPath: this.targetProjectFullPath,
          iid: String(this.mrIid),
          reportTypes: this.reportTypes.map(
            reportType => reportTypeToSecurityReportTypeEnum[reportType],
          ),
        };
      },
      update(data) {
        debugger;
        return extractSecurityReportArtifacts(this.reportTypes, data);
      },
      error(error) {
        this.showError(error);
      },
      result({ loading }) {
        if (loading) {
          return;
        }

        let foo =  this.reportArtifacts.map(({ reportType }) => reportType);
        //debugger;
        return foo;
        // // Query has completed, so populate the availableSecurityReports.
        // this.onCheckingAvailableSecurityReports(
        //   this.reportArtifacts.map(({ reportType }) => reportType),
        // );
      },
    },
  },
  computed: {
    isLoadingReportArtifacts() {
      //debugger;
      return this.$apollo.queries.reportArtifacts.loading;
    },
  },
  methods: {
    showError(error) {
      createFlash({
        message: this.$options.i18n.apiError,
        captureError: true,
        error,
      });
    },    
  },
  i18n: {
    apiError: s__(
      'SecurityReports|Failed to get security report information. Please reload the page or try again later.',
    ),
  }  
};
</script>

<template>
  <security-report-download-dropdown
    :artifacts="reportArtifacts || []"
    :loading="isLoadingReportArtifacts"
  />
</template>
