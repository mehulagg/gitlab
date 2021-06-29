<script>
import { GlLink, GlSprintf } from '@gitlab/ui';
import * as Sentry from '@sentry/browser';
import { componentNames } from 'ee/reports/components/issue_body';
import { helpPagePath } from '~/helpers/help_page_helper';
import axios from '~/lib/utils/axios_utils';
import { sprintf, s__ } from '~/locale';
import ReportSection from '~/reports/components/report_section.vue';
import { status } from '~/reports/constants';
import { APPROVED, PENDING } from './constants';

export default {
  name: 'StatusChecksReportsApp',
  components: {
    GlLink,
    GlSprintf,
    ReportSection,
  },
  componentNames,
  props: {
    endpoint: {
      type: String,
      required: true,
    },
  },
  data() {
    return {
      reportStatus: status.LOADING,
      statusChecks: [],
    };
  },
  computed: {
    approvedStatusChecks() {
      return this.statusChecks.filter((s) => s.status === APPROVED);
    },
    pendingStatusChecks() {
      return this.statusChecks.filter((s) => s.status === PENDING);
    },
    hasStatusChecks() {
      return this.statusChecks.length > 0;
    },
    headingReportText() {
      if (this.pendingStatusChecks.length > 0) {
        return sprintf(s__('StatusCheck|%{pending} pending'), {
          pending: this.pendingStatusChecks.length,
        });
      }
      return s__('StatusCheck|All passed');
    },
  },
  mounted() {
    this.fetchStatusChecks();
  },
  methods: {
    fetchStatusChecks() {
      axios
        .get(this.endpoint)
        .then(({ data }) => {
          this.statusChecks = data;
          this.reportStatus = status.SUCCESS;
        })
        .catch((error) => {
          this.reportStatus = status.ERROR;
          Sentry.captureException(error);
        });
    },
  },
  i18n: {
    heading: s__('StatusCheck|Status checks'),
    subHeading: s__(
      'StatusCheck|When this merge request is updated, a call is sent to the following APIs to confirm their status. %{linkStart}Learn more%{linkEnd}.',
    ),
    errorText: s__('StatusCheck|Failed to load status checks.'),
  },
  docsLink: helpPagePath('user/project/merge_requests/status_checks.md', {
    anchor: 'status-checks-widget',
  }),
};
</script>

<template>
  <report-section
    :status="reportStatus"
    :loading-text="$options.i18n.heading"
    :error-text="$options.i18n.errorText"
    :has-issues="hasStatusChecks"
    :resolved-issues="approvedStatusChecks"
    :neutral-issues="pendingStatusChecks"
    :component="$options.componentNames.StatusCheckIssueBody"
    :show-report-section-status-icon="false"
    issues-list-container-class="gl-p-0 gl-border-top-0"
    issues-ul-element-class="gl-p-0"
    data-test-id="mr-status-checks"
    class="mr-widget-section mr-report"
  >
    <template #success>
      <p class="gl-line-height-normal gl-m-0">
        {{ $options.i18n.heading }}
        <strong class="gl-p-1">{{ headingReportText }}</strong>
      </p>
    </template>

    <template #sub-heading>
      <span class="gl-text-gray-500 gl-font-sm">
        <gl-sprintf :message="$options.i18n.subHeading">
          <template #link="{ content }">
            <gl-link class="gl-font-sm" :href="$options.docsLink">{{ content }}</gl-link>
          </template>
        </gl-sprintf>
      </span>
    </template>
  </report-section>
</template>
