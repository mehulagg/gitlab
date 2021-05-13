<script>
import { GlButton, GlCollapse, GlIcon } from '@gitlab/ui';
import { __ } from '~/locale';
import query from '../queries/iterations_in_cadence.query.graphql';

const pageSize = 20;

export default {
  components: { GlButton, GlCollapse, GlIcon },
  apollo: {
    group: {
      skip() {
        return !this.expanded;
      },
      query,
      variables() {
        return this.queryVariables;
      },
      update(data) {
        return {
          iterations: data.group.iterations?.nodes || [],
          pageInfo: data.group.iterations?.pageInfo || {},
        };
      },
      error() {
        this.error = __('Error loading iterations');
      },
    },
  },
  inject: ['groupPath'],
  props: {
    title: {
      type: String,
      required: true,
    },
    cadenceId: {
      type: String,
      required: true,
    },
  },
  data() {
    return {
      expanded: false,
      group: {
        iterations: [],
        pageInfo: {
          hasNextPage: true,
          hasPreviousPage: false,
        },
      },
      pagination: {
        currentPage: 1,
      },
      error: '',
    };
  },
  computed: {
    queryVariables() {
      const vars = {
        fullPath: this.groupPath,
        iterationCadenceId: this.cadenceId,
      };

      if (this.pagination.beforeCursor) {
        vars.beforeCursor = this.pagination.beforeCursor;
        vars.lastPageSize = pageSize;
      } else {
        vars.afterCursor = this.pagination.afterCursor;
        vars.firstPageSize = pageSize;
      }

      return vars;
    },
    iterations() {
      return this.group.iterations;
    },
    loading() {
      return this.$apollo.queries.iterations.loading;
    },
    prevPage() {
      return Number(this.group.pageInfo.hasPreviousPage);
    },
    nextPage() {
      return Number(this.group.pageInfo.hasNextPage);
    },
  },
  methods: {
    handlePageChange(page) {
      const { startCursor, endCursor } = this.iterationCadence.pageInfo;

      if (page > this.pagination.currentPage) {
        this.pagination = {
          afterCursor: endCursor,
          currentPage: page,
        };
      } else {
        this.pagination = {
          beforeCursor: startCursor,
          currentPage: page,
        };
      }
    },
  },
};
</script>

<template>
  <li>
    <<<<<<< HEAD
    <gl-button
      data-testid="accordion-button"
      variant="link"
      class="gl-font-weight-bold gl-text-body!"
      @click="expanded = !expanded"
    >
      <gl-icon
        name="chevron-right"
        class="gl-transition-medium"
        :class="{ 'gl-rotate-90': expanded }"
      />
      {{ title }}
    </gl-button>

    <!-- frequency -->
    <!-- dropdown with actions -->

    <gl-collapse :visible="expanded">
      <ol>
        <li v-for="iteration in iterations" :key="iteration.id">
          {{ iteration.title }}
        </li>
      </ol>
    </gl-collapse>
    =======
    {{ title }}
    >>>>>>> 20c562286cc9d3418a9b97842b4bedb14d788614
  </li>
</template>
