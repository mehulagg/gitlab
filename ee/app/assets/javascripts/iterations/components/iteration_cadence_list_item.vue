<script>
import {
  GlAlert,
  GlButton,
  GlCollapse,
  GlIcon,
  GlInfiniteScroll,
  GlSkeletonLoader,
} from '@gitlab/ui';
import { getIdFromGraphQLId } from '~/graphql_shared/utils';
import { __, s__ } from '~/locale';
import query from '../queries/iterations_in_cadence.query.graphql';

const pageSize = 20;

const i18n = Object.freeze({
  noResults: s__('Iterations|No iterations in cadence.'),
  error: __('Error loading iterations'),
});

export default {
  i18n,
  components: {
    GlAlert,
    GlButton,
    GlCollapse,
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
        this.error = i18n.error;
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
    iterationState: {
      type: String,
      required: true,
    },
  },
  data() {
    return {
      i18n,
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
        state: this.iterationState,
      };
    },
    pageInfo() {
      return this.group.iterations?.pageInfo || {};
    },
    hasNextPage() {
      return this.pageInfo.hasNextPage;
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
      if (this.iterations.length === 0 || !this.hasNextPage || this.loading) {
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

          return {
            group: {
              // eslint-disable-next-line @gitlab/require-i18n-strings
              __typename: 'Group',
              iterations: {
                __typename: 'IterationConnection',
                // Merging the list
                nodes: [...previousResult.group.iterations.nodes, ...newIterations],
                pageInfo: fetchMoreResult.group?.iterations.pageInfo || {},
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
        variant="link"
        class="gl-font-weight-bold gl-text-body! gl-py-5! gl-px-3! gl-mr-auto"
        :aria-expanded="expanded"
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
    </div>

    <gl-alert v-if="error" variant="danger" :dismissible="true" @dismiss="error = ''">
      {{ error }}
    </gl-alert>

    <gl-collapse :visible="expanded">
      <div v-if="loading && iterations.length === 0" class="gl-p-5">
        <gl-skeleton-loader :lines="2" />
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
          <div v-if="loading" class="gl-p-5">
            <gl-skeleton-loader :lines="2" />
          </div>
        </template>
      </gl-infinite-scroll>
      <p v-else-if="!loading" class="gl-px-5">
        {{ i18n.noResults }}
      </p>
    </gl-collapse>
  </li>
</template>
