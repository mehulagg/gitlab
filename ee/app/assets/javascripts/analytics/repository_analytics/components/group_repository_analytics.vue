<script>
import { s__ } from '~/locale';
import glFeatureFlagsMixin from '~/vue_shared/mixins/gl_feature_flags_mixin';
import TestCoverageTable from './test_coverage_table.vue';
import DownloadTestCoverage from './download_test_coverage.vue';

export default {
  name: 'GroupRepositoryAnalytics',
  components: {
    TestCoverageTable,
    DownloadTestCoverage,
  },
  mixins: [glFeatureFlagsMixin()],
  text: {
    codeCoverageHeader: s__('RepositoriesAnalytics|Test Code Coverage'),
  },
  computed: {
    shouldShowCoverageReport() {
      return this.glFeatures.groupCoverageDataReport;
    },
  },
};
</script>

<template>
  <div>
    <h4 data-testid="test-coverage-header">
      {{ $options.text.codeCoverageHeader }}
    </h4>
    <test-coverage-table v-if="shouldShowCoverageReport" class="gl-mb-5" />
    <download-test-coverage />
  </div>
</template>
