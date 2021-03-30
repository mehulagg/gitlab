<script>
import { GlIcon, GlEmptyState, GlLoadingIcon, GlSprintf } from '@gitlab/ui';
import Cookies from 'js-cookie';
import { mapActions, mapState, mapGetters } from 'vuex';
import FilterBar from 'ee/analytics/cycle_analytics/components/filter_bar.vue';
import ValueStreamFilters from 'ee/analytics/cycle_analytics/components/value_stream_filters.vue';
import PathNavigation from '~/cycle_analytics/components/path_navigation.vue';
import { __ } from '~/locale';
import banner from './banner.vue';
import StageTable from './stage_table.vue';

const OVERVIEW_DIALOG_COOKIE = 'cycle_analytics_help_dismissed';

export default {
  name: 'CycleAnalytics',
  components: {
    GlIcon,
    GlEmptyState,
    GlLoadingIcon,
    GlSprintf,
    banner,
    PathNavigation,
    FilterBar,
    StageTable,
    ValueStreamFilters,
  },
  props: {
    noDataSvgPath: {
      type: String,
      required: true,
    },
    noAccessSvgPath: {
      type: String,
      required: true,
    },
  },
  data() {
    return {
      isOverviewDialogDismissed: Cookies.get(OVERVIEW_DIALOG_COOKIE),
    };
  },
  computed: {
    ...mapState([
      'isLoading',
      'isLoadingStage',
      'isEmptyStage',
      'selectedStage',
      'selectedStageEvents',
      'selectedStageError',
      'currentGroup',
      'stages',
      'summary',
      'permissions',
      'endpoints',
      'pagination',
      'createdBefore',
      'createdAfter',
    ]),
    ...mapGetters(['pathNavigationData']),
    displayStageEvents() {
      const { selectedStageEvents, isLoadingStage, isEmptyStage } = this;
      return selectedStageEvents.length && !isLoadingStage && !isEmptyStage;
    },
    displayNotEnoughData() {
      return this.selectedStageReady && this.isEmptyStage;
    },
    displayNoAccess() {
      return this.selectedStageReady && !this.isUserAllowed(this.selectedStage.id);
    },
    selectedStageReady() {
      return !this.isLoadingStage && this.selectedStage;
    },
    emptyStageTitle() {
      return this.selectedStageError
        ? this.selectedStageError
        : __("We don't have enough data to show this stage.");
    },
    emptyStageText() {
      return !this.selectedStageError ? this.selectedStage.emptyStageText : '';
    },
    selectedStageCount() {
      // TODO: stub
    },
    selectedStageError() {
      // TODO: stub
    },
  },
  methods: {
    ...mapActions([
      'fetchCycleAnalyticsData',
      'fetchStageData',
      'setSelectedStage',
      'setDateRange',
    ]),
    onSelectStage(stage) {
      this.setSelectedStage(stage);
    },
    onSetDateRange({ startDate, endDate }) {
      console.log('setDateRange', startDate, endDate);
      this.setDateRange({
        createdAfter: new Date(startDate),
        createdBefore: new Date(endDate),
      });
    },
    dismissOverviewDialog() {
      this.isOverviewDialogDismissed = true;
      Cookies.set(OVERVIEW_DIALOG_COOKIE, '1', { expires: 365 });
    },
    isUserAllowed(id) {
      const { permissions } = this;
      return Boolean(permissions?.[id]);
    },
    onHandleUpdatePagination(data) {
      console.log('onHandleUpdatePagination::data', data);
      // TODO: implement vuex actions
      // this.updateStageTablePagination(data);
    },
  },
  i18n: {
    pageTitle: __('Value Stream Analytics'),
    recentActivity: __('Recent Project Activity'),
  },
};
</script>
<template>
  <div class="cycle-analytics">
    <h3>{{ $options.i18n.pageTitle }}</h3>
    <path-navigation
      v-if="selectedStageReady"
      class="js-path-navigation gl-w-full gl-pb-2"
      :loading="isLoading"
      :stages="pathNavigationData"
      :selected-stage="selectedStage"
      :with-stage-counts="false"
      @selected="onSelectStage"
    />
    <gl-loading-icon v-if="isLoading" size="lg" />
    <div v-else class="wrapper">
      <!--
        We wont have access to the stage counts until we move to a default value stream
        For now we can use the `withStageCounts` flag to ensure we don't display empty stage counts
        Related issue: https://gitlab.com/gitlab-org/gitlab/-/issues/326705
      -->
      <!-- NOTE: start / end filter work, but for the search we will need a vuex defined -->
      <value-stream-filters
        :has-project-filter="false"
        :group-id="currentGroup.id"
        :group-path="currentGroup.path"
        :start-date="createdAfter"
        :end-date="createdBefore"
        @onSetDateRange="onSetDateRange"
      />
      <div class="card" data-testid="vsa-stage-overview-metrics">
        <div class="card-header">{{ $options.i18n.recentActivity }}</div>
        <div class="d-flex justify-content-between">
          <div v-for="item in summary" :key="item.title" class="gl-flex-grow-1 gl-text-center">
            <h3 class="header">{{ item.value }}</h3>
            <p class="text">{{ item.title }}</p>
          </div>
        </div>
      </div>
      <stage-table
        :is-loading="isLoading || isLoadingStage"
        :stage-events="selectedStageEvents"
        :selected-stage="selectedStage"
        :stage-count="selectedStageCount"
        :empty-state-message="selectedStageError"
        :no-data-svg-path="noDataSvgPath"
        :pagination="pagination"
        @handleUpdatePagination="onHandleUpdatePagination"
      />
    </div>
  </div>
</template>
