import { shallowMount } from '@vue/test-utils';
import UsersChart from '~/analytics/instance_statistics/components/users_chart.vue';
import { GlLineChart } from '@gitlab/ui/dist/charts';
import ChartSkeletonLoader from '~/vue_shared/components/resizable_chart/skeleton_loader.vue';
import countsMockData from '../mock_data';

describe('UsersChart', () => {
  let wrapper;

  const createComponent = ({ loading = false, data = {} } = {}) => {
    const $apollo = {
      queries: {
        counts: {
          loading,
        },
      },
    };

    wrapper = shallowMount(UsersChart, {
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

  const findMetricCard = () => wrapper.find(MetricCard);

  describe('while loading', () => {
    beforeEach(() => {
      createComponent({ loading: true });
    });

    it('displays the metric card with isLoading=true', () => {
      expect(findMetricCard().props('isLoading')).toBe(true);
    });
  });

  describe('with data', () => {
    beforeEach(() => {
      createComponent({ data: { counts: countsMockData } });
    });

    it('passes the counts data to the metric card', () => {
      expect(findMetricCard().props('metrics')).toEqual(countsMockData);
    });
  });
});
