<script>
import { s__ } from '~/locale';
import DownloadTestCoverage from './download_test_coverage.vue';

export default {
  name: 'GroupRepositoryAnalytics',
  components: {
    DownloadTestCoverage,
  },
  text: {
    codeCoverageHeader: s__('RepositoriesAnalytics|Test Code Coverage'),
  },
};
</script>

<template>
  <div>
    <h4 data-testid="test-coverage-header">
      {{ $options.text.codeCoverageHeader }}
    </h4>
    <download-test-coverage />
  </div>
</template>
