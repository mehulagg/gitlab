<script>
import {
  GlAlert,
  GlButton,
  GlCollapse,
  GlDropdown,
  GlDropdownItem,
  GlIcon,
  GlInfiniteScroll,
  GlModal,
  GlSkeletonLoader,
} from '@gitlab/ui';
import { getIdFromGraphQLId } from '~/graphql_shared/utils';
import { __, s__ } from '~/locale';
import query from '../queries/iterations_in_cadence.query.graphql';

const pageSize = 20;

const i18n = Object.freeze({
  noResults: s__('Iterations|No iterations in cadence.'),
  error: __('Error loading iterations'),

  deleteCadence: s__('Iterations|Delete cadence'),
  modalTitle: s__('Iterations|Delete iteration cadence?'),
  modalText: s__(
    'Iterations|This will delete the cadence as well as all of the iterations within it.',
  ),
  modalConfirm: s__('Iterations|Delete cadence'),
  modalCancel: __('Cancel'),
});

export default {
  i18n,
  components: {
    GlAlert,
    GlButton,
    GlCollapse,
    GlDropdown,
    GlDropdownItem,
    GlIcon,
    GlInfiniteScroll,
    GlModal,
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
  inject: ['groupPath', 'canEditCadence'],
  props: {
    title: {
      type: String,
      required: true,
    },
    automatic: {
      type: Boolean,
      required: false,
      default: false,
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
    newIteration() {
      return {
        name: 'newIteration',
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
    showModal() {
      this.$refs.modal.show();
    },
    focusMenu() {
      this.$refs.menu.$el.focus();
    },
  },
};
</script>

<template>
  <li class="gl-py-0!">
    <div class="gl-display-flex gl-align-items-center">
      <gl-button
        variant="link"
        class="gl-font-weight-bold gl-text-body! gl-py-5! gl-px-3! gl-mr-auto gl-min-w-0"
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

      <span v-if="durationInWeeks" class="gl-mr-5 gl-display-none gl-sm-display-inline-block">
        <gl-icon name="clock" class="gl-mr-3" />
        {{ n__('Every week', 'Every %d weeks', durationInWeeks) }}</span
      >
      <gl-dropdown
        v-if="canEditCadence"
        ref="menu"
        icon="ellipsis_v"
        category="tertiary"
        right
        text-sr-only
        no-caret
      >
        <gl-dropdown-item v-if="!automatic" :to="newIteration">
          {{ s__('Iterations|Add iteration') }}
        </gl-dropdown-item>

        <gl-dropdown-item :to="editCadence">
          {{ s__('Iterations|Edit cadence') }}
        </gl-dropdown-item>
        <gl-dropdown-item data-testid="delete-cadence" @click="showModal">
          {{ i18n.deleteCadence }}
        </gl-dropdown-item>
      </gl-dropdown>
      <gl-modal
        ref="modal"
        :modal-id="`${cadenceId}-delete-modal`"
        :title="i18n.modalTitle"
        :ok-title="i18n.modalConfirm"
        ok-variant="danger"
        @hidden="focusMenu"
        @ok="$emit('delete-cadence', cadenceId)"
      >
        {{ i18n.modalText }}
      </gl-modal>
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
