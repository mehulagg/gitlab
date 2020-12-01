<script>
import { __ } from '~/locale';
import { fetchPolicies } from '~/lib/graphql';
import IterationReportSummaryCards from './iteration_report_summary_cards.vue';
import query from '../queries/iteration_issues_summary_stats.query.graphql';

export default {
  components: {
    IterationReportSummaryCards,
  },
  apollo: {
    issues: {
      query,
      variables() {
        return this.queryVariables;
      },
      update(data) {
        const stats = data.iteration?.report?.stats || {};

        return {
          complete: stats.complete?.count || 0,
          incomplete: stats.incomplete?.count || 0,
          total: stats.total?.count || 0,
        };
      },
    },
  },
  props: {
    iterationId: {
      type: String,
      required: true,
    },
  },
  data() {
    return {
      issues: {
        complete: 0,
        incomplete: 0,
        total: 0,
      },
    };
  },
  computed: {
    queryVariables() {
      return {
        id: this.iterationId,
      };
    },
    columns() {
      return [
        {
          title: __('Completed'),
          value: this.issues.complete,
        },
        {
          title: __('Incomplete'),
          value: this.issues.incomplete,
        },
      ];
    },
  },
};
</script>

<template>
  <iteration-report-summary-cards
    :columns="columns"
    :loading="this.$apollo.queries.issues.loading"
    :total="issues.total"
  />
</template>
