<script>
import { GlAlert, GlButton, GlLoadingIcon, GlPagination, GlTab, GlTabs } from '@gitlab/ui';
import { __ } from '~/locale';
import query from '../queries/iteration_cadences_list.query.graphql';
import IterationCadence from './iteration_cadence.vue';

const pageSize = 20;

export default {
  components: {
    IterationCadence,
    GlAlert,
    GlButton,
    GlLoadingIcon,
    GlPagination,
    GlTab,
    GlTabs,
  },
  apollo: {
    group: {
      query,
      variables() {
        return this.queryVariables;
      },
      update(data) {
        return {
          iterationCadences: data.group.iterationCadences?.nodes || [],
          pageInfo: data.group.iterationCadences?.pageInfo || {},
        };
      },
      error({ message }) {
        this.error = message || __('Error loading iterations');
      },
    },
  },
  inject: ['groupPath', 'cadencesListPath', 'canCreateCadence'],
  data() {
    return {
      group: {
        iterationCadences: [],
        pageInfo: {
          hasNextPage: true,
          hasPreviousPage: false,
        },
      },
      pagination: {
        currentPage: 1,
      },
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
      return this.group.iterationCadences;
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
    prevPage() {
      return Number(this.group.pageInfo.hasPreviousPage);
    },
    nextPage() {
      return Number(this.group.pageInfo.hasNextPage);
    },
  },
  methods: {
    handlePageChange(page) {
      const { startCursor, endCursor } = this.group.pageInfo;

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
    handleTabChange() {
      this.pagination = { currentPage: 1 };
    },
  },
};
</script>

<template>
  <gl-tabs v-model="tabIndex" @activate-tab="handleTabChange">
    <gl-tab v-for="tab in [__('Open'), __('Done'), __('All')]" :key="tab">
      <template #title>
        {{ tab }}
      </template>
      <div v-if="loading" class="gl-my-5">
        <gl-loading-icon size="lg" />
      </div>
      <div v-else-if="error">
        <gl-alert variant="danger" @dismiss="error = ''">
          {{ error }}
        </gl-alert>
      </div>
      <div v-else>
        <ul v-if="cadences.length > 0" class="content-list">
          <iteration-cadence v-for="cadence in cadences" :key="cadence.id" :title="cadence.title" />
        </ul>
        <div v-else class="nothing-here-block">
          {{ __('No iteration cadences to show') }}
        </div>
        <gl-pagination
          v-if="prevPage || nextPage"
          :value="pagination.currentPage"
          :prev-page="prevPage"
          :next-page="nextPage"
          align="center"
          class="gl-pagination gl-mt-3"
          @input="handlePageChange"
        />
      </div>
    </gl-tab>
    <template v-if="canCreateCadence" #tabs-end>
      <li class="gl-ml-auto gl-display-flex gl-align-items-center">
        <gl-button
          variant="confirm"
          data-qa-selector="new_iteration_button"
          :to="{
            name: 'new',
          }"
        >
          {{ __('New iteration') }}
        </gl-button>
      </li>
    </template>
  </gl-tabs>
</template>
