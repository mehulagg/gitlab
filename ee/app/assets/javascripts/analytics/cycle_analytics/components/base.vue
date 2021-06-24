<script>
import { GlEmptyState } from '@gitlab/ui';
import { mapActions, mapState, mapGetters } from 'vuex';
import PathNavigation from '~/cycle_analytics/components/path_navigation.vue';
import { OVERVIEW_STAGE_ID } from '~/cycle_analytics/constants';
import UrlSync from '~/vue_shared/components/url_sync.vue';
import DateRange from '../../shared/components/daterange.vue';
import ProjectsDropdownFilter from '../../shared/components/projects_dropdown_filter.vue';
import { DATE_RANGE_LIMIT } from '../../shared/constants';
import { toYmd } from '../../shared/utils';
import { PROJECTS_PER_PAGE } from '../constants';
import DurationChart from './duration_chart.vue';
import FilterBar from './filter_bar.vue';
import Metrics from './metrics.vue';
import StageTable from './stage_table.vue';
import TypeOfWorkCharts from './type_of_work_charts.vue';
import ValueStreamSelect from './value_stream_select.vue';

export default {
  name: 'CycleAnalytics',
  components: {
    DateRange,
    DurationChart,
    GlEmptyState,
    ProjectsDropdownFilter,
    TypeOfWorkCharts,
    StageTable,
    PathNavigation,
    FilterBar,
    ValueStreamSelect,
    UrlSync,
    Metrics,
  },
  props: {
    emptyStateSvgPath: {
      type: String,
      required: true,
    },
    noDataSvgPath: {
      type: String,
      required: true,
    },
    noAccessSvgPath: {
      type: String,
      required: true,
    },
  },
  computed: {
    ...mapState([
      'featureFlags',
      'isLoading',
      'isLoadingStage',
      'currentGroup',
      'selectedProjects',
      'selectedStage',
      'stages',
      'selectedStageEvents',
      'errorCode',
      'startDate',
      'endDate',
      'isLoadingValueStreams',
      'selectedStageError',
      'selectedValueStream',
      'pagination',
    ]),
    ...mapGetters([
      'hasNoAccessError',
      'currentGroupPath',
      'activeStages',
      'selectedProjectIds',
      'enableCustomOrdering',
      'cycleAnalyticsRequestParams',
      'pathNavigationData',
      'isOverviewStageSelected',
      'selectedStageCount',
    ]),
    shouldRenderEmptyState() {
      return !this.currentGroup && !this.isLoading;
    },
    shouldDisplayFilters() {
      return !this.errorCode && !this.hasNoAccessError;
    },
    shouldDisplayDurationChart() {
      return this.featureFlags.hasDurationChart;
    },
    selectedStageReady() {
      return !this.hasNoAccessError && this.selectedStage;
    },
    shouldDisplayCreateMultipleValueStreams() {
      return Boolean(!this.shouldRenderEmptyState && !this.isLoadingValueStreams);
    },
    hasDateRangeSet() {
      return this.startDate && this.endDate;
    },
    query() {
      const selectedProjectIds = this.selectedProjectIds?.length ? this.selectedProjectIds : null;
      const paginationUrlParams = !this.isOverviewStageSelected
        ? {
            sort: this.pagination?.sort || null,
            direction: this.pagination?.direction || null,
            page: this.pagination?.page || null,
          }
        : {
            sort: null,
            direction: null,
            page: null,
          };

      return {
        value_stream_id: this.selectedValueStream?.id || null,
        project_ids: selectedProjectIds,
        created_after: toYmd(this.startDate),
        created_before: toYmd(this.endDate),
        stage_id: (!this.isOverviewStageSelected && this.selectedStage?.id) || null, // the `overview` stage is always the default, so dont persist the id if its selected
        ...paginationUrlParams,
      };
    },
    stageCount() {
      return this.activeStages.length;
    },
    projectsQueryParams() {
      return {
        first: PROJECTS_PER_PAGE,
        includeSubgroups: true,
      };
    },
  },
  methods: {
    ...mapActions([
      'fetchCycleAnalyticsData',
      'fetchStageData',
      'setSelectedProjects',
      'setSelectedStage',
      'setDefaultSelectedStage',
      'setDateRange',
      'updateStageTablePagination',
    ]),
    onProjectsSelect(projects) {
      this.setSelectedProjects(projects);
      this.fetchCycleAnalyticsData();
    },
    onStageSelect(stage) {
      if (stage.slug === OVERVIEW_STAGE_ID) {
        this.setDefaultSelectedStage();
      } else {
        this.setSelectedStage(stage);
        this.updateStageTablePagination({ ...this.pagination, page: 1 });
      }
    },
    onHandleUpdatePagination(data) {
      this.updateStageTablePagination(data);
    },
  },
  multiProjectSelect: true,
  maxDateRange: DATE_RANGE_LIMIT,
};
</script>
<template>
  <div>
    <div
      class="gl-mb-3 gl-display-flex gl-flex-direction-column gl-sm-flex-direction-row gl-justify-content-space-between"
    >
      <h3>{{ __('Value Stream Analytics') }}</h3>
      <value-stream-select
        v-if="shouldDisplayCreateMultipleValueStreams"
        class="gl-align-self-start gl-sm-align-self-start gl-mt-0 gl-sm-mt-5"
      />
    </div>
    <gl-empty-state
      v-if="shouldRenderEmptyState"
      :title="__('Value Stream Analytics can help you determine your team’s velocity')"
      :description="
        __('Filter parameters are not valid. Make sure that the end date is after the start date.')
      "
      :svg-path="emptyStateSvgPath"
    />
    <div v-if="!shouldRenderEmptyState" class="gl-max-w-full">
      <path-navigation
        v-if="selectedStageReady"
        class="js-path-navigation gl-w-full gl-pb-2"
        :loading="isLoading"
        :stages="pathNavigationData"
        :selected-stage="selectedStage"
        @selected="onStageSelect"
      />
      <div class="gl-mt-3 gl-py-2 gl-px-3 bg-gray-light border-top border-bottom">
        <filter-bar
          v-if="shouldDisplayFilters"
          class="js-filter-bar filtered-search-box gl-display-flex gl-mb-2 gl-mr-3 gl-border-none"
          :group-path="currentGroupPath"
        />
        <div
          v-if="shouldDisplayFilters"
          class="gl-display-flex gl-flex-direction-column gl-lg-flex-direction-row gl-justify-content-space-between"
        >
          <projects-dropdown-filter
            :key="currentGroup.id"
            class="js-projects-dropdown-filter project-select gl-mb-2 gl-lg-mb-0"
            :group-id="currentGroup.id"
            :group-namespace="currentGroupPath"
            :query-params="projectsQueryParams"
            :multi-select="$options.multiProjectSelect"
            :default-projects="selectedProjects"
            @selected="onProjectsSelect"
          />
          <date-range
            :start-date="startDate"
            :end-date="endDate"
            :max-date-range="$options.maxDateRange"
            :include-selected-date="true"
            class="js-daterange-picker"
            @change="setDateRange"
          />
        </div>
      </div>
    </div>
    <div v-if="!shouldRenderEmptyState" class="cycle-analytics gl-mt-2">
      <gl-empty-state
        v-if="hasNoAccessError"
        class="js-empty-state"
        :title="__('You don’t have access to Value Stream Analytics for this group')"
        :svg-path="noAccessSvgPath"
        :description="
          __(
            'Only \'Reporter\' roles and above on tiers Premium and above can see Value Stream Analytics.',
          )
        "
      />
      <template v-else>
        <template v-if="isOverviewStageSelected">
          <metrics :group-path="currentGroupPath" :request-params="cycleAnalyticsRequestParams" />
          <duration-chart
            v-if="shouldDisplayDurationChart"
            class="gl-mt-3"
            :stages="activeStages"
          />
          <type-of-work-charts />
        </template>
        <stage-table
          v-else
          :is-loading="isLoading || isLoadingStage"
          :stage-events="selectedStageEvents"
          :selected-stage="selectedStage"
          :stage-count="selectedStageCount"
          :empty-state-message="selectedStageError"
          :no-data-svg-path="noDataSvgPath"
          :pagination="pagination"
          @handleUpdatePagination="onHandleUpdatePagination"
        />
        <url-sync v-if="selectedStageReady" :query="query" />
      </template>
    </div>
  </div>
</template>
