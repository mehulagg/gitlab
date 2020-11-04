<script>
import Vue from 'vue';
import { GlCard, GlEmptyState, GlSkeletonLoader, GlTable } from '@gitlab/ui';
import { __, s__ } from '~/locale';
import { SUPPORTED_FORMATS, getFormatter } from '~/lib/utils/unit_format';
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
  apollo: {
    projects: {
      query: getProjectsTestCoverage,
      debounce: 500,
      variables() {
        return {
          projectIds: this.selectedProjectIds,
        };
      },
      result({ data }) {
        // Keep data from all queries so that we don't
        // fetch the same data more than once
        this.allCoverageData = [
          ...this.allCoverageData,
          ...data.projects.nodes.map(project => ({
            ...project,
            // if a project has no code coverage, set to default values
            codeCoverageSummary:
              project.codeCoverageSummary || this.$options.noCoverageDefaultSummary,
          })),
        ];
      },
      error() {
        this.handleError();
      },
      watchLoading(isLoading) {
        this.isLoading = isLoading;
      },
      skip() {
        return this.skipQuery;
      },
    },
  },
  data() {
    return {
      allProjectsSelected: false,
      allCoverageData: [],
      hasError: false,
      isLoading: false,
      projectIds: {},
    };
  },
  computed: {
    hasCoverageData() {
      return Boolean(this.selectedCoverageData.length);
    },
    skipQuery() {
      // Skip if we haven't selected any projects yet
      return !this.selectedProjectIds.length;
    },
    selectedProjectIds() {
      // Get the IDs of the projects that we haven't requested yet
      return Object.keys(this.projectIds).filter(
        id => !this.allCoverageData.some(project => project.id === id),
      );
    },
    selectedCoverageData() {
      return this.allCoverageData.filter(({ id }) => this.projectIds[id]);
    },
  },
  methods: {
    handleError() {
      this.hasError = true;
    },
    selectAllProjects(allProjects) {
      this.projectIds = Object.fromEntries(allProjects.map(({ id }) => [id, true]));
      this.allProjectsSelected = true;
    },
    toggleProject({ id }) {
      if (this.allProjectsSelected) {
        // Reset all project selections to false
        this.allProjectsSelected = false;
        this.projectIds = Object.fromEntries(
          Object.entries(this.projectIds).map(([key]) => [key, false]),
        );
      }

      if (Object.prototype.hasOwnProperty.call(this.projectIds, id)) {
        Vue.set(this.projectIds, id, !this.projectIds[id]);
        return;
      }

      Vue.set(this.projectIds, id, true);
    },
  },
  tableFields: [
    {
      key: 'project',
      label: __('Project'),
    },
    {
      key: 'averageCoverage',
      label: s__('RepositoriesAnalytics|Coverage'),
    },
    {
      key: 'coverageCount',
      label: s__('RepositoriesAnalytics|Coverage Jobs'),
    },
    {
      key: 'lastUpdatedAt',
      label: s__('RepositoriesAnalytics|Last Update'),
    },
  ],
  text: {
    header: s__('RepositoriesAnalytics|Latest test coverage results'),
    emptyStateTitle: s__('RepositoriesAnalytics|Please select projects to display.'),
    emptyStateDescription: s__(
      'RepositoriesAnalytics|Please select a project or multiple projects to display their most recent test coverage data.',
    ),
  },
  noCoverageDefaultSummary: {
    averageCoverage: 0,
    coverageCount: 0,
    lastUpdatedAt: '', // empty string will default to "just now" in table
  },
  LOADING_STATE: {
    rows: 4,
    height: 10,
    rx: 4,
    groupXs: [0, 95, 180, 330],
    widths: [90, 80, 145, 100],
    totalWidth: 430,
    totalHeight: 15,
  },
  averageCoverageFormatter: getFormatter(SUPPORTED_FORMATS.percentHundred),
};
</script>
<template>
  <gl-card>
    <template #header>
      <div class="gl-display-flex gl-justify-content-space-between">
        <h5>{{ $options.text.header }}</h5>
        <select-projects-dropdown
          class="gl-w-quarter"
          @projects-query-error="handleError"
          @select-all-projects="selectAllProjects"
          @select-project="toggleProject"
        />
      </div>
    </template>

    <template v-if="isLoading">
      <gl-skeleton-loader
        v-for="index in $options.LOADING_STATE.rows"
        :key="index"
        :width="$options.LOADING_STATE.totalWidth"
        :height="$options.LOADING_STATE.totalHeight"
        data-testid="test-coverage-loading-state"
      >
        <rect
          v-for="(x, xIndex) in $options.LOADING_STATE.groupXs"
          :key="`x-skeleton-${x}`"
          :width="$options.LOADING_STATE.widths[xIndex]"
          :height="$options.LOADING_STATE.height"
          :x="x"
          :y="0"
          :rx="$options.LOADING_STATE.rx"
        />
      </gl-skeleton-loader>
    </template>

    <gl-table
      v-else-if="hasCoverageData"
      data-testid="test-coverage-data-table"
      thead-class="thead-white"
      :fields="$options.tableFields"
      :items="selectedCoverageData"
    >
      <template #head(project)="data">
        <div>{{ data.label }}</div>
      </template>
      <template #head(averageCoverage)="data">
        <div>{{ data.label }}</div>
      </template>
      <template #head(coverageCount)="data">
        <div>{{ data.label }}</div>
      </template>
      <template #head(lastUpdatedAt)="data">
        <div>{{ data.label }}</div>
      </template>

      <template #cell(project)="{ item }">
        <div :data-testid="`${item.id}-name`">{{ item.name }}</div>
      </template>
      <template #cell(averageCoverage)="{ item }">
        <div :data-testid="`${item.id}-average`">
          {{ $options.averageCoverageFormatter(item.codeCoverageSummary.averageCoverage, 2) }}
        </div>
      </template>
      <template #cell(coverageCount)="{ item }">
        <div :data-testid="`${item.id}-count`">{{ item.codeCoverageSummary.coverageCount }}</div>
      </template>
      <template #cell(lastUpdatedAt)="{ item }">
        <time-ago-tooltip
          :time="item.codeCoverageSummary.lastUpdatedAt"
          :data-testid="`${item.id}-date`"
        />
      </template>
    </gl-table>

    <gl-empty-state
      v-else
      class="gl-mt-3"
      :title="$options.text.emptyStateTitle"
      :description="$options.text.emptyStateDescription"
      data-testid="test-coverage-table-empty-state"
    />
  </gl-card>
</template>
