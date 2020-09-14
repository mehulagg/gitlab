import { createLocalVue, shallowMount, mount } from '@vue/test-utils';
import Vuex from 'vuex';
import createStore from 'ee/analytics/cycle_analytics/store';
import Component from 'ee/analytics/cycle_analytics/components/base.vue';
import { GlEmptyState } from '@gitlab/ui';
import axios from 'axios';
import MockAdapter from 'axios-mock-adapter';
import ProjectsDropdownFilter from 'ee/analytics/shared/components/projects_dropdown_filter.vue';
import Metrics from 'ee/analytics/cycle_analytics/components/metrics.vue';
import PathNavigation from 'ee/analytics/cycle_analytics/components/path_navigation.vue';
import StageTable from 'ee/analytics/cycle_analytics/components/stage_table.vue';
import StageTableNav from 'ee/analytics/cycle_analytics/components/stage_table_nav.vue';
import StageNavItem from 'ee/analytics/cycle_analytics/components/stage_nav_item.vue';
import AddStageButton from 'ee/analytics/cycle_analytics/components/add_stage_button.vue';
import CustomStageForm from 'ee/analytics/cycle_analytics/components/custom_stage_form.vue';
import FilterBar from 'ee/analytics/cycle_analytics/components/filter_bar.vue';
import DurationChart from 'ee/analytics/cycle_analytics/components/duration_chart.vue';
import Daterange from 'ee/analytics/shared/components/daterange.vue';
import TypeOfWorkCharts from 'ee/analytics/cycle_analytics/components/type_of_work_charts.vue';
import ValueStreamSelect from 'ee/analytics/cycle_analytics/components/value_stream_select.vue';
import waitForPromises from 'helpers/wait_for_promises';
import { toYmd } from 'ee/analytics/shared/utils';
import httpStatusCodes from '~/lib/utils/http_status';
import UrlSync from '~/vue_shared/components/url_sync.vue';
import * as commonUtils from '~/lib/utils/common_utils';
import * as urlUtils from '~/lib/utils/url_utility';
import * as mockData from '../mock_data';
import { convertObjectPropsToCamelCase } from '~/lib/utils/common_utils';

const noDataSvgPath = 'path/to/no/data';
const noAccessSvgPath = 'path/to/no/access';
const group = convertObjectPropsToCamelCase(mockData.group);

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
  hasCreateMultipleValueStreams: false,
};

const initialCycleAnalyticsState = {
  createdAfter: mockData.startDate,
  createdBefore: mockData.endDate,
  group,
};

const mocks = {
  $toast: {
    show: jest.fn(),
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
}

async function shouldMergeUrlParams(wrapper, result) {
  await wrapper.vm.$nextTick();
  expect(urlUtils.mergeUrlParams).toHaveBeenCalledWith(result, window.location.href, {
    spreadArrays: true,
  });
  expect(commonUtils.historyPushState).toHaveBeenCalled();
}

describe('Cycle Analytics component', () => {
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
      withValueStreamSelected = true,
      featureFlags = {},
      props = {},
    } = options;

    store = createStore();
    await store.dispatch('initializeCycleAnalytics', {
      ...initialCycleAnalyticsState,
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
        noDataSvgPath,
        noAccessSvgPath,
        ...props,
      },
      mocks,
      ...opts,
    });

    if (withValueStreamSelected) {
      await store.dispatch('receiveValueStreamsSuccess', mockData.valueStreams);
    }

    if (withStageSelected) {
      await Promise.all([
        store.dispatch('receiveGroupStagesSuccess', mockData.customizableStagesAndEvents.stages),
        store.dispatch('receiveStageDataSuccess', mockData.issueEvents),
      ]);
    }
    return comp;
  }

  const findStageNavItemAtIndex = index =>
    wrapper
      .find(StageTableNav)
      .findAll(StageNavItem)
      .at(index);

  const findAddStageButton = () => wrapper.find(AddStageButton);

  const displaysProjectsDropdownFilter = flag => {
    expect(wrapper.find(ProjectsDropdownFilter).exists()).toBe(flag);
  };

  const displaysDateRangePicker = flag => {
    expect(wrapper.find(Daterange).exists()).toBe(flag);
  };

  const displaysMetrics = flag => {
    expect(wrapper.find(Metrics).exists()).toBe(flag);
  };

  const displaysStageTable = flag => {
    expect(wrapper.find(StageTable).exists()).toBe(flag);
  };

  const displaysDurationChart = flag => {
    expect(wrapper.find(DurationChart).exists()).toBe(flag);
  };

  const displaysTypeOfWork = flag => {
    expect(wrapper.find(TypeOfWorkCharts).exists()).toBe(flag);
  };

  const displaysPathNavigation = flag => {
    expect(wrapper.find(PathNavigation).exists()).toBe(flag);
  };

  const displaysAddStageButton = flag => {
    expect(wrapper.find(AddStageButton).exists()).toBe(flag);
  };

  const displaysFilterBar = flag => {
    expect(wrapper.find(FilterBar).exists()).toBe(flag);
  };

  const displaysValueStreamSelect = flag => {
    expect(wrapper.find(ValueStreamSelect).exists()).toBe(flag);
  };

  beforeEach(async () => {
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

  describe('displays the components as required', () => {
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

      describe('hasCreateMultipleValueStreams = true', () => {
        beforeEach(() => {
          mock = new MockAdapter(axios);
          mockRequiredRoutes(mock);
        });

        it('hides the value stream select component', () => {
          displaysValueStreamSelect(false);
        });

        it('displays the value stream select component', async () => {
          wrapper = await createComponent({
            featureFlags: {
              hasCreateMultipleValueStreams: true,
            },
          });

          displaysValueStreamSelect(true);
        });
      });

      describe('when analyticsSimilaritySearch feature flag is on', () => {
        beforeEach(async () => {
          wrapper = await createComponent({
            withStageSelected: true,
            featureFlags: {
              hasAnalyticsSimilaritySearch: true,
            },
          });
        });

        it('uses similarity as the order param', () => {
          displaysProjectsDropdownFilter(true);

          expect(wrapper.find(ProjectsDropdownFilter).props().queryParams.order_by).toEqual(
            'similarity',
          );
        });
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
            withValueStreamSelected: false,
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

      describe('the user does not have access to the group', () => {
        beforeEach(async () => {
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
                withValueStreamSelected: false,
                withStageSelected: true,
                pathNavigationEnabled: true,
              });

              mock = new MockAdapter(axios);
              mockRequiredRoutes(mock);
              mock.onAny().reply(httpStatusCodes.FORBIDDEN);

              await waitForPromises();
            });

            it('does not display the path navigation', () => {
              displaysPathNavigation(false);
            });
          });
        });
      });
    });
  });

  describe('with failed requests while loading', () => {
    beforeEach(async () => {
      setFixtures('<div class="flash-container"></div>');

      mock = new MockAdapter(axios);
      mockRequiredRoutes(mock);
    });

    afterEach(() => {
      wrapper.destroy();
      mock.restore();
    });

    const findFlashError = () => document.querySelector('.flash-container .flash-text');
    const findError = async msg => {
      await waitForPromises();
      expect(findFlashError().innerText.trim()).toEqual(msg);
    };

    it('will display an error if the fetchGroupStagesAndEvents request fails', async () => {
      // expect(await findFlashError()).toBeNull();

      mock
        .onGet(mockData.endpoints.baseStagesEndpoint)
        .reply(httpStatusCodes.NOT_FOUND, { response: { status: httpStatusCodes.NOT_FOUND } });
      wrapper = await createComponent();

      await findError('There was an error fetching value stream analytics stages.');
    });

    it('will display an error if the fetchStageData request fails', async () => {
      // expect(await findFlashError()).toBeNull();

      mock
        .onGet(mockData.endpoints.stageData)
        .reply(httpStatusCodes.NOT_FOUND, { response: { status: httpStatusCodes.NOT_FOUND } });
      await createComponent();

      await findError('There was an error fetching data for the selected stage');
    });

    it('will display an error if the fetchTopRankedGroupLabels request fails', async () => {
      // expect(await findFlashError()).toBeNull();

      mock
        .onGet(mockData.endpoints.tasksByTypeTopLabelsData)
        .reply(httpStatusCodes.NOT_FOUND, { response: { status: httpStatusCodes.NOT_FOUND } });
      await createComponent();

      await findError('There was an error fetching the top labels for the selected group');
    });

    it('will display an error if the fetchTasksByTypeData request fails', async () => {
      // expect(await findFlashError()).toBeNull();

      mock
        .onGet(mockData.endpoints.tasksByTypeData)
        .reply(httpStatusCodes.NOT_FOUND, { response: { status: httpStatusCodes.NOT_FOUND } });
      await createComponent();

      await findError('There was an error fetching data for the tasks by type chart');
    });

    it('will display an error if the fetchStageMedian request fails', async () => {
      // expect(await findFlashError()).toBeNull();

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
      created_after: toYmd(mockData.startDate),
      created_before: toYmd(mockData.endDate),
      project_ids: null,
    };

    const selectedProjectIds = mockData.selectedProjects.map(({ id }) => id);

    beforeEach(async () => {
      commonUtils.historyPushState = jest.fn();
      urlUtils.mergeUrlParams = jest.fn();

      mock = new MockAdapter(axios);
      mockRequiredRoutes(mock);
      wrapper = await createComponent();

      await store.dispatch('initializeCycleAnalytics', initialCycleAnalyticsState);
    });

    it('sets the created_after and created_before url parameters', async () => {
      await shouldMergeUrlParams(wrapper, defaultParams);
    });

    describe('with selectedProjectIds set', () => {
      beforeEach(async () => {
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
