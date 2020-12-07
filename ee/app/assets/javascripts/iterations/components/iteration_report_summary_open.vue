<script>
import { __ } from '~/locale';
import { getIdFromGraphQLId } from '~/graphql_shared/utils';
import IterationReportSummaryCards from './iteration_report_summary_cards.vue';
import summaryStatsQuery from '../queries/iteration_issues_summary.query.graphql';
import { Namespace } from '../constants';

export default {
  components: {
    IterationReportSummaryCards,
  },
  apollo: {
    issues: {
      query: summaryStatsQuery,
      variables() {
        return this.queryVariables;
      },
      update(data) {
        return {
          open: data[this.namespaceType]?.openIssues?.[this.displayValue] || 0,
          assigned: data[this.namespaceType]?.assignedIssues?.[this.displayValue] || 0,
          closed: data[this.namespaceType]?.closedIssues?.[this.displayValue] || 0,
        };
      },
      error() {
        this.error = __('Error loading issues');
      },
    },
  },
  props: {
    fullPath: {
      type: String,
      required: true,
    },
    iterationId: {
      type: String,
      required: true,
    },
    namespaceType: {
      type: String,
      required: false,
      default: Namespace.Group,
      validator: value => Object.values(Namespace).includes(value),
    },
    displayValue: {
      type: String,
      required: false,
      default: 'count',
      validator: val => ['count', 'weight'].includes(val),
    },
  },
  data() {
    return {
      issues: {
        assigned: 0,
        open: 0,
        closed: 0,
      },
    };
  },
  computed: {
    queryVariables() {
      return {
        fullPath: this.fullPath,
        id: getIdFromGraphQLId(this.iterationId),
        isGroup: this.namespaceType === Namespace.Group,
        displayValue: this.displayValue,
      };
    },
    completedPercent() {
      const open = this.issues.open + this.issues.assigned;
      const { closed } = this.issues;
      if (closed <= 0) {
        return 0;
      }
      return ((closed / (open + closed)) * 100).toFixed(0);
    },
    columns() {
      return [
        {
          title: __('Completed'),
          value: this.issues.closed,
        },
        {
          title: __('Incomplete'),
          value: this.issues.assigned,
        },
        {
          title: __('Unstarted'),
          value: this.issues.open,
        },
      ];
    },
    total() {
      return this.issues.open + this.issues.assigned + this.issues.closed;
    },
  },
  methods: {
    percent(val) {
      if (!this.total) return 0;
      return ((val / this.total) * 100).toFixed(0);
    },
  },
  render() {
    return this.$scopedSlots.default({
      columns: this.columns,
      loading: this.$apollo.queries.issues.loading,
      total: this.total,
    });
  },
};
</script>
