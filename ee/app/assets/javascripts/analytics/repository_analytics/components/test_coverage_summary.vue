<script>
import { __, s__ } from '~/locale';
import MetricCard from '~/analytics/shared/components/metric_card.vue';
import getGroupTestCoverage from '../graphql/queries/get_group_test_coverage.query.graphql';

export default {
  name: 'TestCoverageSummary',
  components: {
    MetricCard,
  },
  inject: {
    groupFullPath: {
      default: '',
    },
  },
  apollo: {
    group: {
      query: getGroupTestCoverage,
      variables() {
        const ONE_WEEK = 7 * 24 * 60 * 60 * 1000; // milliseconds

        return {
          groupFullPath: this.groupFullPath,
          startDate: new Date(Date.now() - ONE_WEEK),
        };
      },
      result(res) {
        const { projectCount, averageCoverage, coverageCount } =
          res.data?.group?.codeCoverageActivities?.nodes?.[0] || {};

        this.projectCount = projectCount;
        this.averageCoverage = averageCoverage;
        this.coverageCount = coverageCount;
      },
      error() {
        this.hasError = true;
        this.projectCount = null;
        this.averageCoverage = null;
        this.coverageCount = null;
      },
      watchLoading(isLoading) {
        this.isLoading = isLoading;
      },
    },
  },
  data() {
    return {
      projectCount: null,
      averageCoverage: null,
      coverageCount: null,
      hasError: false,
      isLoading: false,
    };
  },
  i18n: {
    cardTitle: __('Overall Activity'),
  },
  computed: {
    metrics() {
      return [
        {
          key: 'projectCount',
          value: this.projectCount,
          label: s__('RepositoriesAnalytics|Projects with Tests'),
        },
        {
          key: 'averageCoverage',
          value: this.averageCoverage,
          unit: '%',
          label: s__('RepositoriesAnalytics|Average Coverage by Job'),
        },
        {
          key: 'coverageCount',
          value: this.coverageCount,
          label: s__('RepositoriesAnalytics|Total Number of Coverages'),
        },
      ];
    },
  },
};
</script>
<template>
  <metric-card :title="$options.i18n.cardTitle" :metrics="metrics" :is-loading="isLoading" />
</template>
