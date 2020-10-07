import { shallowMount } from '@vue/test-utils';
import { GlLineChart } from '@gitlab/ui/dist/charts';
import { useFakeDate } from 'helpers/fake_date';
import IssuesAndMergeRequestsChart from '~/analytics/instance_statistics/components/issues_and_merge_requests_chart.vue';
import ChartSkeletonLoader from '~/vue_shared/components/resizable_chart/skeleton_loader.vue';
import { mockIssueCounts, mockMergeRequestCounts } from '../mock_data';

describe('IssuesAndMergeRequestsChart', () => {
  let wrapper;

  const createComponent = ({ loading = false, data = {} } = {}) => {
    const $apollo = {
      queries: {
        usersTotal: {
          loading,
        },
      },
    };

    wrapper = shallowMount(IssuesAndMergeRequestsChart, {
      props: {
        startDate: useFakeDate(2020, 9, 26),
        endDate: useFakeDate(2020, 10, 1),
        totalDataPoints: 200,
      },
      mocks: { $apollo },
      data() {
        return {
          ...data,
        };
      },
    });
  };

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
  });

  const findLoader = () => wrapper.find(ChartSkeletonLoader);
  const findChart = () => wrapper.find(GlLineChart);

  describe('while loading', () => {
    beforeEach(() => {
      createComponent({ loading: true });
    });

    it('displays the skeleton loader', () => {
      expect(findLoader().exists()).toBe(true);
    });

    it('hides the chart', () => {
      expect(findChart().exists()).toBe(false);
    });
  });

  describe('with data', () => {
    beforeEach(() => {
      createComponent({ data: { issues: mockIssueCounts, mergeRequests: mockMergeRequestCounts } });
      return wrapper.vm.$nextTick();
    });

    it('hides the skeleton loader', () => {
      expect(findLoader().exists()).toBe(false);
    });

    it('renders the chart', () => {
      expect(findChart().exists()).toBe(true);
    });

    it('passes the data to the line chart', () => {
      expect(findChart().props('data')).toEqual([
        { data: mockIssueCounts, name: 'Issues' },
        { data: mockMergeRequestCounts, name: 'Merge Requests' },
      ]);
    });
  });
});
