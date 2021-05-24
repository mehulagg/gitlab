<script>
import {
  GlButton,
  GlCollapse,
  GlDropdown,
  GlDropdownItem,
  GlIcon,
  GlInfiniteScroll,
  GlSkeletonLoader,
} from '@gitlab/ui';
import { getIdFromGraphQLId } from '~/graphql_shared/utils';
import { __ } from '~/locale';
import query from '../queries/iterations_in_cadence.query.graphql';

const pageSize = 20;

export default {
  components: {
    GlButton,
    GlCollapse,
    GlDropdown,
    GlDropdownItem,
    GlIcon,
    GlInfiniteScroll,
    GlSkeletonLoader,
  },
  apollo: {
    group: {
      skip() {
        return !this.expanded;
      },
      query,
      variables() {
        return this.queryVariables;
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
      afterCursor: null,
      showMoreEnabled: true,
      error: '',
    };
  },
  computed: {
    queryVariables() {
      return {
        fullPath: this.groupPath,
        iterationCadenceId: this.cadenceId,
        firstPageSize: pageSize,
      };
    },
    pageInfo() {
      return this.group.iterations?.pageInfo || {};
    },
    iterations() {
      return this.group?.iterations?.nodes || [];
    },
    loading() {
      return this.$apollo.queries.group.loading;
    },
    editCadence() {
      return {
        name: 'edit',
        params: {
          cadenceId: getIdFromGraphQLId(this.cadenceId),
        },
      };
    },
  },
  methods: {
    fetchMore() {
      if (this.iterations.length === 0 || !this.showMoreEnabled || this.loading) {
        return;
      }

      // Fetch more data and transform the original result
      this.$apollo.queries.group.fetchMore({
        variables: {
          ...this.queryVariables,
          afterCursor: this.pageInfo.endCursor,
        },
        // Transform the previous result with new data
        updateQuery: (previousResult, { fetchMoreResult }) => {
          const newIterations = fetchMoreResult.group?.iterations.nodes || [];
          const { hasNextPage } = fetchMoreResult.group?.iterations.pageInfo || {};

          this.showMoreEnabled = hasNextPage;

          return {
            group: {
              // eslint-disable-next-line no-underscore-dangle
              __typename: previousResult.group.__typename,
              iterations: {
                // eslint-disable-next-line no-underscore-dangle
                __typename: previousResult.group.iterations.__typename,
                // Merging the list
                nodes: [...previousResult.group.iterations.nodes, ...newIterations],
                pageInfo: fetchMoreResult.group?.iterations.pageInfo || {},
                hasNextPage,
              },
            },
          };
        },
      });
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
      <div v-if="loading && iterations.length === 0" class="gl-p-5!">
        <gl-skeleton-loader :lines="3" />
      </div>
      <gl-infinite-scroll
        v-else-if="iterations.length || loading"
        :fetched-items="iterations.length"
        :max-list-height="250"
        @bottomReached="fetchMore"
      >
        <template #items>
          <ol class="gl-pl-0">
            <li
              v-for="iteration in iterations"
              :key="iteration.id"
              class="gl-bg-gray-10 gl-p-5 gl-border-t-solid gl-border-gray-100 gl-border-t-1 gl-list-style-position-inside"
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
      <p v-else-if="!loading" class="gl-px-7">
        {{ s__('Iterations|No iterations in cadence') }}
      </p>
    </gl-collapse>
  </li>
</template>
