<script>
import { GlCard, GlEmptyState, GlSkeletonLoader, GlTable } from '@gitlab/ui';
import { __, s__ } from '~/locale';
import TimeAgoTooltip from '~/vue_shared/components/time_ago_tooltip.vue';
import SelectProjectsDropdown from './select_projects_dropdown.vue';
import getProjectsTestCoverage from '../graphql/queries/get_projects_test_coverage.query.graphql';

export default {
  name: 'TestCoverageTable',
  components: {
    GlCard,
    GlEmptyState,
    GlSkeletonLoader,
    GlTable,
    SelectProjectsDropdown,
    TimeAgoTooltip,
  },
  inject: {
    coverageTableEmptyStateSvgPath: {
      type: String,
      default: '',
    },
  },
  data() {
    return {
      coverageData: [],
      hasError: false,
      allProjectsSelected: false,
      selectedProjectIds: [],
      isLoading: false,
    };
  },
  computed: {
    hasCoverageData() {
      return this.coverageData.length;
    },
  },
  methods: {
    getCoverageData() {
      this.$apollo.addSmartQuery('coverageData', {
        query: getProjectsTestCoverage,
        debounce: 500,
        variables() {
          return {
            projectIds: this.selectedProjectIds,
          };
        },
        update(data) {
          return data.projects.nodes;
        },
        error() {
          this.handleError();
        },
        watchLoading(isLoading) {
          this.isLoading = isLoading;
        },
      });
    },
    handleError() {
      this.hasError = true;
    },
    selectAllProjects(allProjects) {
      this.selectedProjectIds = allProjects.map(project => project.id);
      this.allProjectsSelected = true;
      this.getCoverageData();
    },
    selectProject({ id }) {
      if (this.allProjectsSelected) {
        this.allProjectsSelected = false;
        this.selectedProjectIds = [id];
        this.getCoverageData();
        return;
      }

      const index = this.selectedProjectIds.indexOf(id);
      if (index < 0) {
        this.selectedProjectIds.push(id);
        this.getCoverageData();
        return;
      }

      this.selectedProjectIds.splice(index, 1);
      this.getCoverageData();
    },
  },
  tableFields: [
    {
      key: 'project',
      label: __('Project'),
    },
    {
      key: 'coverage',
      label: __('Coverage'),
    },
    {
      key: 'numberOfCoverages',
      label: __('Number of Coverages'),
    },
    {
      key: 'lastUpdate',
      label: __('Last Update'),
    },
  ],
  text: {
    emptyStateTitle: s__('RepositoriesAnalytics|Please select projects to display.'),
    emptyStateDescription: s__(
      'RepositoriesAnalytics|Please select a project or multiple projects to display their most recent test coverage data.',
    ),
  },
};
</script>
<template>
  <gl-card>
    <template #header>
      <select-projects-dropdown
        class="gl-w-quarter"
        @projects-query-error="handleError"
        @select-all-projects="selectAllProjects"
        @select-project="selectProject"
      />
    </template>

    <gl-skeleton-loader
      v-if="isLoading"
      :width="430"
      :height="55"
      data-testid="test-coverage-loading-state"
    >
      <rect width="90" height="10" x="0" y="0" rx="4" />
      <rect width="80" height="10" x="95" y="0" rx="4" />
      <rect width="145" height="10" x="180" y="0" rx="4" />
      <rect width="100" height="10" x="330" y="0" rx="4" />

      <rect width="90" height="10" x="0" y="15" rx="4" />
      <rect width="80" height="10" x="95" y="15" rx="4" />
      <rect width="145" height="10" x="180" y="15" rx="4" />
      <rect width="100" height="10" x="330" y="15" rx="4" />

      <rect width="90" height="10" x="0" y="30" rx="4" />
      <rect width="80" height="10" x="95" y="30" rx="4" />
      <rect width="145" height="10" x="180" y="30" rx="4" />
      <rect width="100" height="10" x="330" y="30" rx="4" />

      <rect width="90" height="10" x="0" y="45" rx="4" />
      <rect width="80" height="10" x="95" y="45" rx="4" />
      <rect width="145" height="10" x="180" y="45" rx="4" />
      <rect width="100" height="10" x="330" y="45" rx="4" />
    </gl-skeleton-loader>

    <gl-table
      v-else-if="hasCoverageData"
      data-testid="test-coverage-data-table"
      thead-class="thead-white"
      :fields="$options.tableFields"
      :items="coverageData"
    >
      <template #head(project)="data">
        <div>{{ data.label }}</div>
      </template>
      <template #head(coverage)="data">
        <div>{{ data.label }}</div>
      </template>
      <template #head(numberOfCoverages)="data">
        <div>{{ data.label }}</div>
      </template>
      <template #head(lastUpdate)="data">
        <div>{{ data.label }}</div>
      </template>

      <template #cell(project)="{ item }">
        <div :data-testid="`${item.id}-name`">{{ item.name }}</div>
      </template>
      <template #cell(coverage)="{ item }">
        <div :data-testid="`${item.id}-average`">{{ item.codeCoverage.average }}%</div>
      </template>
      <template #cell(numberOfCoverages)="{ item }">
        <div :data-testid="`${item.id}-count`">{{ item.codeCoverage.count }}</div>
      </template>
      <template #cell(lastUpdate)="{ item }">
        <time-ago-tooltip
          :time="item.codeCoverage.lastUpdatedAt"
          :data-testid="`${item.id}-date`"
        />
      </template>
    </gl-table>

    <gl-empty-state
      v-else
      :svg-path="coverageTableEmptyStateSvgPath"
      :title="$options.text.emptyStateTitle"
      :description="$options.text.emptyStateDescription"
      data-testid="test-coverage-table-empty-state"
    />
  </gl-card>
</template>
