<script>
import { GlAlert, GlButton, GlLoadingIcon, GlKeysetPagination, GlTab, GlTabs } from '@gitlab/ui';
import produce from 'immer';
import { __, s__ } from '~/locale';
import destroyIterationCadence from '../queries/destroy_cadence.mutation.graphql';
import query from '../queries/iteration_cadences_list.query.graphql';
import IterationCadenceListItem from './iteration_cadence_list_item.vue';

const pageSize = 20;

export default {
  tabTitles: [__('Open'), __('Done'), __('All')],
  components: {
    IterationCadenceListItem,
    GlAlert,
    GlButton,
    GlLoadingIcon,
    GlKeysetPagination,
    GlTab,
    GlTabs,
  },
  apollo: {
    group: {
      query,
      variables() {
        return this.queryVariables;
      },
      error({ message }) {
        this.error = message || s__('Iterations|Error loading iteration cadences.');
      },
    },
  },
  inject: ['groupPath', 'cadencesListPath', 'canCreateCadence'],
  data() {
    return {
      group: {
        iterationCadences: {
          nodes: [],
          pageInfo: {
            hasNextPage: true,
            hasPreviousPage: false,
          },
        },
      },
      pagination: {},
      tabIndex: 0,
      error: '',
    };
  },
  computed: {
    queryVariables() {
      const vars = {
        fullPath: this.groupPath,
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
    cadences() {
      return this.group?.iterationCadences?.nodes || [];
    },
    pageInfo() {
      return this.group?.iterationCadences?.pageInfo || {};
    },
    loading() {
      return this.$apollo.queries.group.loading;
    },
    state() {
      switch (this.tabIndex) {
        default:
        case 0:
          return 'opened';
        case 1:
          return 'closed';
        case 2:
          return 'all';
      }
    },
  },
  methods: {
    nextPage() {
      this.pagination = {
        afterCursor: this.pageInfo.endCursor,
      };
    },
    previousPage() {
      this.pagination = {
        beforeCursor: this.pageInfo.startCursor,
      };
    },
    handleTabChange() {
      this.pagination = {};
    },
    deleteCadence(cadenceId) {
      this.$apollo
        .mutate({
          mutation: destroyIterationCadence,
          variables: {
            id: cadenceId,
          },
          update: (store, { data: { iterationCadenceDestroy } }) => {
            if (iterationCadenceDestroy.errors?.length) {
              throw iterationCadenceDestroy.errors[0];
            }

            const sourceData = store.readQuery({
              query,
              variables: this.queryVariables,
            });

            const data = produce(sourceData, (draftData) => {
              draftData.group.iterationCadences.nodes = draftData.group.iterationCadences.nodes.filter(
                ({ id }) => id !== cadenceId,
              );
            });

            store.writeQuery({
              query,
              variables: this.queryVariables,
              data,
            });
          },
        })
        .catch((err) => {
          this.error = err;
        });
    },
  },
};
</script>

<template>
  <gl-tabs v-model="tabIndex" @activate-tab="handleTabChange">
    <gl-tab v-for="tab in $options.tabTitles" :key="tab">
      <template #title>
        {{ tab }}
      </template>

      <gl-alert v-if="error" variant="danger" @dismiss="error = ''">
        {{ error }}
      </gl-alert>

      <gl-loading-icon v-if="loading" class="gl-my-5" size="lg" />

      <template v-else>
        <ul v-if="cadences.length" class="content-list">
          <iteration-cadence-list-item
            v-for="cadence in cadences"
            :key="cadence.id"
            :cadence-id="cadence.id"
            :duration-in-weeks="cadence.durationInWeeks"
            :automatic="cadence.automatic"
            :title="cadence.title"
            :iteration-state="state"
            @delete-cadence="deleteCadence"
          />
        </ul>
        <p v-else class="nothing-here-block">
          {{ s__('Iterations|No iteration cadences to show.') }}
        </p>
        <div
          v-if="pageInfo.hasNextPage || pageInfo.hasPreviousPage"
          class="gl-display-flex gl-justify-content-center gl-mt-3"
        >
          <gl-keyset-pagination
            :has-next-page="pageInfo.hasNextPage"
            :has-previous-page="pageInfo.hasPreviousPage"
            @prev="previousPage"
            @next="nextPage"
          />
        </div>
      </template>
    </gl-tab>
    <template v-if="canCreateCadence" #tabs-end>
      <li class="gl-ml-auto gl-display-flex gl-align-items-center">
        <gl-button
          variant="confirm"
          data-qa-selector="create_cadence_button"
          :to="{
            name: 'new',
          }"
        >
          {{ s__('Iterations|New iteration cadence') }}
        </gl-button>
      </li>
    </template>
  </gl-tabs>
</template>
