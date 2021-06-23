import { shallowMount, createLocalVue } from '@vue/test-utils';
import Vuex from 'vuex';
import TasksByTypeChart from 'ee/analytics/cycle_analytics/components/tasks_by_type/tasks_by_type_chart.vue';
import TasksByTypeFilters from 'ee/analytics/cycle_analytics/components/tasks_by_type/tasks_by_type_filters.vue';
import TypeOfWorkCharts from 'ee/analytics/cycle_analytics/components/type_of_work_charts.vue';
import {
  TASKS_BY_TYPE_SUBJECT_MERGE_REQUEST,
  TASKS_BY_TYPE_FILTERS,
} from 'ee/analytics/cycle_analytics/constants';
import ChartSkeletonLoader from '~/vue_shared/components/resizable_chart/skeleton_loader.vue';
import { tasksByTypeData, taskByTypeFilters } from '../mock_data';

const localVue = createLocalVue();
localVue.use(Vuex);

const actionSpies = {
  setTasksByTypeFilters: jest.fn(),
};

const fakeStore = ({ initialGetters, initialState }) =>
  new Vuex.Store({
    modules: {
      typeOfWork: {
        namespaced: true,
        getters: {
          tasksByTypeChartData: () => tasksByTypeData,
          selectedTasksByTypeFilters: () => taskByTypeFilters,
          currentGroupPath: () => 'fake/group/path',
          ...initialGetters,
        },
        state: {
          ...initialState,
        },
        actions: actionSpies,
      },
    },
  });

describe('TypeOfWorkCharts', () => {
  function createComponent({ stubs = {}, initialGetters, initialState } = {}) {
    return shallowMount(TypeOfWorkCharts, {
      localVue,
      store: fakeStore({ initialGetters, initialState }),
      stubs: {
        TasksByTypeChart: true,
        TasksByTypeFilters: true,
        ...stubs,
      },
    });
  }

  let wrapper = null;

  const findSubjectFilters = (_wrapper) => _wrapper.findComponent(TasksByTypeFilters);
  const findTasksByTypeChart = (_wrapper) => _wrapper.findComponent(TasksByTypeChart);
  const findLoader = (_wrapper) => _wrapper.findComponent(ChartSkeletonLoader);
  const selectedFilterText =
    "Type of work Showing data for group 'Gitlab Org' from Dec 11, 2019 to Jan 10, 2020";

  afterEach(() => {
    wrapper.destroy();
  });

  describe('with data', () => {
    beforeEach(() => {
      wrapper = createComponent();
    });

    it('renders the task by type chart', () => {
      expect(findTasksByTypeChart(wrapper).exists()).toBe(true);
    });

    it('renders a description of the current filters', () => {
      expect(wrapper.text()).toContain(selectedFilterText);
    });

    it('does not render the loading icon', () => {
      expect(findLoader(wrapper).exists()).toBe(false);
    });
  });

  describe('with no data', () => {
    beforeEach(() => {
      wrapper = createComponent({
        initialGetters: {
          tasksByTypeChartData: () => ({ groupBy: [], data: [] }),
        },
      });
    });

    it('does not renders the task by type chart', () => {
      expect(findTasksByTypeChart(wrapper).exists()).toBe(false);
    });

    it('renders the no data available message', () => {
      expect(wrapper.text()).toContain('There is no data available. Please change your selection.');
    });
  });

  describe('when a filter is selected', () => {
    const payload = {
      filter: TASKS_BY_TYPE_FILTERS.SUBJECT,
      value: TASKS_BY_TYPE_SUBJECT_MERGE_REQUEST,
    };

    beforeEach(() => {
      wrapper = createComponent();
      findSubjectFilters(wrapper).vm.$emit('update-filter', payload);
      return wrapper.vm.$nextTick();
    });

    it('calls the setTasksByTypeFilters method', () => {
      expect(actionSpies.setTasksByTypeFilters).toHaveBeenCalledWith(expect.any(Object), payload);
    });
  });

  describe.each`
    stateKey                                | value
    ${'isLoadingTasksByTypeChart'}          | ${true}
    ${'isLoadingTasksByTypeChartTopLabels'} | ${true}
  `('when $stateKey=$value', ({ stateKey, value }) => {
    beforeEach(() => {
      wrapper = createComponent({ initialState: { [stateKey]: value } });
    });

    it('renders loading icon', () => {
      expect(findLoader(wrapper).exists()).toBe(true);
    });
  });
});
