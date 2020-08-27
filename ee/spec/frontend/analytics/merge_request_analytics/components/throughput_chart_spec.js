import { shallowMount } from '@vue/test-utils';
import { GlAlert } from '@gitlab/ui';
import { GlAreaChart } from '@gitlab/ui/dist/charts';
import ThroughputChart from 'ee/analytics/merge_request_analytics/components/throughput_chart.vue';
import { THROUGHPUT_CHART_STRINGS } from 'ee/analytics/merge_request_analytics/constants';
import ChartSkeletonLoader from '~/vue_shared/components/resizable_chart/skeleton_loader.vue';
import { throughputChartData, startDate, endDate, fullPath } from '../mock_data';

describe('ThroughputChart', () => {
  let wrapper;

  const displaysComponent = (component, visible) => {
    const element = wrapper.find(component);

    expect(element.exists()).toBe(visible);
  };

  const createComponent = ({ loading = false, data = {} } = {}) => {
    const $apollo = {
      queries: {
        throughputChartData: {
          loading,
        },
      },
    };

    wrapper = shallowMount(ThroughputChart, {
      mocks: { $apollo },
      provide: {
        fullPath,
      },
      props: {
        startDate,
        endDate,
      },
    });

    wrapper.setData(data);
  };

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
  });

  describe('default state', () => {
    beforeEach(() => {
      createComponent();
    });

    it('displays the chart title', () => {
      const chartTitle = wrapper.find('[data-testid="chartTitle"').text();

      expect(chartTitle).toBe(THROUGHPUT_CHART_STRINGS.CHART_TITLE);
    });

    it('displays the chart description', () => {
      const chartDescription = wrapper.find('[data-testid="chartDescription"').text();

      expect(chartDescription).toBe(THROUGHPUT_CHART_STRINGS.CHART_DESCRIPTION);
    });

    it('displays an empty state message when there is no data', () => {
      const alert = wrapper.find(GlAlert);

      expect(alert.exists()).toBe(true);
      expect(alert.text()).toBe(THROUGHPUT_CHART_STRINGS.NO_DATA);
    });

    it('does not display a skeleton loader', () => {
      displaysComponent(ChartSkeletonLoader, false);
    });

    it('does not display the chart', () => {
      displaysComponent(GlAreaChart, false);
    });
  });

  describe('while loading', () => {
    beforeEach(() => {
      createComponent({ loading: true });
    });

    it('displays a skeleton loader', () => {
      displaysComponent(ChartSkeletonLoader, true);
    });

    it('does not display the chart', () => {
      displaysComponent(GlAreaChart, false);
    });

    it('does not display a no data message', () => {
      displaysComponent(GlAlert, false);
    });
  });

  describe('with data', () => {
    beforeEach(() => {
      createComponent({ data: { throughputChartData } });
    });

    it('displays the chart', () => {
      displaysComponent(GlAreaChart, true);
    });

    it('does not display the skeleton loader', () => {
      displaysComponent(ChartSkeletonLoader, false);
    });

    it('does not display a no data message', () => {
      displaysComponent(GlAlert, false);
    });
  });

  describe('with errors', () => {
    beforeEach(() => {
      createComponent({ data: { hasError: true } });
    });

    it('does not display the chart', () => {
      displaysComponent(GlAreaChart, false);
    });

    it('does not display the skeleton loader', () => {
      displaysComponent(ChartSkeletonLoader, false);
    });

    it('displays an error message', () => {
      const alert = wrapper.find(GlAlert);

      expect(alert.exists()).toBe(true);
      expect(alert.text()).toBe(THROUGHPUT_CHART_STRINGS.ERROR_FETCHING_DATA);
    });
  });
});
