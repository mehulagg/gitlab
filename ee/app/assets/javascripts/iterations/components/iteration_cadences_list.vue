<script>
import { GlAlert, GlButton, GlLoadingIcon, GlPagination, GlTab, GlTabs } from '@gitlab/ui';
import { __, s__ } from '~/locale';
import query from '../queries/iteration_cadences_list.query.graphql';
import IterationCadence from './iteration_cadence.vue';

const pageSize = 20;

export default {
  tabTitles: [__('Open'), __('Done'), __('All')],
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
          iterationCadences: data.group?.iterationCadences?.nodes || [],
          pageInfo: data.group?.iterationCadences?.pageInfo || {},
        };
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

      if (this.active !== undefined) {
        vars.active = this.active;
      }

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
    active() {
      switch (this.tabIndex) {
        default:
        case 0:
          return true;
        case 1:
          return false;
        case 2:
          return undefined;
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
    <gl-tab v-for="tab in $options.tabTitles" :key="tab">
      <template #title>
        {{ tab }}
      </template>
      <gl-loading-icon v-if="loading" class="gl-my-5" size="lg" />

      <gl-alert v-else-if="error" variant="danger" @dismiss="error = ''">
        {{ error }}
      </gl-alert>
      <template v-else>
        <ul v-if="cadences.length" class="content-list">
          <iteration-cadence
            v-for="cadence in cadences"
            :key="cadence.id"
            :cadence-id="cadence.id"
            :title="cadence.title"
          />
        </ul>
        <p v-else class="nothing-here-block">
          {{ s__('Iterations|No iteration cadences to show.') }}
        </p>
        <gl-pagination
          v-if="prevPage || nextPage"
          :value="pagination.currentPage"
          :prev-page="prevPage"
          :next-page="nextPage"
          align="center"
          class="gl-pagination gl-mt-3"
          @input="handlePageChange"
        />
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
