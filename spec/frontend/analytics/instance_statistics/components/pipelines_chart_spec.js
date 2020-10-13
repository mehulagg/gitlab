import { createLocalVue, shallowMount } from '@vue/test-utils';
import { GlLineChart } from '@gitlab/ui/dist/charts';
import { useFakeDate } from 'helpers/fake_date';
import VueApollo from 'vue-apollo';
import createMockApollo from 'jest/helpers/mock_apollo_helper';
import waitForPromises from 'helpers/wait_for_promises';
import PipelinesChart from '~/analytics/instance_statistics/components/pipelines_chart.vue';
import pipelinesStatsQuery from '~/analytics/instance_statistics/graphql/queries/pipeline_stats.query.graphql';
import ChartSkeletonLoader from '~/vue_shared/components/resizable_chart/skeleton_loader.vue';
import {
  mockCountsData1,
  mockCountsData2,
  countsMonthlyChartData1,
  countsMonthlyChartData2,
} from '../mock_data';

const reversedChartData1 = [...countsMonthlyChartData1].reverse();
const reversedChartData2 = [...countsMonthlyChartData2].reverse();

const localVue = createLocalVue();
localVue.use(VueApollo);

const defaultPageInfo = { hasPreviousPage: false, startCursor: null, endCursor: null };

describe('PipelinesChart', () => {
  let wrapper;
  let queryHandler;

  const createComponent = (options = {}) => {
    const {
      loading = false,
      pipelinesTotal = [],
      pipelinesSucceeded = [],
      pipelinesFailed = [],
      pipelinesCanceled = [],
      pipelinesSkipped = [],
      hasNextPage = false,
      secondResponse,
    } = options;
    const apolloQueryResponse = {
      data: {
        pipelinesTotal: { pageInfo: { ...defaultPageInfo, hasNextPage }, nodes: pipelinesTotal },
        pipelinesSucceeded: {
          pageInfo: { ...defaultPageInfo, hasNextPage },
          nodes: pipelinesSucceeded,
        },
        pipelinesFailed: { pageInfo: { ...defaultPageInfo, hasNextPage }, nodes: pipelinesFailed },
        pipelinesCanceled: {
          pageInfo: { ...defaultPageInfo, hasNextPage },
          nodes: pipelinesCanceled,
        },
        pipelinesSkipped: {
          pageInfo: { ...defaultPageInfo, hasNextPage },
          nodes: pipelinesSkipped,
        },
      },
    };
    if (loading) {
      queryHandler = jest.fn().mockReturnValue(new Promise(() => {}));
    } else if (secondResponse) {
      queryHandler = jest
        .fn()
        .mockResolvedValueOnce(apolloQueryResponse)
        .mockResolvedValueOnce(secondResponse);
    } else {
      queryHandler = jest.fn().mockResolvedValue(apolloQueryResponse);
    }

    const apolloProvider = createMockApollo([[pipelinesStatsQuery, queryHandler]]);

    return shallowMount(PipelinesChart, {
      localVue,
      apolloProvider,
      props: {
        startDate: useFakeDate(2020, 9, 26),
        endDate: useFakeDate(2020, 10, 1),
        totalDataPoints: 150,
      },
    });
  };

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
  });

  const findLoader = () => wrapper.find(ChartSkeletonLoader);
  const findChart = () => wrapper.find(GlLineChart);
  const findFlashError = () => document.querySelector('.flash-container .flash-text');
  const findError = async msg => {
    await waitForPromises();
    expect(findFlashError().innerText.trim()).toEqual(msg);
  };

  describe('while loading', () => {
    beforeEach(() => {
      wrapper = createComponent({ loading: true });
    });

    it('requests data', () => {
      expect(queryHandler).toBeCalledTimes(1);
    });

    it('displays the skeleton loader', () => {
      expect(findLoader().exists()).toBe(true);
    });

    it('hides the chart', () => {
      expect(findChart().exists()).toBe(false);
    });

    it('does not show an error', async () => {
      expect(await findFlashError()).toBeNull();
    });
  });

  describe('with data', () => {
    beforeEach(() => {
      wrapper = createComponent({
        pipelinesTotal: mockCountsData1,
        pipelinesSucceeded: mockCountsData2,
        pipelinesFailed: mockCountsData2,
        pipelinesCanceled: mockCountsData1,
        pipelinesSkipped: mockCountsData1,
      });
    });

    it('requests data', () => {
      expect(queryHandler).toBeCalledTimes(1);
    });

    it('hides the skeleton loader', () => {
      expect(findLoader().exists()).toBe(false);
    });

    it('renders the chart', () => {
      expect(findChart().exists()).toBe(true);
    });

    it('passes the data to the line chart', () => {
      expect(findChart().props('data')).toEqual([
        { data: reversedChartData1, name: 'Total' },
        { data: reversedChartData2, name: 'Succeeded' },
        { data: reversedChartData2, name: 'Failed' },
        { data: reversedChartData1, name: 'Canceled' },
        { data: reversedChartData1, name: 'Skipped' },
      ]);
    });

    it('does not show an error', async () => {
      expect(await findFlashError()).toBeNull();
    });
  });

  describe('when fetching more data', () => {
    describe('when the fetchMore query returns data', () => {
      beforeEach(async () => {
        const newData = { recordedAt: '2020-07-21', count: 5 };
        wrapper = createComponent({
          pipelinesTotal: mockCountsData2,
          pipelinesSucceeded: mockCountsData2,
          pipelinesFailed: mockCountsData1,
          pipelinesCanceled: mockCountsData2,
          pipelinesSkipped: mockCountsData2,
          hasNextPage: true,
          secondResponse: {
            data: {
              pipelinesTotal: {
                pageInfo: { ...defaultPageInfo, hasNextPage: false },
                nodes: [newData],
              },
              pipelinesSucceeded: {
                pageInfo: { ...defaultPageInfo, hasNextPage: false },
                nodes: [newData],
              },
              pipelinesFailed: {
                pageInfo: { ...defaultPageInfo, hasNextPage: false },
                nodes: [newData],
              },
              pipelinesCanceled: {
                pageInfo: { ...defaultPageInfo, hasNextPage: false },
                nodes: [newData],
              },
              pipelinesSkipped: {
                pageInfo: { ...defaultPageInfo, hasNextPage: false },
                nodes: [newData],
              },
            },
          },
        });

        jest.spyOn(wrapper.vm.$apollo.queries.pipelineStats, 'fetchMore');
        await wrapper.vm.$nextTick();
      });

      it('requests data twice', () => {
        expect(queryHandler).toBeCalledTimes(2);
      });

      it('calls fetchMore', async () => {
        expect(wrapper.vm.$apollo.queries.pipelineStats.fetchMore).toHaveBeenCalledTimes(1);
      });

      it('passes the data to the line chart', async () => {
        const data1Date = reversedChartData1[reversedChartData1.length - 1][0];
        const data2Date = reversedChartData2[reversedChartData2.length - 1][0];
        const remainingChartData1 = reversedChartData1.slice(0, -1);
        const remainingChartData2 = reversedChartData2.slice(0, -1);
        expect(findChart().props('data')).toEqual([
          { data: [...remainingChartData2, [data2Date, 8]], name: 'Total' },
          { data: [...remainingChartData2, [data2Date, 8]], name: 'Succeeded' },
          { data: [...remainingChartData1, [data1Date, 32]], name: 'Failed' },
          { data: [...remainingChartData2, [data2Date, 8]], name: 'Canceled' },
          { data: [...remainingChartData2, [data2Date, 8]], name: 'Skipped' },
        ]);
      });
    });

    describe('when the fetchMore query throws an error', () => {
      beforeEach(async () => {
        setFixtures('<div class="flash-container"></div>');
        wrapper = createComponent({
          pipelinesTotal: mockCountsData2,
          pipelinesSucceeded: mockCountsData2,
          pipelinesFailed: mockCountsData1,
          pipelinesCanceled: mockCountsData2,
          pipelinesSkipped: mockCountsData2,
          hasNextPage: true,
        });
        jest
          .spyOn(wrapper.vm.$apollo.queries.pipelineStats, 'fetchMore')
          .mockImplementation(jest.fn().mockRejectedValue());
        await wrapper.vm.$nextTick();
      });

      it('calls fetchMore', async () => {
        expect(wrapper.vm.$apollo.queries.pipelineStats.fetchMore).toHaveBeenCalledTimes(1);
      });

      it('show an error message', async () => {
        await findError(
          'Could not load the pipelines chart. Please refresh the page to try again.',
        );
      });
    });
  });
});
