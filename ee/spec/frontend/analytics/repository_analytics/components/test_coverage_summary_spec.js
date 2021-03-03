import { GlDeprecatedSkeletonLoading as GlSkeletonLoading } from '@gitlab/ui';
import { shallowMount, createLocalVue } from '@vue/test-utils';
import TestCoverageSummary from 'ee/analytics/repository_analytics/components/test_coverage_summary.vue';
import { extendedWrapper } from 'helpers/vue_test_utils_helper';
import MetricCard from '~/analytics/shared/components/metric_card.vue';

const localVue = createLocalVue();

describe('Test coverage table component', () => {
  let wrapper;

  const findProjectsWithTests = () => wrapper.find('.js-metric-card-item:nth-child(1) h3');
  const findAverageCoverage = () => wrapper.find('.js-metric-card-item:nth-child(2) h3');
  const findTotalCoverages = () => wrapper.find('.js-metric-card-item:nth-child(3) h3');
  const findGroupCoverageChart = () => wrapper.findByTestId('group-coverage-chart');
  const findChartLoadingState = () => wrapper.findByTestId('group-coverage-chart-loading');
  const findChartEmptyState = () => wrapper.findByTestId('group-coverage-chart-empty');
  const findLoadingState = () => wrapper.find(GlSkeletonLoading);

  const createComponent = ({ data = {} } = {}) => {
    wrapper = extendedWrapper(
      shallowMount(TestCoverageSummary, {
        localVue,
        data() {
          return {
            projectCount: null,
            averageCoverage: null,
            coverageCount: null,
            hasError: false,
            isLoading: false,
            ...data,
          };
        },
        mocks: {
          $apollo: {
            queries: {
              group: {
                query: jest.fn().mockResolvedValue(),
              },
            },
          },
        },
        stubs: {
          MetricCard,
        },
      }),
    );
  };

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
  });

  describe('when group code coverage is empty', () => {
    it('renders empty metrics', () => {
      createComponent();

      expect(findProjectsWithTests().text()).toBe('-');
      expect(findAverageCoverage().text()).toBe('-');
      expect(findTotalCoverages().text()).toBe('-');
    });

    it('renders empty chart state', () => {
      createComponent();

      expect(findChartEmptyState().exists()).toBe(true);
      expect(findGroupCoverageChart().exists()).toBe(false);
    });
  });

  describe('when query is loading', () => {
    it('renders loading state', () => {
      createComponent({ data: { isLoading: true } });

      expect(findLoadingState().exists()).toBe(true);
      expect(findChartLoadingState().exists()).toBe(true);
    });
  });

  describe('when group code coverage is available', () => {
    it('renders coverage metrics', () => {
      const projectCount = '5';
      const averageCoverage = '74.35';
      const coverageCount = '5';

      createComponent({
        data: {
          projectCount,
          averageCoverage,
          coverageCount,
        },
      });

      expect(findProjectsWithTests().text()).toBe(projectCount);
      expect(findAverageCoverage().text()).toBe(`${averageCoverage} %`);
      expect(findTotalCoverages().text()).toBe(coverageCount);
    });

    it('renders area chart with correct data', () => {
      createComponent({
        data: {
          groupCoverageChartData: [
            {
              name: 'test',
              data: [
                ['2020-01-10', 77.9],
                ['2020-01-11', 78.7],
                ['2020-01-12', 79.6],
              ],
            },
          ],
        },
      });

      expect(findGroupCoverageChart().exists()).toBe(true);
      expect(findGroupCoverageChart().props('data')).toMatchSnapshot();
    });

    it('formats the area chart labels correctly', () => {
      createComponent({
        data: {
          groupCoverageChartData: [
            {
              name: 'test',
              data: [
                ['2020-01-10', 77.9],
                ['2020-01-11', 78.7],
                ['2020-01-12', 79.6],
              ],
            },
          ],
        },
      });

      expect(findGroupCoverageChart().props('option').xAxis.axisLabel.formatter('2020-01-10')).toBe(
        'Jan 10',
      );
      expect(findGroupCoverageChart().props('option').yAxis.axisLabel.formatter(80)).toBe('80%');
    });
  });
});
