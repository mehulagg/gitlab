<script>
import { GlButton, GlCollapse, GlIcon, GlSkeletonLoader } from '@gitlab/ui';
import { getIdFromGraphQLId } from '~/graphql_shared/utils';
import { __ } from '~/locale';
import query from '../queries/iterations_in_cadence.query.graphql';

const pageSize = 20;

export default {
  components: { GlButton, GlCollapse, GlIcon, GlSkeletonLoader },
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
      return this.$apollo.queries.group.loading;
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
    path(iterationId) {
      return {
        name: 'iteration',
        params: {
          cadenceId: getIdFromGraphQLId(this.cadenceId),
          iterationId: getIdFromGraphQLId(iterationId),
        },
      };
    },
  },
};
</script>

<template>
  <li class="gl-py-0!">
    <gl-button
      data-testid="accordion-button"
      variant="link"
      class="gl-font-weight-bold gl-text-body! gl-py-5! gl-px-3!"
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
      <div v-if="loading" class="gl-p-5!">
        <gl-skeleton-loader :lines="3" />
      </div>
      <ol v-else-if="iterations.length" class="gl-pl-0">
        <li
          v-for="iteration in iterations"
          :key="iteration.id"
          class="gl-bg-gray-50 gl-p-5 gl-border-t-solid gl-border-gray-100 gl-border-t-1 gl-list-style-position-inside"
        >
          <router-link :to="path(iteration.id)">
            {{ iteration.title }}
          </router-link>
        </li>
      </ol>
      <p v-else class="gl-px-5">
        {{ s__('Iterations|No iterations in cadence') }}
      </p>
    </gl-collapse>
  </li>
</template>
