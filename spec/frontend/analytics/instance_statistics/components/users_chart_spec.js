import { shallowMount } from '@vue/test-utils';
import { GlAreaChart } from '@gitlab/ui/dist/charts';
import { GlAlert } from '@gitlab/ui';
import { useFakeDate } from 'helpers/fake_date';
import UsersChart from '~/analytics/instance_statistics/components/users_chart.vue';
import ChartSkeletonLoader from '~/vue_shared/components/resizable_chart/skeleton_loader.vue';
import { mockUsersTotalCount, mockUsersMonthlyChartData } from '../mock_data';

describe('UsersChart', () => {
  let wrapper;

  const createComponent = ({ loading = false, data = {} } = {}) => {
    const $apollo = {
      queries: {
        usersTotal: {
          loading,
        },
      },
    };

    wrapper = shallowMount(UsersChart, {
      props: {
        startDate: useFakeDate(2020, 9, 26),
        endDate: useFakeDate(2020, 10, 1),
        totalDataPoints: mockUsersTotalCount.length,
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
  const findAlert = () => wrapper.find(GlAlert);
  const findChart = () => wrapper.find(GlAreaChart);

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

  describe('without data', () => {
    beforeEach(() => {
      createComponent({ data: { usersTotal: [] } });
      return wrapper.vm.$nextTick();
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
    beforeEach(() => {
      createComponent({ data: { usersTotal: mockUsersTotalCount } });
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
        { data: mockUsersMonthlyChartData, name: 'Users' },
      ]);
    });
  });
});
