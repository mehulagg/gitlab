<script>
import {
  GlButton,
  GlCollapse,
  GlDropdown,
  GlIcon,
  GlInfiniteScroll,
  GlSkeletonLoader,
} from '@gitlab/ui';
import { getIdFromGraphQLId } from '~/graphql_shared/utils';
import { __ } from '~/locale';
import query from '../queries/iterations_in_cadence.query.graphql';

const pageSize = 20;

export default {
  components: { GlButton, GlCollapse, GlDropdown, GlIcon, GlInfiniteScroll, GlSkeletonLoader },
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
        const iterations = data.group?.iterations?.nodes || [];

        this.iterations = [...this.iterations, ...iterations];

        return data;
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
    durationInWeeks: {
      type: Number,
      required: false,
      default: null,
    },
    cadenceId: {
      type: String,
      required: true,
    },
  },
  data() {
    return {
      expanded: false,
      // query response
      group: {
        iterations: {
          nodes: [],
          pageInfo: {
            hasNextPage: true,
          },
        },
      },
      iterations: [],
      pagination: {
        currentPage: 1,
      },
      afterCursor: null,
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
        vars.afterCursor = this.afterCursor;
        vars.firstPageSize = pageSize;
      }

      return vars;
    },
    pageInfo() {
      return this.group.iterations?.pageInfo || {};
    },
    loading() {
      return this.$apollo.queries.group.loading;
    },
    editCadence() {
      return {
        name: 'edit',
      };
    },
  },
  methods: {
    nextPage() {
      if (this.loading) {
        return;
      }
      this.afterCursor = this.pageInfo.endCursor;
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
    <div class="gl-display-flex gl-align-items-center">
      <gl-button
        data-testid="accordion-button"
        variant="link"
        class="gl-font-weight-bold gl-text-body! gl-py-5! gl-px-3! gl-mr-auto"
        @click="expanded = !expanded"
      >
        <gl-icon
          name="chevron-right"
          class="gl-transition-medium"
          :class="{ 'gl-rotate-90': expanded }"
        />
        {{ title }}
      </gl-button>

      <span v-if="durationInWeeks" class="gl-mr-5">
        <gl-icon name="clock" class="gl-mr-3" />
        {{ n__('Every week', 'Every %d weeks', durationInWeeks) }}</span
      >
      <!-- todo: v-if permission check -->
      <gl-dropdown icon="ellipsis_v" category="tertiary" right lazy text-sr-only no-caret>
        <gl-dropdown-item :to="editCadence">
          {{ s__('Iterations|Edit cadence') }}
        </gl-dropdown-item>
      </gl-dropdown>
    </div>

    <!-- <gl-alert v-if="hasError" variant="danger" :dismissible="true">
      {{ __('Error fetching iterations') }}
    </gl-alert> -->

    <gl-collapse :visible="expanded">
      <gl-infinite-scroll
        v-if="iterations.length || loading"
        :fetched-items="iterations.length"
        :max-list-height="250"
        @bottomReached="nextPage"
      >
        <template #items>
          <ol class="gl-pl-0">
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
          <div v-if="loading" class="gl-p-5!">
            <gl-skeleton-loader :lines="3" />
          </div>
        </template>
      </gl-infinite-scroll>
      <p v-else-if="!loading" class="gl-px-5">
        {{ s__('Iterations|No iterations in cadence') }}
      </p>
    </gl-collapse>
  </li>
</template>
