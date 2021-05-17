<script>
import { GlAlert, GlButton, GlLoadingIcon, GlKeysetPagination, GlTab, GlTabs } from '@gitlab/ui';
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
        iterationCadences: [],
        pageInfo: {
          hasNextPage: true,
          hasPreviousPage: false,
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
      return this.group?.iterationCadences?.nodes || [];
    },
    pageInfo() {
      return this.group?.iterationCadences?.pageInfo || {};
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
          <iteration-cadence v-for="cadence in cadences" :key="cadence.id" :title="cadence.title" />
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
