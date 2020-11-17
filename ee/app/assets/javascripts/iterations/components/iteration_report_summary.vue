<script>
import { GlCard, GlIcon, GlSprintf } from '@gitlab/ui';
import { __ } from '~/locale';
import { fetchPolicies } from '~/lib/graphql';
import query from '../queries/iteration_issues_summary.query.graphql';

export default {
  cardBodyClass: 'gl-text-center gl-py-3',
  cardClass: 'gl-bg-gray-10 gl-border-0',
  components: {
    GlCard,
    GlIcon,
    GlSprintf,
  },
  apollo: {
    issues: {
      fetchPolicy: fetchPolicies.NO_CACHE,
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
      error() {
        this.error = __('Error loading issues');
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
      issues: {},
    };
  },
  computed: {
    queryVariables() {
      return {
        id: this.iterationId,
      };
    },
    showCards() {
      return !this.$apollo.queries.issues.loading && Object.values(this.issues).every(a => a >= 0);
    },
    unstarted() {
      const started = this.issues.complete + this.issues.incomplete;
      return this.issues.total - started;
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
        {
          title: __('Unstarted'),
          value: this.unstarted,
        },
      ];
    },
  },
  methods: {
    percent(val) {
      if (!this.issues.total) return 0;
      return ((val / this.issues.total) * 100).toFixed(0);
    },
  },
};
</script>

<template>
  <div v-if="showCards" class="row gl-mt-6">
    <div v-for="(column, index) in columns" :key="index" class="col-sm-4">
      <gl-card :class="$options.cardClass" :body-class="$options.cardBodyClass" class="gl-mb-5">
        <span
          class="gl-font-size-h2 gl-border-1 gl-border-r-solid gl-border-gray-100 gl-pr-3 gl-mr-2"
        >
          <span>{{ column.title }}</span>
          <span class="gl-font-weight-bold"
            >{{ percent(column.value) }}<small class="gl-text-gray-500">%</small></span
          >
        </span>
        <gl-sprintf :message="__('%{count} of %{total}')">
          <template #count>
            <span class="gl-font-size-h2 gl-font-weight-bold">{{ column.value }}</span>
          </template>
          <template #total>
            <span class="gl-font-size-h2 gl-font-weight-bold">{{ issues.total }}</span>
          </template>
        </gl-sprintf>
        <gl-icon v-if="column.icon" name="issues" :size="12" class="gl-text-gray-500" />
      </gl-card>
    </div>
  </div>
</template>
