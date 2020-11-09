<script>
import { GlAlert, GlBadge, GlKeysetPagination, GlLoadingIcon, GlTab, GlTabs } from '@gitlab/ui';
import getStatesQuery from '../graphql/queries/get_states.query.graphql';
import EmptyState from './empty_state.vue';
import StatesTable from './states_table.vue';

export default {
  apollo: {
    states: {
      query: getStatesQuery,
      variables() {
        return {
          after: this.cursor.after,
          before: this.cursor.before,
          projectPath: this.projectPath,
        };
      },
      update: data => {
        return {
          count: data?.project?.terraformStates?.count,
          list: data?.project?.terraformStates?.nodes,
          pageInfo: data?.project?.terraformStates?.pageInfo,
        };
      },
      error() {
        this.states = null;
      },
    },
  },
  components: {
    EmptyState,
    GlAlert,
    GlBadge,
    GlKeysetPagination,
    GlLoadingIcon,
    GlTab,
    GlTabs,
    StatesTable,
  },
  props: {
    emptyStateImage: {
      required: true,
      type: String,
    },
    projectPath: {
      required: true,
      type: String,
    },
  },
  data() {
    return {
      cursor: {
        before: null,
        after: null,
      },
    };
  },
  computed: {
    isLoading() {
      return this.$apollo.queries.states.loading;
    },
    pageInfo() {
      return this.states?.pageInfo || {};
    },
    statesCount() {
      return this.states?.count;
    },
    statesList() {
      return this.states?.list;
    },
  },
  methods: {
    updatePagination(item) {
      if (item === this.pageInfo.endCursor) {
        this.cursor = {
          after: item,
          before: null,
        };
      } else {
        this.cursor = {
          after: null,
          before: item,
        };
      }
    },
  },
};
</script>

<template>
  <section>
    <gl-tabs>
      <gl-tab>
        <template slot="title">
          <p class="gl-m-0">
            {{ s__('Terraform|States') }}
            <gl-badge v-if="statesCount">{{ statesCount }}</gl-badge>
          </p>
        </template>

        <gl-loading-icon v-if="isLoading" size="md" class="gl-mt-3" />

        <div v-else-if="statesList">
          <div v-if="statesCount">
            <states-table :states="statesList" />

            <div class="gl-display-flex gl-justify-content-center gl-mt-5">
              <gl-keyset-pagination
                v-bind="pageInfo"
                @prev="updatePagination"
                @next="updatePagination"
              />
            </div>
          </div>

          <empty-state v-else :image="emptyStateImage" />
        </div>

        <gl-alert v-else variant="danger" :dismissible="false">
          {{ s__('Terraform|An error occurred while loading your Terraform States') }}
        </gl-alert>
      </gl-tab>
    </gl-tabs>
  </section>
</template>
