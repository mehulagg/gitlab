<script>
import { GlEmptyState } from '@gitlab/ui';
import { mapActions, mapState, mapGetters } from 'vuex';
import { PROJECTS_PER_PAGE } from '../constants';
import ProjectsDropdownFilter from '../../shared/components/projects_dropdown_filter.vue';
import { DATE_RANGE_LIMIT } from '../../shared/constants';
import DateRange from '../../shared/components/daterange.vue';
import StageTable from './stage_table.vue';
import DurationChart from './duration_chart.vue';
import TypeOfWorkCharts from './type_of_work_charts.vue';
import UrlSync from '~/vue_shared/components/url_sync.vue';
import { toYmd } from '../../shared/utils';
import StageTableNav from './stage_table_nav.vue';
import CustomStageForm from './custom_stage_form.vue';
import PathNavigation from './path_navigation.vue';
import FilterBar from './filter_bar.vue';
import ValueStreamSelect from './value_stream_select.vue';
import Metrics from './metrics.vue';

export default {
  name: 'CycleAnalytics',
  components: {
    DateRange,
    DurationChart,
    GlEmptyState,
    ProjectsDropdownFilter,
    StageTable,
    TypeOfWorkCharts,
    CustomStageForm,
    StageTableNav,
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
      'isEmptyStage',
      'currentGroup',
      'selectedProjects',
      'selectedStage',
      'stages',
      'currentStageEvents',
      'errorCode',
      'startDate',
      'endDate',
      'medians',
      'isLoadingValueStreams',
      'selectedStageError',
      'selectedValueStream',
    ]),
    // NOTE: formEvents are fetched in the same request as the list of stages (fetchGroupStagesAndEvents)
    // so i think its ok to bind formEvents here even though its only used as a prop to the custom-stage-form
    ...mapState('customStages', ['isCreatingCustomStage', 'formEvents']),
    ...mapGetters([
      'hasNoAccessError',
      'currentGroupPath',
      'activeStages',
      'selectedProjectIds',
      'enableCustomOrdering',
      'cycleAnalyticsRequestParams',
      'pathNavigationData',
    ]),
    ...mapGetters('customStages', ['customStageFormActive']),
    shouldRenderEmptyState() {
      return !this.currentGroup && !this.isLoading;
    },
    shouldDisplayFilters() {
      return !this.errorCode;
    },
    shouldDisplayDurationChart() {
      return this.featureFlags.hasDurationChart && !this.hasNoAccessError;
    },
    shouldDisplayTypeOfWorkCharts() {
      return !this.hasNoAccessError;
    },
    shouldDisplayPathNavigation() {
      return this.featureFlags.hasPathNavigation && !this.hasNoAccessError && this.selectedStage;
    },
    shouldDisplayCreateMultipleValueStreams() {
      return Boolean(
        this.featureFlags.hasCreateMultipleValueStreams && !this.isLoadingValueStreams,
      );
    },
    hasDateRangeSet() {
      return this.startDate && this.endDate;
    },
    query() {
      const selectedProjectIds = this.selectedProjectIds?.length ? this.selectedProjectIds : null;

      return {
        value_stream_id: this.selectedValueStream?.id || null,
        project_ids: selectedProjectIds,
        created_after: toYmd(this.startDate),
        created_before: toYmd(this.endDate),
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
      'setDateRange',
      'removeStage',
      'updateStage',
      'reorderStage',
    ]),
    ...mapActions('customStages', ['hideForm', 'showCreateForm', 'showEditForm', 'createStage']),
    onProjectsSelect(projects) {
      this.setSelectedProjects(projects);
      this.fetchCycleAnalyticsData();
    },
    onStageSelect(stage) {
      this.hideForm();
      this.setSelectedStage(stage);
      this.fetchStageData(this.selectedStage.slug);
    },
    onShowAddStageForm() {
      this.showCreateForm();
    },
    onShowEditStageForm(initData = {}) {
      this.setSelectedStage(initData);
      this.showEditForm(initData);
    },
    onCreateCustomStage(data) {
      this.createStage(data);
    },
    onUpdateCustomStage(data) {
      this.updateStage(data);
    },
    onRemoveStage(id) {
      this.removeStage(id);
    },
    onStageReorder(data) {
      this.reorderStage(data);
    },
  },
  multiProjectSelect: true,
  dateOptions: [7, 30, 90],
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
        :has-extended-form-fields="featureFlags.hasExtendedFormFields"
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
      <div class="gl-mt-3 gl-py-2 gl-px-3 bg-gray-light border-top border-bottom">
        <div v-if="shouldDisplayPathNavigation" class="gl-w-full gl-pb-2">
          <path-navigation
            :key="`path_navigation_key_${pathNavigationData.length}`"
            class="js-path-navigation"
            :loading="isLoading"
            :stages="pathNavigationData"
            :selected-stage="selectedStage"
            @selected="onStageSelect"
          />
        </div>
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
        <filter-bar
          v-if="shouldDisplayFilters"
          class="js-filter-bar filtered-search-box gl-display-flex gl-mt-3 gl-mr-3 gl-border-none"
          :group-path="currentGroupPath"
        />
      </div>
    </div>
    <div v-if="!shouldRenderEmptyState" class="cycle-analytics gl-mt-0">
      <gl-empty-state
        v-if="hasNoAccessError"
        class="js-empty-state"
        :title="__('You don’t have access to Value Stream Analytics for this group')"
        :svg-path="noAccessSvgPath"
        :description="
          __(
            'Only \'Reporter\' roles and above on tiers Premium / Silver and above can see Value Stream Analytics.',
          )
        "
      />
      <div v-else>
        <metrics :group-path="currentGroupPath" :request-params="cycleAnalyticsRequestParams" />
        <stage-table
          :key="stageCount"
          class="js-stage-table"
          :current-stage="selectedStage"
          :is-loading="isLoading"
          :is-loading-stage="isLoadingStage"
          :is-empty-stage="isEmptyStage"
          :custom-stage-form-active="customStageFormActive"
          :current-stage-events="currentStageEvents"
          :no-data-svg-path="noDataSvgPath"
          :empty-state-message="selectedStageError"
        >
          <template #nav>
            <stage-table-nav
              :current-stage="selectedStage"
              :stages="activeStages"
              :medians="medians"
              :is-creating-custom-stage="isCreatingCustomStage"
              :custom-ordering="enableCustomOrdering"
              @reorderStage="onStageReorder"
              @selectStage="onStageSelect"
              @editStage="onShowEditStageForm"
              @showAddStageForm="onShowAddStageForm"
              @hideStage="onUpdateCustomStage"
              @removeStage="onRemoveStage"
            />
          </template>
          <template v-if="customStageFormActive" #content>
            <custom-stage-form
              :events="formEvents"
              @createStage="onCreateCustomStage"
              @updateStage="onUpdateCustomStage"
              @clearErrors="$emit('clear-form-errors')"
            />
          </template>
        </stage-table>
        <url-sync :query="query" />
      </div>
      <duration-chart v-if="shouldDisplayDurationChart" class="gl-mt-3" :stages="activeStages" />
      <type-of-work-charts v-if="shouldDisplayTypeOfWorkCharts" />
    </div>
  </div>
</template>
