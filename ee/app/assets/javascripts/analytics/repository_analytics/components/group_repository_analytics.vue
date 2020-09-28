<script>
import {
  GlAlert,
  GlButton,
  GlDropdown,
  GlDropdownSectionHeader,
  GlDropdownItem,
  GlIntersectionObserver,
  GlLoadingIcon,
  GlModal,
  GlModalDirective,
  GlSearchBoxByType,
} from '@gitlab/ui';
import produce from 'immer';
import { __, s__ } from '~/locale';
import { pikadayToString } from '~/lib/utils/datetime_utility';
import { getIdFromGraphQLId } from '~/graphql_shared/utils';
import getGroupProjects from '../graphql/queries/get_group_projects.query.graphql';

export default {
  name: 'GroupRepositoryAnalytics',
  components: {
    GlAlert,
    GlButton,
    GlDropdown,
    GlDropdownSectionHeader,
    GlDropdownItem,
    GlIntersectionObserver,
    GlLoadingIcon,
    GlModal,
    GlSearchBoxByType,
  },
  directives: {
    GlModalDirective,
  },
  inject: {
    groupAnalyticsCoverageReportsPath: {
      type: String,
      default: '',
    },
    groupFullPath: {
      type: String,
      default: '',
    },
  },
  apollo: {
    groupProjects: {
      query: getGroupProjects,
      variables() {
        return {
          groupFullPath: this.groupFullPath,
        };
      },
      update(data) {
        return data.group.projects.nodes.map(project => ({
          ...project,
          id: getIdFromGraphQLId(project.id),
          isSelected: false,
        }));
      },
      result({ data }) {
        this.projectsPageInfo = data?.group?.projects?.pageInfo || {};
      },
      error() {
        this.hasError = true;
      },
    },
  },
  data() {
    return {
      groupProjects: [],
      hasError: false,
      projectsPageInfo: {},
      projectSearchTerm: '',
      selectAllProjects: true,
      selectedDateRange: this.$options.dateRangeOptions[2],
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
      if (!this.selectAllProjects) {
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
      return !this.selectAllProjects && !this.groupProjects.some(project => project.isSelected);
    },
    filteredProjects() {
      return this.groupProjects.filter(project =>
        project.name.toLowerCase().includes(this.projectSearchTerm.toLowerCase()),
      );
    },
    selectedProjectIds() {
      return this.groupProjects.filter(project => project.isSelected).map(project => project.id);
    },
  },
  methods: {
    clickDropdownProject(id) {
      const index = this.groupProjects.map(project => project.id).indexOf(id);
      this.groupProjects[index].isSelected = !this.groupProjects[index].isSelected;
      this.selectAllProjects = false;
    },
    clickSelectAllProjects() {
      this.selectAllProjects = true;
      this.groupProjects = this.groupProjects.map(project => ({
        ...project,
        isSelected: false,
      }));
    },
    clickDateRange(dateRange) {
      this.selectedDateRange = dateRange;
    },
    dismissError() {
      this.hasError = false;
    },
    loadMoreProjects() {
      this.$apollo.queries.groupProjects
        .fetchMore({
          variables: {
            groupFullPath: this.groupFullPath,
            after: this.projectsPageInfo.endCursor,
          },
          updateQuery(previousResult, { fetchMoreResult }) {
            const results = produce(fetchMoreResult, draftData => {
              // eslint-disable-next-line no-param-reassign
              draftData.group.projects.nodes = [
                ...previousResult.group.projects.nodes,
                ...draftData.group.projects.nodes,
              ];
            });
            return results;
          },
        })
        .catch(() => {
          this.hasError = true;
        });
    },
  },
  text: {
    codeCoverageHeader: s__('RepositoriesAnalytics|Test Code Coverage'),
    downloadCSVButton: s__('RepositoriesAnalytics|Download historic test coverage data (.csv)'),
    dateRangeHeader: __('Date range'),
    downloadCSVModalButton: s__('RepositoriesAnalytics|Download test coverage data (.csv)'),
    downloadCSVModalTitle: s__('RepositoriesAnalytics|Download Historic Test Coverage Data'),
    downloadCSVModalDescription: s__(
      'RepositoriesAnalytics|Historic Test Coverage Data is available in raw format (.csv) for further analysis.',
    ),
    projectDropdown: __('Select projects'),
    projectDropdownHeader: __('Projects'),
    projectDropdownAllProjects: __('All projects'),
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
  <div class="gl-display-flex gl-justify-content-space-between gl-align-items-center gl-flex-wrap">
    <h4 class="sub-header">{{ $options.text.codeCoverageHeader }}</h4>
    <gl-button
      v-gl-modal-directive="'download-csv-modal'"
      data-testid="group-code-coverage-modal-button"
      >{{ $options.text.downloadCSVButton }}</gl-button
    >

    <gl-modal
      modal-id="download-csv-modal"
      :title="$options.text.downloadCSVModalTitle"
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
        <gl-dropdown
          :text="$options.text.projectDropdown"
          class="gl-w-half"
          data-testid="group-code-coverage-project-dropdown"
        >
          <gl-dropdown-section-header>
            {{ $options.text.projectDropdownHeader }}
          </gl-dropdown-section-header>
          <gl-search-box-by-type v-model.trim="projectSearchTerm" class="gl-my-2 gl-mx-3" />
          <gl-dropdown-item
            :is-check-item="true"
            :is-checked="selectAllProjects"
            data-testid="group-code-coverage-download-select-all-projects"
            @click.native.capture.stop="clickSelectAllProjects()"
            >{{ $options.text.projectDropdownAllProjects }}</gl-dropdown-item
          >
          <gl-dropdown-item
            v-for="project in filteredProjects"
            :key="project.id"
            :is-check-item="true"
            :is-checked="project.isSelected"
            :data-testid="`group-code-coverage-download-select-project-${project.id}`"
            @click.native.capture.stop="clickDropdownProject(project.id)"
            >{{ project.name }}</gl-dropdown-item
          >
          <gl-intersection-observer v-if="projectsPageInfo.hasNextPage" @appear="loadMoreProjects">
            <gl-loading-icon v-if="$apollo.queries.groupProjects.loading" size="md" />
          </gl-intersection-observer>
        </gl-dropdown>

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
  </div>
</template>
