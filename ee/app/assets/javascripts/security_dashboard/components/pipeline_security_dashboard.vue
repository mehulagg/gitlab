<script>
import { GlAccordion, GlAccordionItem, GlAlert, GlEmptyState } from '@gitlab/ui';
import { mapActions } from 'vuex';
import { fetchPolicies } from '~/lib/graphql';
import { s__ } from '~/locale';
import glFeatureFlagMixin from '~/vue_shared/mixins/gl_feature_flags_mixin';
import pipelineSecurityReportSummaryQuery from '../graphql/queries/pipeline_security_report_summary.query.graphql';
import SecurityDashboard from './security_dashboard_vuex.vue';
import SecurityReportsSummary from './security_reports_summary.vue';
import VulnerabilityReport from './vulnerability_report.vue';

export default {
  name: 'PipelineSecurityDashboard',
  components: {
    GlAccordion, // TODO: lazy load these inside separate component
    GlAccordionItem,
    GlAlert,
    GlEmptyState,
    SecurityReportsSummary,
    SecurityDashboard,
    VulnerabilityReport,
  },
  mixins: [glFeatureFlagMixin()],
  inject: ['projectFullPath', 'pipeline', 'dashboardDocumentation', 'emptyStateSvgPath'],
  props: {
    projectId: {
      type: Number,
      required: true,
    },
    vulnerabilitiesEndpoint: {
      type: String,
      required: true,
    },
    loadingErrorIllustrations: {
      type: Object,
      required: true,
    },
  },
  data() {
    return {
      securityReportSummary: {},
    };
  },
  apollo: {
    securityReportSummary: {
      query: pipelineSecurityReportSummaryQuery,
      fetchPolicy: fetchPolicies.NETWORK_ONLY,
      variables() {
        return {
          fullPath: this.projectFullPath,
          pipelineIid: this.pipeline.iid,
        };
      },
      update(data) {
        const summary = data?.project?.pipeline?.securityReportSummary;
        return summary && Object.keys(summary).length ? summary : null;
      },
    },
  },
  computed: {
    shouldShowGraphqlVulnerabilityReport() {
      return this.glFeatures.pipelineSecurityDashboardGraphql;
    },
    emptyStateProps() {
      return {
        svgPath: this.emptyStateSvgPath,
        title: s__('SecurityReports|No vulnerabilities found for this pipeline'),
        description: s__(
          `SecurityReports|While it's rare to have no vulnerabilities for your pipeline, it can happen. In any event, we ask that you double check your settings to make sure all security scanning jobs have passed successfully.`,
        ),
        primaryButtonLink: this.dashboardDocumentation,
        primaryButtonText: s__('SecurityReports|Learn more about setting up your dashboard'),
      };
    },
    scannerErrors() {
      const securityReportSummary = {
        dast: {
          scans: [{ errors: ['dastyo', 'dastya'], name: 'dast' }],
        },
        sast: null,
        foo: {
          scans: [{ errors: ['fooyo', 'foobar'], name: 'dast' }],
        },
      };

      // TODO: make this more readable
      return Object.entries(securityReportSummary).flatMap(([scannerName, scannerSummary]) => {
        const scans = scannerSummary?.scans || [];

        if (!scans.length) {
          return [];
        }

        const errors = scans.flatMap((scan) => scan.errors);

        return errors.length ? [{ scannerName, errors }] : [];
      });
    },
    hasScannerErrors() {
      return this.scannerErrors.length > 0;
    },
  },
  created() {
    this.setSourceBranch(this.pipeline.sourceBranch);
    this.setPipelineJobsPath(this.pipeline.jobsPath);
    this.setProjectId(this.projectId);
  },
  methods: {
    ...mapActions('vulnerabilities', ['setSourceBranch']),
    ...mapActions('pipelineJobs', ['setPipelineJobsPath', 'setProjectId']),
  },
};
</script>

<template>
  <div>
    <gl-alert v-if="hasScannerErrors" variant="danger" :dismissible="false" class="gl-my-5">
      <h2>{{ __('Error parsing security reports') }}</h2>
      <p>
        {{
          __(
            'The security reports below contain one or more vulnerability findings that could not be parsed and were not recorded. Download the artifacts in the job output to investigate. Ensure any security report created conforms to the relevant JSON schema.',
          )
        }}
      </p>
      <gl-accordion :header-level="3">
        <gl-accordion-item
          v-for="{ scannerName, errors } in scannerErrors"
          :key="scannerName"
          :title="scannerName"
        >
          {{ errors }}
        </gl-accordion-item>
      </gl-accordion>
    </gl-alert>
    <security-reports-summary
      v-if="securityReportSummary"
      :summary="securityReportSummary"
      class="gl-my-5"
    />
    <security-dashboard
      v-if="!shouldShowGraphqlVulnerabilityReport"
      :vulnerabilities-endpoint="vulnerabilitiesEndpoint"
      :lock-to-project="{ id: projectId }"
      :pipeline-id="pipeline.id"
      :pipeline-iid="pipeline.iid"
      :project-full-path="projectFullPath"
      :loading-error-illustrations="loadingErrorIllustrations"
      :security-report-summary="securityReportSummary"
    >
      <template #empty-state>
        <gl-empty-state v-bind="emptyStateProps" />
      </template>
    </security-dashboard>
    <vulnerability-report v-else />
  </div>
</template>
