import { GlEmptyState } from '@gitlab/ui';
import { createLocalVue, shallowMount, mount } from '@vue/test-utils';
import axios from 'axios';
import MockAdapter from 'axios-mock-adapter';
import Vuex from 'vuex';
import AddStageButton from 'ee/analytics/cycle_analytics/components/add_stage_button.vue';
import Component from 'ee/analytics/cycle_analytics/components/base.vue';
import CustomStageForm from 'ee/analytics/cycle_analytics/components/custom_stage_form.vue';
import DurationChart from 'ee/analytics/cycle_analytics/components/duration_chart.vue';
import FilterBar from 'ee/analytics/cycle_analytics/components/filter_bar.vue';
import Metrics from 'ee/analytics/cycle_analytics/components/metrics.vue';
import PathNavigation from 'ee/analytics/cycle_analytics/components/path_navigation.vue';
import StageNavItem from 'ee/analytics/cycle_analytics/components/stage_nav_item.vue';
import StageTable from 'ee/analytics/cycle_analytics/components/stage_table.vue';
import StageTableNav from 'ee/analytics/cycle_analytics/components/stage_table_nav.vue';
import TypeOfWorkCharts from 'ee/analytics/cycle_analytics/components/type_of_work_charts.vue';
import ValueStreamSelect from 'ee/analytics/cycle_analytics/components/value_stream_select.vue';
import createStore from 'ee/analytics/cycle_analytics/store';
import Daterange from 'ee/analytics/shared/components/daterange.vue';
import ProjectsDropdownFilter from 'ee/analytics/shared/components/projects_dropdown_filter.vue';
import { toYmd } from 'ee/analytics/shared/utils';
import waitForPromises from 'helpers/wait_for_promises';
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

const localVue = createLocalVue();
localVue.use(Vuex);

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
  hasPathNavigation: false,
};

const [selectedValueStream] = mockData.valueStreams;

const initialCycleAnalyticsState = {
  selectedValueStream,
  createdAfter: mockData.startDate,
  createdBefore: mockData.endDate,
  group: currentGroup,
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

describe('Value Stream Analytics component', () => {
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

    if (withStageSelected) {
      await Promise.all([
        store.dispatch('receiveGroupStagesSuccess', mockData.customizableStagesAndEvents.stages),
        store.dispatch('receiveStageDataSuccess', mockData.issueEvents),
      ]);
    }
    return comp;
  }

  const findStageNavItemAtIndex = (index) =>
    wrapper.find(StageTableNav).findAll(StageNavItem).at(index);

  const findAddStageButton = () => wrapper.find(AddStageButton);

  const displaysProjectsDropdownFilter = (flag) => {
    expect(wrapper.find(ProjectsDropdownFilter).exists()).toBe(flag);
  };

  const displaysDateRangePicker = (flag) => {
    expect(wrapper.find(Daterange).exists()).toBe(flag);
  };

  const displaysMetrics = (flag) => {
    expect(wrapper.find(Metrics).exists()).toBe(flag);
  };

  const displaysStageTable = (flag) => {
    expect(wrapper.find(StageTable).exists()).toBe(flag);
  };

  const displaysDurationChart = (flag) => {
    expect(wrapper.find(DurationChart).exists()).toBe(flag);
  };

  const displaysTypeOfWork = (flag) => {
    expect(wrapper.find(TypeOfWorkCharts).exists()).toBe(flag);
  };

  const displaysPathNavigation = (flag) => {
    expect(wrapper.find(PathNavigation).exists()).toBe(flag);
  };

  const displaysAddStageButton = (flag) => {
    expect(wrapper.find(AddStageButton).exists()).toBe(flag);
  };

  const displaysFilterBar = (flag) => {
    expect(wrapper.find(FilterBar).exists()).toBe(flag);
  };

  const displaysValueStreamSelect = (flag) => {
    expect(wrapper.find(ValueStreamSelect).exists()).toBe(flag);
  };

  describe('without a group', () => {
    beforeEach(async () => {
      const { group, ...stateWithoutGroup } = initialCycleAnalyticsState;
      mock = new MockAdapter(axios);
      wrapper = await createComponent({
        featureFlags: {
          hasPathNavigation: true,
        },
        initialState: stateWithoutGroup,
      });
    });

    afterEach(() => {
      wrapper.destroy();
      mock.restore();
      wrapper = null;
    });

    it('displays an empty state', () => {
      const emptyState = wrapper.find(GlEmptyState);

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

    it('does not display the add stage button', () => {
      displaysAddStageButton(false);
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

      wrapper = await createComponent({
        featureFlags: {
          hasPathNavigation: true,
        },
      });

      await store.dispatch('receiveCycleAnalyticsDataError', {
        response: { status: httpStatusCodes.FORBIDDEN },
      });
    });

    it('renders the no access information', () => {
      const emptyState = wrapper.find(GlEmptyState);

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

    it('does not display the add stage button', () => {
      displaysAddStageButton(false);
    });

    it('does not display the tasks by type chart', () => {
      displaysTypeOfWork(false);
    });

    it('does not display the duration chart', () => {
      displaysDurationChart(false);
    });

    describe('path navigation', () => {
      describe('disabled', () => {
        it('does not display the path navigation', () => {
          displaysPathNavigation(false);
        });
      });

      describe('enabled', () => {
        beforeEach(async () => {
          wrapper = await createComponent({
            withStageSelected: true,
            pathNavigationEnabled: true,
          });

          mock = new MockAdapter(axios);
          mockRequiredRoutes(mock);
          mock.onAny().reply(httpStatusCodes.FORBIDDEN);

          await waitForPromises();
        });

        afterEach(() => {
          mock.restore();
        });

        it('does not display the path navigation', () => {
          displaysPathNavigation(false);
        });
      });
    });
  });

  describe('the user has access to the group', () => {
    beforeEach(async () => {
      mock = new MockAdapter(axios);
      mockRequiredRoutes(mock);
      wrapper = await createComponent({
        withStageSelected: true,
        featureFlags: {
          hasPathNavigation: true,
        },
      });
    });

    afterEach(() => {
      wrapper.destroy();
      mock.restore();
      wrapper = null;
    });

    it('hides the empty state', () => {
      expect(wrapper.find(GlEmptyState).exists()).toBe(false);
    });

    it('displays the projects filter', () => {
      displaysProjectsDropdownFilter(true);

      expect(wrapper.find(ProjectsDropdownFilter).props()).toEqual(
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

    it('displays the metrics', () => {
      displaysMetrics(true);
    });

    it('displays the stage table', () => {
      displaysStageTable(true);
    });

    it('displays the filter bar', () => {
      displaysFilterBar(true);
    });

    it('displays the add stage button', async () => {
      wrapper = await createComponent({
        opts: {
          stubs: {
            StageTable,
            StageTableNav,
            AddStageButton,
          },
        },
        withStageSelected: true,
      });

      await wrapper.vm.$nextTick();
      displaysAddStageButton(true);
    });

    it('displays the tasks by type chart', async () => {
      wrapper = await createComponent({ shallow: false, withStageSelected: true });
      await wrapper.vm.$nextTick();
      expect(wrapper.find('.js-tasks-by-type-chart').exists()).toBe(true);
    });

    it('displays the duration chart', () => {
      displaysDurationChart(true);
    });

    describe('path navigation', () => {
      describe('disabled', () => {
        beforeEach(async () => {
          wrapper = await createComponent({
            withStageSelected: true,
            featureFlags: {
              hasPathNavigation: false,
            },
          });
        });

        it('does not display the path navigation', () => {
          displaysPathNavigation(false);
        });
      });

      describe('enabled', () => {
        beforeEach(async () => {
          wrapper = await createComponent({
            withStageSelected: true,
            featureFlags: {
              hasPathNavigation: true,
            },
          });
        });

        it('displays the path navigation', () => {
          displaysPathNavigation(true);
        });
      });
    });

    describe('StageTable', () => {
      beforeEach(async () => {
        mock = new MockAdapter(axios);
        mockRequiredRoutes(mock);

        wrapper = await createComponent({
          opts: {
            stubs: {
              StageTable,
              StageTableNav,
              StageNavItem,
            },
          },
          withStageSelected: true,
        });
      });

      it('has the first stage selected by default', async () => {
        const first = findStageNavItemAtIndex(0);
        const second = findStageNavItemAtIndex(1);

        expect(first.props('isActive')).toBe(true);
        expect(second.props('isActive')).toBe(false);
      });

      it('can navigate to different stages', async () => {
        findStageNavItemAtIndex(2).trigger('click');

        await wrapper.vm.$nextTick();
        const first = findStageNavItemAtIndex(0);
        const third = findStageNavItemAtIndex(2);
        expect(third.props('isActive')).toBe(true);
        expect(first.props('isActive')).toBe(false);
      });

      describe('Add stage button', () => {
        beforeEach(async () => {
          wrapper = await createComponent({
            opts: {
              stubs: {
                StageTable,
                StageTableNav,
                AddStageButton,
              },
            },
            withStageSelected: true,
          });
        });

        it('can navigate to the custom stage form', async () => {
          expect(wrapper.find(CustomStageForm).exists()).toBe(false);
          findAddStageButton().trigger('click');

          await wrapper.vm.$nextTick();
          expect(wrapper.find(CustomStageForm).exists()).toBe(true);
        });
      });
    });
  });

  describe('with failed requests while loading', () => {
    beforeEach(async () => {
      setFixtures('<div class="flash-container"></div>');

      mock = new MockAdapter(axios);
      mockRequiredRoutes(mock);
      wrapper = await createComponent({
        featureFlags: {
          hasPathNavigation: true,
        },
      });
    });

    afterEach(() => {
      wrapper.destroy();
      mock.restore();
      wrapper = null;
    });

    const findFlashError = () => document.querySelector('.flash-container .flash-text');
    const findError = async (msg) => {
      await waitForPromises();
      expect(findFlashError().innerText.trim()).toEqual(msg);
    };

    it('will display an error if the fetchGroupStagesAndEvents request fails', async () => {
      expect(await findFlashError()).toBeNull();

      mock
        .onGet(mockData.endpoints.baseStagesEndpoint)
        .reply(httpStatusCodes.NOT_FOUND, { response: { status: httpStatusCodes.NOT_FOUND } });
      wrapper = await createComponent();

      await findError('There was an error fetching value stream analytics stages.');
    });

    it('will display an error if the fetchStageData request fails', async () => {
      expect(await findFlashError()).toBeNull();

      mock
        .onGet(mockData.endpoints.stageData)
        .reply(httpStatusCodes.NOT_FOUND, { response: { status: httpStatusCodes.NOT_FOUND } });
      await createComponent();

      await findError('There was an error fetching data for the selected stage');
    });

    it('will display an error if the fetchTopRankedGroupLabels request fails', async () => {
      expect(await findFlashError()).toBeNull();

      mock
        .onGet(mockData.endpoints.tasksByTypeTopLabelsData)
        .reply(httpStatusCodes.NOT_FOUND, { response: { status: httpStatusCodes.NOT_FOUND } });
      await createComponent();

      await findError('There was an error fetching the top labels for the selected group');
    });

    it('will display an error if the fetchTasksByTypeData request fails', async () => {
      expect(await findFlashError()).toBeNull();

      mock
        .onGet(mockData.endpoints.tasksByTypeData)
        .reply(httpStatusCodes.NOT_FOUND, { response: { status: httpStatusCodes.NOT_FOUND } });
      await createComponent();

      await findError('There was an error fetching data for the tasks by type chart');
    });

    it('will display an error if the fetchStageMedian request fails', async () => {
      expect(await findFlashError()).toBeNull();

      mock
        .onGet(mockData.endpoints.stageMedian)
        .reply(httpStatusCodes.NOT_FOUND, { response: { status: httpStatusCodes.NOT_FOUND } });
      await createComponent();

      await waitForPromises();
      expect(await findFlashError().innerText.trim()).toEqual(
        'There was an error fetching median data for stages',
      );
    });
  });

  describe('Url parameters', () => {
    const defaultParams = {
      value_stream_id: selectedValueStream.id,
      created_after: toYmd(mockData.startDate),
      created_before: toYmd(mockData.endDate),
      project_ids: null,
    };

    const selectedProjectIds = mockData.selectedProjects.map(({ id }) => getIdFromGraphQLId(id));

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
        store.dispatch('setSelectedProjects', mockData.selectedProjects);
        await wrapper.vm.$nextTick();
      });

      it('sets the project_ids url parameter', async () => {
        await shouldMergeUrlParams(wrapper, {
          ...defaultParams,
          created_after: toYmd(mockData.startDate),
          created_before: toYmd(mockData.endDate),
          project_ids: selectedProjectIds,
        });
      });
    });
  });
});
