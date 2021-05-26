<script>
import { GlLink, GlSprintf } from '@gitlab/ui';
import { componentNames } from 'ee/reports/components/issue_body';
import { s__, n__ } from '~/locale';
import ReportSection from '~/reports/components/report_section.vue';
import { status } from '~/reports/constants';

export default {
  name: 'MrWidgetStatusChecks',
  components: {
    GlLink,
    GlSprintf,
    ReportSection,
  },
  componentNames,
  props: {
    projectId: {
      type: Number,
      required: true,
    },
    mergeRequestIid: {
      type: Number,
      required: true,
    },
  },
  data() {
    return {
      statusChecksStatus: status.SUCCESS, // loading, warning, success
      hasIssues: true,
      passedStatusChecks: [
        {
          name: 'success',
          url: 'http',
        },
      ],
      pendingStatusChecks: [
        {
          name: 'pending',
          url: 'http',
        },
      ],
    };
  },
  computed: {
    headingReportText() {
      if (this.pendingStatusChecks.length > 0) {
        return n__(
          'StatusCheck|%d pending',
          'StatusCheck|%d pending',
          this.pendingStatusChecks.length,
        );
      }
      return s__('StatusCheck|All passed');
    },
  },
  methods: {
    fetchStatusChecks() {
      // [GET] /projects/:id/merge_requests/:merge_request_iid/status_checks
    },
  },
  i18n: {
    heading: s__('StatusCheck|Status checks'),
    subHeading: s__(
      'StatusCheck|When this Merge Request is updated, a call is sent to the following APIs to confirm their status. %{linkStart}Learn more%{linkEnd}.',
    ),
  },
};
</script>

<template>
  <report-section
    :status="statusChecksStatus"
    :loading-text="$options.i18n.heading"
    :has-issues="hasIssues"
    :resolved-issues="passedStatusChecks"
    :neutral-issues="pendingStatusChecks"
    :component="$options.componentNames.StatusCheckIssueBody"
    :show-report-section-status-icon="false"
    issues-list-container-class="gl-p-0 gl-border-top-0"
    class="mr-widget-border-top mr-report"
  >
    <template #success>
      <p class="gl-line-height-normal gl-m-0">
        {{ $options.i18n.heading }}
        <strong class="gl-font-sm gl-p-1">{{ headingReportText }}</strong>
      </p>
    </template>

    <template #sub-heading>
      <span class="gl-text-gray-500 gl-font-sm">
        <gl-sprintf :message="$options.i18n.subHeading">
          <template #link="{ content }">
            <gl-link class="gl-font-sm" href="#">{{ content }}</gl-link>
          </template>
        </gl-sprintf>
      </span>
    </template>
  </report-section>
</template>
