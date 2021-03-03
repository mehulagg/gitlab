<script>
import api from '~/api';
import { s__ } from '~/locale';
import glFeatureFlagsMixin from '~/vue_shared/mixins/gl_feature_flags_mixin';
import DownloadTestCoverage from './download_test_coverage.vue';
import TestCoverageSummary from './test_coverage_summary.vue';
import TestCoverageTable from './test_coverage_table.vue';

export default {
  name: 'GroupRepositoryAnalytics',
  components: {
    TestCoverageSummary,
    TestCoverageTable,
    DownloadTestCoverage,
  },
  mixins: [glFeatureFlagsMixin()],
  mounted() {
    if (this.glFeatures.usageDataITestingGroupCodeCoverageVisitTotal) {
      api.trackRedisHllUserEvent(this.$options.groupCoverageVisitEvent);
    }
  },
  text: {
    codeCoverageHeader: s__('RepositoriesAnalytics|Test Code Coverage'),
  },
  groupCoverageVisitEvent: 'i_testing_group_code_coverage_visit_total',
};
</script>

<template>
  <div>
    <h4 data-testid="test-coverage-header">
      {{ $options.text.codeCoverageHeader }}
    </h4>
    <test-coverage-summary class="gl-mb-5" />
    <test-coverage-table class="gl-mb-5" />
    <download-test-coverage />
  </div>
</template>
