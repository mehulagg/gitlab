<script>
import { GlEmptyState } from '@gitlab/ui';
import { mapActions, mapState, mapGetters } from 'vuex';
import { featureAccessLevel } from '~/pages/projects/shared/permissions/constants';
import { PROJECTS_PER_PAGE } from '../constants';
import GroupsDropdownFilter from '../../shared/components/groups_dropdown_filter.vue';
import ProjectsDropdownFilter from '../../shared/components/projects_dropdown_filter.vue';
import { SIMILARITY_ORDER, LAST_ACTIVITY_AT, DATE_RANGE_LIMIT } from '../../shared/constants';
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
    GroupsDropdownFilter,
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
    hideGroupDropDown: {
      type: Boolean,
      required: true,
    },
  },
  computed: {
    ...mapState([
      'featureFlags',
      'isLoading',
      'isLoadingStage',
      'isEmptyStage',
      'selectedGroup',
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
      return !this.selectedGroup && !this.isLoading;
    },
    shouldDisplayFilters() {
      return this.selectedGroup && !this.errorCode;
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
    shouldDisplayFilterBar() {
      // TODO: After we remove instance VSA currentGroupPath will be always set
      // https://gitlab.com/gitlab-org/gitlab/-/issues/223735
      return this.currentGroupPath;
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
        group_id: !this.hideGroupDropDown ? this.currentGroupPath : null,
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
        per_page: PROJECTS_PER_PAGE,
        with_shared: false,
        order_by: this.featureFlags.hasAnalyticsSimilaritySearch
          ? SIMILARITY_ORDER
          : LAST_ACTIVITY_AT,
        include_subgroups: true,
      };
    },
  },

  methods: {
    ...mapActions([
      'fetchCycleAnalyticsData',
      'fetchStageData',
      'setSelectedGroup',
      'setSelectedProjects',
      'setSelectedStage',
      'setDateRange',
      'updateStage',
      'removeStage',
      'updateStage',
      'reorderStage',
    ]),
    ...mapActions('customStages', [
      'hideForm',
      'showCreateForm',
      'showEditForm',
      'createStage',
      'clearFormErrors',
    ]),
    onGroupSelect(group) {
      this.setSelectedGroup(group);
      this.fetchCycleAnalyticsData();
    },
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
  groupsQueryParams: {
    min_access_level: featureAccessLevel.EVERYONE,
  },
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
    <div class="gl-max-w-full">
      <div class="gl-mt-3 gl-py-2 gl-px-3 bg-gray-light border-top border-bottom">
        <div v-if="shouldDisplayPathNavigation" class="gl-w-full gl-pb-2">
          <path-navigation
            class="js-path-navigation"
            :loading="isLoading"
            :stages="pathNavigationData"
            :selected-stage="selectedStage"
            @selected="onStageSelect"
          />
        </div>
        <div
          class="gl-display-flex gl-flex-direction-column gl-lg-flex-direction-row gl-justify-content-space-between"
        >
          <div class="dropdown-container d-flex flex-column flex-lg-row">
            <groups-dropdown-filter
              v-if="!hideGroupDropDown"
              class="js-groups-dropdown-filter"
              :class="{ 'mr-lg-3': shouldDisplayFilters }"
              :query-params="$options.groupsQueryParams"
              :default-group="selectedGroup"
              @selected="onGroupSelect"
            />
            <projects-dropdown-filter
              v-if="shouldDisplayFilters"
              :key="selectedGroup.id"
              class="js-projects-dropdown-filter project-select"
              :group-id="selectedGroup.id"
              :query-params="projectsQueryParams"
              :multi-select="$options.multiProjectSelect"
              :default-projects="selectedProjects"
              @selected="onProjectsSelect"
            />
          </div>
          <div v-if="shouldDisplayFilters" class="gl-justify-content-end gl-white-space-nowrap">
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
        <filter-bar
          v-if="shouldDisplayFilterBar"
          class="js-filter-bar filtered-search-box gl-display-flex gl-mt-3 gl-mr-3 gl-border-none"
          :group-path="currentGroupPath"
        />
      </div>
    </div>
    <gl-empty-state
      v-if="shouldRenderEmptyState"
      :title="__('Value Stream Analytics can help you determine your team’s velocity')"
      :description="
        __(
          'Start by choosing a group to see how your team is spending time. You can then drill down to the project level.',
        )
      "
      :svg-path="emptyStateSvgPath"
    />
    <div v-else class="cycle-analytics mt-0">
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
