import { createLocalVue, shallowMount } from '@vue/test-utils';
import { GlLineChart } from '@gitlab/ui/dist/charts';
import { GlAlert } from '@gitlab/ui';
import VueApollo from 'vue-apollo';
import createMockApollo from 'jest/helpers/mock_apollo_helper';
import { useFakeDate } from 'helpers/fake_date';
import ProjectsAndGroupChart from '~/analytics/instance_statistics/components/projects_and_groups_chart.vue';
import ChartSkeletonLoader from '~/vue_shared/components/resizable_chart/skeleton_loader.vue';
import projectsQuery from '~/analytics/instance_statistics/graphql/queries/projects.query.graphql';
import groupsQuery from '~/analytics/instance_statistics/graphql/queries/groups.query.graphql';
import { mockCountsData2, roundedSortedCountsMonthlyChartData2, mockPageInfo } from '../mock_data';

const localVue = createLocalVue();
localVue.use(VueApollo);

describe('ProjectsAndGroupChart', () => {
  let wrapper;
  let projectsQueryResponse;

  const mockApolloResponse = ({ loading = false, hasNextPage = false, key, data }) => ({
    data: {
      [key]: {
        pageInfo: { ...mockPageInfo, hasNextPage },
        nodes: data,
        loading,
      },
    },
  });

  const mockQueryResponse = ({ key, data = [], loading = false, hasNextPage = false }) => {
    const projectsApolloQueryResponse = mockApolloResponse({ loading, hasNextPage, key, data });
    if (loading) {
      return jest.fn().mockReturnValue(new Promise(() => {}));
    }
    if (hasNextPage) {
      return jest
        .fn()
        .mockResolvedValueOnce(projectsApolloQueryResponse)
        .mockResolvedValueOnce(
          mockApolloResponse({
            loading,
            hasNextPage: false,
            projects: [{ recordedAt: '2020-07-21', count: 5 }],
          }),
        );
    }
    return jest.fn().mockResolvedValue(projectsApolloQueryResponse);
  };

  const createComponent = ({
    loadingError = false,
    loading = false,
    projects = [],
    hasNextPage = false,
  } = {}) => {
    projectsQueryResponse = mockQueryResponse({ key:'projects', data: projects, loading, hasNextPage });

    return shallowMount(ProjectsAndGroupChart, {
      props: {
        startDate: useFakeDate(2020, 9, 26),
        endDate: useFakeDate(2020, 10, 1),
        totalDataPoints: mockCountsData2.length,
      },
      localVue,
      apolloProvider: createMockApollo([
        [projectsQuery, projectsQueryResponse],
        [groupsQuery, mockQueryResponse({ loading, hasNextPage: false, key:'groups', data: [] })]
      ]),
      data() {
        return { loadingError };
      },
    });
  };

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
  });

  const findLoader = () => wrapper.find(ChartSkeletonLoader);
  const findAlert = () => wrapper.find(GlAlert);
  const findChart = () => wrapper.find(GlLineChart);

  describe('while loading', () => {
    beforeEach(() => {
      wrapper = createComponent({ loading: true });
    });

    it('displays the skeleton loader', () => {
      expect(findLoader().exists()).toBe(true);
    });

    it('hides the chart', () => {
      expect(findChart().exists()).toBe(false);
    });
  });

  describe('without data', () => {
    beforeEach(async () => {
      wrapper = createComponent({ projects: [] });
      await wrapper.vm.$nextTick();
    });

    it('renders an no data message', () => {
      expect(findAlert().text()).toBe('There is no data available.');
    });

    it('hides the skeleton loader', () => {
      expect(findLoader().exists()).toBe(false);
    });

    it('renders the chart', () => {
      expect(findChart().exists()).toBe(false);
    });
  });

  describe('with data', () => {
    beforeEach(async () => {
      wrapper = createComponent({ projects: mockCountsData2 });
      await wrapper.vm.$nextTick();
    });

    it('hides the skeleton loader', () => {
      expect(findLoader().exists()).toBe(false);
    });

    it('renders the chart', () => {
      expect(findChart().exists()).toBe(true);
    });

    it('passes the data to the line chart', () => {
      expect(findChart().props('data')).toEqual([
        { data: roundedSortedCountsMonthlyChartData2, name: 'Total projects' },
        { data: [], name: 'Total groups' },
      ]);
    });
  });

  describe('with errors', () => {
    beforeEach(async () => {
      wrapper = createComponent({ loadingError: true });
      await wrapper.vm.$nextTick();
    });

    it('renders an error message', () => {
      expect(findAlert().text()).toBe('There is no data available.');
    });

    it('hides the skeleton loader', () => {
      expect(findLoader().exists()).toBe(false);
    });

    it('renders the chart', () => {
      expect(findChart().exists()).toBe(false);
    });
  });

  describe('when fetching more data', () => {
    describe('when the fetchMore query returns data', () => {
      beforeEach(async () => {
        wrapper = createComponent({
          projects: mockCountsData2,
          hasNextPage: true,
        });

        jest.spyOn(wrapper.vm.$apollo.queries.projects, 'fetchMore');
        await wrapper.vm.$nextTick();
      });

      it('requests data twice', () => {
        expect(projectsQueryResponse).toBeCalledTimes(2);
      });

      it('calls fetchMore', () => {
        expect(wrapper.vm.$apollo.queries.projects.fetchMore).toHaveBeenCalledTimes(1);
      });
    });

    describe('when the fetchMore query throws an error', () => {
      beforeEach(() => {
        wrapper = createComponent({
          projects: mockCountsData2,
          hasNextPage: true,
        });

        jest
          .spyOn(wrapper.vm.$apollo.queries.projects, 'fetchMore')
          .mockImplementation(jest.fn().mockRejectedValue());
        return wrapper.vm.$nextTick();
      });

      it('calls fetchMore', () => {
        expect(wrapper.vm.$apollo.queries.projects.fetchMore).toHaveBeenCalledTimes(1);
      });

      it('renders an error message', () => {
        expect(findAlert().text()).toBe('There is no data available.');
      });
    });
  });
});
