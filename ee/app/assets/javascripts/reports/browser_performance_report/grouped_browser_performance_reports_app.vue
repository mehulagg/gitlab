<script>
import { once } from 'lodash';
import { componentNames } from 'ee/reports/components/issue_body';
import ReportSection from '~/reports/components/report_section.vue';
import glFeatureFlagsMixin from '~/vue_shared/mixins/gl_feature_flags_mixin';
import api from '~/api';

export default {
  name: 'GroupedBrowserPerformanceReportsApp',
  components: {
    ReportSection,
  },
  mixins: [glFeatureFlagsMixin()],
  props: {
    status: {
      type: String,
      required: true,
    },
    loadingText: {
      type: String,
      required: true,
    },
    errorText: {
      type: String,
      required: true,
    },
    successText: {
      type: String,
      required: true,
    },
    unresolvedIssues: {
      type: Array,
      required: true,
    },
    resolvedIssues: {
      type: Array,
      required: true,
    },
    neutralIssues: {
      type: Array,
      required: true,
    },
    hasIssues: {
      type: Boolean,
      required: true,
    },
  },
  componentNames,
  computed: {
    handleBrowserPerformanceToggleEvent() {
      return once(() => {
        if (this.glFeatures.usageDataITestingWebPerformanceWidgetTotal) {
          api.trackRedisHllUserEvent(this.$options.expandEvent);
        }
      });
    },
  },
  expandEvent: 'i_testing_web_performance_widget_total',
};
</script>
<template>
  <report-section
    :status="status"
    :loading-text="loadingText"
    :error-text="errorText"
    :success-text="successText"
    :unresolved-issues="unresolvedIssues"
    :resolved-issues="resolvedIssues"
    :neutral-issues="neutralIssues"
    :has-issues="hasIssues"
    :component="$options.componentNames.PerformanceIssueBody"
    should-emit-toggle-event
    class="js-browser-performance-widget mr-widget-border-top mr-report"
    @toggleEvent="handleBrowserPerformanceToggleEvent"
  />
</template>
