<script>
import {
  GlAlert,
  GlButton,
  GlCard,
  GlDropdown,
  GlDropdownSectionHeader,
  GlDropdownItem,
  GlModal,
  GlModalDirective,
} from '@gitlab/ui';
import { __, s__ } from '~/locale';
import { pikadayToString } from '~/lib/utils/datetime_utility';
import SelectProjectsDropdown from './select_projects_dropdown.vue';

export default {
  name: 'DownloadTestCoverage',
  components: {
    GlAlert,
    GlButton,
    GlCard,
    GlDropdown,
    GlDropdownSectionHeader,
    GlDropdownItem,
    GlModal,
    SelectProjectsDropdown,
  },
  directives: {
    GlModalDirective,
  },
  inject: {
    groupAnalyticsCoverageReportsPath: {
      default: '',
    },
  },
  data() {
    return {
      hasError: false,
      allProjectsSelected: false,
      selectedDateRange: this.$options.dateRangeOptions[2],
      selectedProjectIds: [],
    };
  },
  computed: {
    cancelModalButton() {
      return {
        text: __('Cancel'),
      };
    },
    csvReportPath() {
      const today = new Date();
      const endDate = pikadayToString(today);
      today.setDate(today.getDate() - this.selectedDateRange.value);
      const startDate = pikadayToString(today);

      const queryParams = new URLSearchParams({
        start_date: startDate,
        end_date: endDate,
      });

      // not including a project_ids param is the same as selecting all the projects
      if (!this.allProjectsSelected) {
        this.selectedProjectIds.forEach(id => queryParams.append('project_ids[]', id));
      }

      return `${this.groupAnalyticsCoverageReportsPath}&${queryParams.toString()}`;
    },
    downloadCSVModalButton() {
      return {
        text: this.$options.text.downloadCSVModalButton,
        attributes: [
          { variant: 'info' },
          { href: this.csvReportPath },
          { rel: 'nofollow' },
          { download: '' },
          { disabled: this.isDownloadButtonDisabled },
          { 'data-testid': 'group-code-coverage-download-button' },
        ],
      };
    },
    isDownloadButtonDisabled() {
      return !this.allProjectsSelected && !this.selectedProjectIds.length;
    },
  },
  methods: {
    clickDateRange(dateRange) {
      this.selectedDateRange = dateRange;
    },
    clickSelectAllProjects() {
      this.$refs.projectsDropdown.clickSelectAllProjects();
    },
    dismissError() {
      this.hasError = false;
    },
    projectsQueryError() {
      this.hasError = true;
    },
    selectAllProjects() {
      this.allProjectsSelected = true;
      this.selectedProjectIds = [];
    },
    selectProject({ parsedId }) {
      this.allProjectsSelected = false;
      const index = this.selectedProjectIds.indexOf(parsedId);
      if (index < 0) {
        this.selectedProjectIds.push(parsedId);
        return;
      }
      this.selectedProjectIds.splice(index, 1);
    },
  },
  text: {
    downloadTestCoverageHeader: s__('RepositoriesAnalytics|Download historic test coverage data'),
    downloadCSVButton: s__('RepositoriesAnalytics|Download historic test coverage data (.csv)'),
    dateRangeHeader: __('Date range'),
    downloadCSVModalButton: s__('RepositoriesAnalytics|Download test coverage data (.csv)'),
    downloadCSVModalDescription: s__(
      'RepositoriesAnalytics|Historic Test Coverage Data is available in raw format (.csv) for further analysis.',
    ),
    projectDropdownHeader: __('Projects'),
    projectSelectAll: __('Select all'),
    queryErrorMessage: s__('RepositoriesAnalytics|There was an error fetching the projects.'),
  },
  dateRangeOptions: [
    { value: 7, text: __('Last week') },
    { value: 14, text: __('Last 2 weeks') },
    { value: 30, text: __('Last 30 days') },
    { value: 60, text: __('Last 60 days') },
    { value: 90, text: __('Last 90 days') },
  ],
};
</script>

<template>
  <gl-card>
    <template #header>
      <h5>{{ $options.text.downloadTestCoverageHeader }}</h5>
    </template>

    <gl-button
      v-gl-modal-directive="'download-csv-modal'"
      category="primary"
      variant="info"
      data-testid="group-code-coverage-modal-button"
      >{{ $options.text.downloadCSVButton }}</gl-button
    >

    <gl-modal
      modal-id="download-csv-modal"
      :title="$options.text.downloadTestCoverageHeader"
      no-fade
      :action-primary="downloadCSVModalButton"
      :action-cancel="cancelModalButton"
    >
      <gl-alert
        v-if="hasError"
        variant="danger"
        data-testid="group-code-coverage-projects-error"
        @dismiss="dismissError"
        >{{ $options.text.queryErrorMessage }}</gl-alert
      >
      <div>{{ $options.text.downloadCSVModalDescription }}</div>
      <div class="gl-my-4">
        <label class="gl-display-block col-form-label-sm col-form-label">
          {{ $options.text.projectDropdownHeader }}
        </label>
        <select-projects-dropdown
          ref="projectsDropdown"
          class="gl-w-half"
          @projects-query-error="projectsQueryError"
          @select-all-projects="selectAllProjects"
          @select-project="selectProject"
        />

        <gl-button
          class="gl-ml-2"
          variant="link"
          data-testid="group-code-coverage-select-all-projects-button"
          @click="clickSelectAllProjects()"
          >{{ $options.text.projectSelectAll }}</gl-button
        >
      </div>

      <div class="gl-my-4">
        <label class="gl-display-block col-form-label-sm col-form-label">
          {{ $options.text.dateRangeHeader }}
        </label>
        <gl-dropdown :text="selectedDateRange.text" class="gl-w-half">
          <gl-dropdown-section-header>
            {{ $options.text.dateRangeHeader }}
          </gl-dropdown-section-header>
          <gl-dropdown-item
            v-for="dateRange in $options.dateRangeOptions"
            :key="dateRange.value"
            :data-testid="`group-code-coverage-download-select-date-${dateRange.value}`"
            @click="clickDateRange(dateRange)"
            >{{ dateRange.text }}</gl-dropdown-item
          >
        </gl-dropdown>
      </div>
    </gl-modal>
  </gl-card>
</template>
