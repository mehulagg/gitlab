import { GlEmptyState } from '@gitlab/ui';
import { createLocalVue, shallowMount, mount } from '@vue/test-utils';
import axios from 'axios';
import MockAdapter from 'axios-mock-adapter';
import Vuex from 'vuex';
import Component from 'ee/analytics/cycle_analytics/components/base.vue';
import DurationChart from 'ee/analytics/cycle_analytics/components/duration_chart.vue';
import FilterBar from 'ee/analytics/cycle_analytics/components/filter_bar.vue';
import Metrics from 'ee/analytics/cycle_analytics/components/metrics.vue';
import StageTable from 'ee/analytics/cycle_analytics/components/stage_table.vue';
import TypeOfWorkCharts from 'ee/analytics/cycle_analytics/components/type_of_work_charts.vue';
import ValueStreamSelect from 'ee/analytics/cycle_analytics/components/value_stream_select.vue';
import createStore from 'ee/analytics/cycle_analytics/store';
import Daterange from 'ee/analytics/shared/components/daterange.vue';
import ProjectsDropdownFilter from 'ee/analytics/shared/components/projects_dropdown_filter.vue';
import { toYmd } from 'ee/analytics/shared/utils';
import waitForPromises from 'helpers/wait_for_promises';
import PathNavigation from '~/cycle_analytics/components/path_navigation.vue';
import { OVERVIEW_STAGE_ID } from '~/cycle_analytics/constants';
import createFlash from '~/flash';
import { getIdFromGraphQLId } from '~/graphql_shared/utils';
import * as commonUtils from '~/lib/utils/common_utils';
import { convertObjectPropsToCamelCase } from '~/lib/utils/common_utils';
import httpStatusCodes from '~/lib/utils/http_status';
import * as urlUtils from '~/lib/utils/url_utility';
import UrlSync from '~/vue_shared/components/url_sync.vue';
import * as mockData from '../mock_data';

const noDataSvgPath = 'path/to/no/data';
const noAccessSvgPath = 'path/to/no/access';
const currentGroup = convertObjectPropsToCamelCase(mockData.group);
const emptyStateSvgPath = 'path/to/empty/state';
const stage = null;

const localVue = createLocalVue();
localVue.use(Vuex);
jest.mock('~/flash');

const defaultStubs = {
  'stage-event-list': true,
  'stage-nav-item': true,
  'tasks-by-type-chart': true,
  'labels-selector': true,
  DurationChart: true,
  ValueStreamSelect: true,
  Metrics: true,
  UrlSync,
};

const defaultFeatureFlags = {
  hasDurationChart: true,
};

const [selectedValueStream] = mockData.valueStreams;

const initialCycleAnalyticsState = {
  selectedValueStream,
  createdAfter: mockData.startDate,
  createdBefore: mockData.endDate,
  group: currentGroup,
  stage,
};

const mocks = {
  $toast: {
    show: jest.fn(),
  },
  $apollo: {
    query: jest.fn().mockResolvedValue({
      data: { group: { projects: { nodes: [] } } },
    }),
  },
};

function mockRequiredRoutes(mockAdapter) {
  mockAdapter.onGet(mockData.endpoints.stageData).reply(httpStatusCodes.OK, mockData.issueEvents);
  mockAdapter
    .onGet(mockData.endpoints.tasksByTypeTopLabelsData)
    .reply(httpStatusCodes.OK, mockData.groupLabels);
  mockAdapter
    .onGet(mockData.endpoints.tasksByTypeData)
    .reply(httpStatusCodes.OK, { ...mockData.tasksByTypeData });
  mockAdapter
    .onGet(mockData.endpoints.baseStagesEndpoint)
    .reply(httpStatusCodes.OK, { ...mockData.customizableStagesAndEvents });
  mockAdapter
    .onGet(mockData.endpoints.durationData)
    .reply(httpStatusCodes.OK, mockData.customizableStagesAndEvents.stages);
  mockAdapter.onGet(mockData.endpoints.stageMedian).reply(httpStatusCodes.OK, { value: null });
  mockAdapter
    .onGet(mockData.endpoints.valueStreamData)
    .reply(httpStatusCodes.OK, mockData.valueStreams);
}

async function shouldMergeUrlParams(wrapper, result) {
  await wrapper.vm.$nextTick();
  expect(urlUtils.mergeUrlParams).toHaveBeenCalledWith(result, window.location.href, {
    spreadArrays: true,
  });
  expect(commonUtils.historyPushState).toHaveBeenCalled();
}

describe('EE Value Stream Analytics component', () => {
  let wrapper;
  let mock;
  let store;

  async function createComponent(options = {}) {
    const {
      opts = {
        stubs: defaultStubs,
      },
      shallow = true,
      withStageSelected = false,
      featureFlags = {},
      initialState = initialCycleAnalyticsState,
      props = {},
      selectedStage = null,
    } = options;

    store = createStore();
    await store.dispatch('initializeCycleAnalytics', {
      ...initialState,
      featureFlags: {
        ...defaultFeatureFlags,
        ...featureFlags,
      },
    });

    const func = shallow ? shallowMount : mount;
    const comp = func(Component, {
      localVue,
      store,
      propsData: {
        emptyStateSvgPath,
        noDataSvgPath,
        noAccessSvgPath,
        ...props,
      },
      mocks,
      ...opts,
    });

    if (withStageSelected || selectedStage) {
      await store.dispatch(
        'receiveGroupStagesSuccess',
        mockData.customizableStagesAndEvents.stages,
      );
      if (selectedStage) {
        await store.dispatch('setSelectedStage', selectedStage);
        await store.dispatch('fetchStageData', selectedStage.slug);
      } else {
        await store.dispatch('setDefaultSelectedStage');
      }
    }
    return comp;
  }

  const findPathNavigation = () => wrapper.findComponent(PathNavigation);
  const findStageTable = () => wrapper.findComponent(StageTable);

  const displaysProjectsDropdownFilter = (flag) => {
    expect(wrapper.findComponent(ProjectsDropdownFilter).exists()).toBe(flag);
  };

  const displaysDateRangePicker = (flag) => {
    expect(wrapper.findComponent(Daterange).exists()).toBe(flag);
  };

  const displaysMetrics = (flag) => {
    expect(wrapper.findComponent(Metrics).exists()).toBe(flag);
  };

  const displaysStageTable = (flag) => {
    expect(findStageTable().exists()).toBe(flag);
  };

  const displaysDurationChart = (flag) => {
    expect(wrapper.findComponent(DurationChart).exists()).toBe(flag);
  };

  const displaysTypeOfWork = (flag) => {
    expect(wrapper.findComponent(TypeOfWorkCharts).exists()).toBe(flag);
  };

  const displaysPathNavigation = (flag) => {
    expect(findPathNavigation().exists()).toBe(flag);
  };

  const displaysFilterBar = (flag) => {
    expect(wrapper.findComponent(FilterBar).exists()).toBe(flag);
  };

  const displaysValueStreamSelect = (flag) => {
    expect(wrapper.findComponent(ValueStreamSelect).exists()).toBe(flag);
  };

  describe('without a group', () => {
    beforeEach(async () => {
      const { group, ...stateWithoutGroup } = initialCycleAnalyticsState;
      mock = new MockAdapter(axios);
      wrapper = await createComponent({ initialState: stateWithoutGroup });
    });

    afterEach(() => {
      wrapper.destroy();
      mock.restore();
      wrapper = null;
    });

    it('displays an empty state', () => {
      const emptyState = wrapper.findComponent(GlEmptyState);

      expect(emptyState.exists()).toBe(true);
      expect(emptyState.props('svgPath')).toBe(emptyStateSvgPath);
    });

    it('does not display the projects filter', () => {
      displaysProjectsDropdownFilter(false);
    });

    it('does not display the date range picker', () => {
      displaysDateRangePicker(false);
    });

    it('does not display the metrics cards', () => {
      displaysMetrics(false);
    });

    it('does not display the stage table', () => {
      displaysStageTable(false);
    });

    it('does not display the duration chart', () => {
      displaysDurationChart(false);
    });

    it('does not display the path navigation', () => {
      displaysPathNavigation(false);
    });

    it('does not display the value stream select component', () => {
      displaysValueStreamSelect(false);
    });
  });

  describe('the user does not have access to the group', () => {
    beforeEach(async () => {
      mock = new MockAdapter(axios);
      mockRequiredRoutes(mock);

      wrapper = await createComponent();

      await store.dispatch('receiveCycleAnalyticsDataError', {
        response: { status: httpStatusCodes.FORBIDDEN },
      });
    });

    it('renders the no access information', () => {
      const emptyState = wrapper.findComponent(GlEmptyState);

      expect(emptyState.exists()).toBe(true);
      expect(emptyState.props('svgPath')).toBe(noAccessSvgPath);
    });

    it('does not display the projects filter', () => {
      displaysProjectsDropdownFilter(false);
    });

    it('does not display the date range picker', () => {
      displaysDateRangePicker(false);
    });

    it('does not display the metrics', () => {
      displaysMetrics(false);
    });

    it('does not display the stage table', () => {
      displaysStageTable(false);
    });

    it('does not display the tasks by type chart', () => {
      displaysTypeOfWork(false);
    });

    it('does not display the duration chart', () => {
      displaysDurationChart(false);
    });

    it('does not display the path navigation', () => {
      displaysPathNavigation(false);
    });
  });

  describe('the user has access to the group', () => {
    beforeEach(async () => {
      mock = new MockAdapter(axios);
      mockRequiredRoutes(mock);
      wrapper = await createComponent({ withStageSelected: true });
    });

    afterEach(() => {
      wrapper.destroy();
      mock.restore();
      wrapper = null;
    });

    it('hides the empty state', () => {
      expect(wrapper.findComponent(GlEmptyState).exists()).toBe(false);
    });

    it('displays the projects filter', () => {
      displaysProjectsDropdownFilter(true);

      expect(wrapper.findComponent(ProjectsDropdownFilter).props()).toEqual(
        expect.objectContaining({
          queryParams: wrapper.vm.projectsQueryParams,
          multiSelect: wrapper.vm.$options.multiProjectSelect,
        }),
      );
    });

    it('displays the value stream select component', () => {
      displaysValueStreamSelect(true);
    });

    it('displays the date range picker', () => {
      displaysDateRangePicker(true);
    });

    it('displays the filter bar', () => {
      displaysFilterBar(true);
    });

    it('displays the metrics', () => {
      displaysMetrics(true);
    });

    it('displays the type of work chart', () => {
      displaysTypeOfWork(true);
    });

    it('displays the duration chart', () => {
      displaysDurationChart(true);
    });

    it('hides the stage table', () => {
      displaysStageTable(false);
    });

    describe('Without the overview stage selected', () => {
      beforeEach(async () => {
        mock = new MockAdapter(axios);
        mockRequiredRoutes(mock);
        wrapper = await createComponent({ selectedStage: mockData.issueStage });
      });

      it('displays the stage table', () => {
        displaysStageTable(true);
      });

      it('displays the path navigation', () => {
        displaysPathNavigation(true);
      });
    });
  });

  describe('with failed requests while loading', () => {
    beforeEach(async () => {
      mock = new MockAdapter(axios);
      mockRequiredRoutes(mock);
    });

    afterEach(() => {
      wrapper.destroy();
      mock.restore();
      wrapper = null;
    });

    it('will display an error if the fetchGroupStagesAndEvents request fails', async () => {
      expect(createFlash).not.toHaveBeenCalled();

      mock
        .onGet(mockData.endpoints.baseStagesEndpoint)
        .reply(httpStatusCodes.NOT_FOUND, { response: { status: httpStatusCodes.NOT_FOUND } });
      wrapper = await createComponent();

      expect(createFlash).toHaveBeenCalledWith({
        message: 'There was an error fetching value stream analytics stages.',
      });
    });

    it('will display an error if the fetchStageData request fails', async () => {
      expect(createFlash).not.toHaveBeenCalled();

      mock
        .onGet(mockData.endpoints.stageData)
        .reply(httpStatusCodes.NOT_FOUND, { response: { status: httpStatusCodes.NOT_FOUND } });

      wrapper = await createComponent({ selectedStage: mockData.issueStage });

      expect(createFlash).toHaveBeenCalledWith({
        message: 'There was an error fetching data for the selected stage',
      });
    });

    it('will display an error if the fetchTopRankedGroupLabels request fails', async () => {
      expect(createFlash).not.toHaveBeenCalled();

      mock
        .onGet(mockData.endpoints.tasksByTypeTopLabelsData)
        .reply(httpStatusCodes.NOT_FOUND, { response: { status: httpStatusCodes.NOT_FOUND } });
      wrapper = await createComponent();
      await waitForPromises();

      expect(createFlash).toHaveBeenCalledWith({
        message: 'There was an error fetching the top labels for the selected group',
      });
    });

    it('will display an error if the fetchTasksByTypeData request fails', async () => {
      expect(createFlash).not.toHaveBeenCalled();

      mock
        .onGet(mockData.endpoints.tasksByTypeData)
        .reply(httpStatusCodes.NOT_FOUND, { response: { status: httpStatusCodes.NOT_FOUND } });
      wrapper = await createComponent();
      await waitForPromises();

      expect(createFlash).toHaveBeenCalledWith({
        message: 'There was an error fetching data for the tasks by type chart',
      });
    });

    it('will display an error if the fetchStageMedian request fails', async () => {
      expect(createFlash).not.toHaveBeenCalled();

      mock
        .onGet(mockData.endpoints.stageMedian)
        .reply(httpStatusCodes.NOT_FOUND, { response: { status: httpStatusCodes.NOT_FOUND } });
      wrapper = await createComponent();

      expect(createFlash).toHaveBeenCalledWith({
        message: 'There was an error fetching median data for stages',
      });
    });

    it('will display an error if the fetchStageData request is successful but has an embedded error', async () => {
      const tooMuchDataError = 'There is too much data to calculate. Please change your selection.';
      mock
        .onGet(mockData.endpoints.stageData)
        .reply(httpStatusCodes.OK, { error: tooMuchDataError });

      wrapper = await createComponent({ selectedStage: mockData.issueStage });

      displaysStageTable(true);
      expect(findStageTable().props('emptyStateMessage')).toBe(tooMuchDataError);
      expect(findStageTable().props('stageEvents')).toEqual([]);
      expect(findStageTable().props('pagination')).toEqual({});
    });
  });

  describe('Path navigation', () => {
    const selectedStage = { title: 'Plan', slug: 2 };
    const overviewStage = { title: 'Overview', slug: OVERVIEW_STAGE_ID };
    let actionSpies = {};

    beforeEach(async () => {
      mock = new MockAdapter(axios);
      mockRequiredRoutes(mock);
      wrapper = await createComponent();
      actionSpies = {
        setDefaultSelectedStage: jest.spyOn(wrapper.vm, 'setDefaultSelectedStage'),
        setSelectedStage: jest.spyOn(wrapper.vm, 'setSelectedStage'),
        updateStageTablePagination: jest.spyOn(wrapper.vm, 'updateStageTablePagination'),
      };
    });

    afterEach(() => {
      wrapper.destroy();
      mock.restore();
      wrapper = null;
    });

    it('when a stage is selected', () => {
      findPathNavigation().vm.$emit('selected', selectedStage);

      expect(actionSpies.setDefaultSelectedStage).not.toHaveBeenCalled();
      expect(actionSpies.setSelectedStage).toHaveBeenCalledWith(selectedStage);
      expect(actionSpies.updateStageTablePagination).toHaveBeenCalledWith({
        ...mockData.initialPaginationQuery,
        page: 1,
      });
    });

    it('when the overview is selected', () => {
      findPathNavigation().vm.$emit('selected', overviewStage);

      expect(actionSpies.setSelectedStage).not.toHaveBeenCalled();
      expect(actionSpies.updateStageTablePagination).not.toHaveBeenCalled();
      expect(actionSpies.setDefaultSelectedStage).toHaveBeenCalled();
    });
  });

  describe('Url parameters', () => {
    const defaultParams = {
      value_stream_id: selectedValueStream.id,
      created_after: toYmd(mockData.startDate),
      created_before: toYmd(mockData.endDate),
      stage_id: null,
      project_ids: null,
      sort: null,
      direction: null,
      page: null,
    };

    const selectedProjectIds = mockData.selectedProjects.map(({ id }) => getIdFromGraphQLId(id));
    const selectedStage = { title: 'Plan', id: 2 };

    beforeEach(async () => {
      commonUtils.historyPushState = jest.fn();
      urlUtils.mergeUrlParams = jest.fn();

      mock = new MockAdapter(axios);
      mockRequiredRoutes(mock);
    });

    afterEach(() => {
      wrapper.destroy();
      mock.restore();
      wrapper = null;
    });

    describe('with minimal parameters set set', () => {
      beforeEach(async () => {
        wrapper = await createComponent();

        await store.dispatch('initializeCycleAnalytics', {
          ...initialCycleAnalyticsState,
          selectedValueStream: null,
        });
      });

      it('sets the created_after and created_before url parameters', async () => {
        await shouldMergeUrlParams(wrapper, defaultParams);
      });
    });

    describe('with selectedValueStream set', () => {
      beforeEach(async () => {
        wrapper = await createComponent();
        await store.dispatch('initializeCycleAnalytics', initialCycleAnalyticsState);
        await wrapper.vm.$nextTick();
      });

      it('sets the value_stream_id url parameter', async () => {
        await shouldMergeUrlParams(wrapper, {
          ...defaultParams,
          created_after: toYmd(mockData.startDate),
          created_before: toYmd(mockData.endDate),
          project_ids: null,
        });
      });
    });

    describe('with selectedProjectIds set', () => {
      beforeEach(async () => {
        wrapper = await createComponent();
        await store.dispatch('setSelectedProjects', mockData.selectedProjects);
        await wrapper.vm.$nextTick();
      });

      it('sets the project_ids url parameter', async () => {
        await shouldMergeUrlParams(wrapper, {
          ...defaultParams,
          created_after: toYmd(mockData.startDate),
          created_before: toYmd(mockData.endDate),
          project_ids: selectedProjectIds,
          stage_id: null,
        });
      });
    });

    describe('with selectedStage set', () => {
      beforeEach(async () => {
        wrapper = await createComponent({
          initialState: {
            ...initialCycleAnalyticsState,
            pagination: mockData.initialPaginationQuery,
          },
          selectedStage,
        });
      });

      it('sets the stage, sort, direction and page parameters', async () => {
        await shouldMergeUrlParams(wrapper, {
          ...defaultParams,
          ...mockData.initialPaginationQuery,
          stage_id: selectedStage.id,
        });
      });
    });
  });
});
