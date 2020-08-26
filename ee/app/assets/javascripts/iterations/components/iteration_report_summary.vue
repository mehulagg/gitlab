<script>
import { GlCard, GlIcon } from '@gitlab/ui';
import { __ } from '~/locale';
import { getIdFromGraphQLId } from '~/graphql_shared/utils';
import query from '../queries/iteration_issues_summary.query.graphql';

export default {
  cardBodyClass: 'gl-text-center gl-py-3',
  cardClass: 'gl-bg-gray-10 gl-border-0',
  components: {
    GlCard,
    GlIcon,
  },
  apollo: {
    issues: {
      query,
      variables() {
        return this.queryVariables;
      },
      update(data) {
        return {
          open: data?.group?.openIssues?.count || 0,
          assigned: data?.group?.assignedIssues?.count || 0,
          closed: data?.group?.closedIssues?.count || 0,
        };
      },
      error() {
        this.error = __('Error loading issues');
      },
    },
  },
  props: {
    groupPath: {
      type: String,
      required: true,
    },
    iterationId: {
      type: String,
      required: true,
    },
  },
  data() {
    return {
      issues: {},
    };
  },
  computed: {
    queryVariables() {
      return {
        groupPath: this.groupPath,
        id: getIdFromGraphQLId(this.iterationId),
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
    showCards() {
      return !this.$apollo.queries.issues.loading && Object.values(this.issues).every(a => a >= 0);
    },
    columns() {
      return [
        {
          title: __('Complete'),
          value: `${this.completedPercent}%`,
        },
        {
          title: __('Open'),
          value: this.issues.open,
          icon: true,
        },
        {
          title: __('In progress'),
          value: this.issues.assigned,
          icon: true,
        },
        {
          title: __('Completed'),
          value: this.issues.closed,
          icon: true,
        },
      ];
    },
  },

  emits: [],
};
</script>

<template>
  <div v-if="showCards" class="row gl-mt-6">
    <div v-for="(column, index) in columns" :key="index" class="col-sm-3">
      <gl-card :class="$options.cardClass" :body-class="$options.cardBodyClass">
        <span>{{ column.title }}</span>
        <span class="gl-font-size-h2 gl-font-weight-bold">{{ column.value }}</span>
        <gl-icon v-if="column.icon" name="issues" :size="12" class="gl-text-gray-500" />
      </gl-card>
    </div>
  </div>
</template>
