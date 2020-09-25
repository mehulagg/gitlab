<script>
import { s__ } from '~/locale';
import DownloadTestCoverage from './download_test_coverage.vue';

export default {
  name: 'GroupRepositoryAnalytics',
  components: {
    DownloadTestCoverage,
  },
  inject: {
    groupAnalyticsCoverageReportsPath: {
      type: String,
      default: '',
    },
    groupFullPath: {
      type: String,
      default: '',
    },
  },
  text: {
    codeCoverageHeader: s__('RepositoriesAnalytics|Test Code Coverage'),
  },
};
</script>

<template>
  <div>
    <h4 class="sub-header" data-testid="test-coverage-header">
      {{ $options.text.codeCoverageHeader }}
    </h4>
    <download-test-coverage
      :group-analytics-coverage-reports-path="groupAnalyticsCoverageReportsPath"
      :group-full-path="groupFullPath"
    />
  </div>
</template>
