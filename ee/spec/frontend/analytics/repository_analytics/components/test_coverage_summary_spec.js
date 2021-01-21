import { GlDeprecatedSkeletonLoading as GlSkeletonLoading } from '@gitlab/ui';
import { mount, createLocalVue } from '@vue/test-utils';
import VueApollo from 'vue-apollo';
import TestCoverageSummary from 'ee/analytics/repository_analytics/components/test_coverage_summary.vue';
import getGroupTestCoverage from 'ee/analytics/repository_analytics/graphql/queries/get_group_test_coverage.query.graphql';
import { useFakeDate } from 'helpers/fake_date';
import createMockApollo from 'helpers/mock_apollo_helper';
import waitForPromises from 'helpers/wait_for_promises';

const localVue = createLocalVue();

describe('Test coverage table component', () => {
  useFakeDate();
  let wrapper;
  let fakeApollo;

  const findProjectsWithTests = () => wrapper.find('.js-metric-card-item:nth-child(1) h3');
  const findAverageCoverage = () => wrapper.find('.js-metric-card-item:nth-child(2) h3');
  const findTotalCoverages = () => wrapper.find('.js-metric-card-item:nth-child(3) h3');
  const findLoadingState = () => wrapper.find(GlSkeletonLoading);

  const createComponent = ({ data = {} } = {}, withApollo = false) => {
    fakeApollo = createMockApollo([[getGroupTestCoverage, jest.fn().mockResolvedValue()]]);

    const props = {
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
    };
    if (withApollo) {
      localVue.use(VueApollo);
      props.apolloProvider = fakeApollo;
    } else {
      props.mocks = {
        $apollo: {
          queries: {
            group: {
              query: jest.fn().mockResolvedValue(),
            },
          },
        },
      };
    }

    wrapper = mount(TestCoverageSummary, props);
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
  });

  describe('when query is loading', () => {
    it('renders loading state', () => {
      createComponent({ data: { isLoading: true } });

      expect(findLoadingState().exists()).toBe(true);
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
  });

  describe('when group has no coverage', () => {
    it('renders empty metrics', async () => {
      createComponent({
        withApollo: true,
        data: {},
        queryData: {
          data: {
            group: {
              codeCoverageActivities: {
                nodes: [],
              },
            },
          },
        },
      });
      jest.runOnlyPendingTimers();
      await waitForPromises();

      expect(findProjectsWithTests().text()).toBe('-');
      expect(findAverageCoverage().text()).toBe('-');
      expect(findTotalCoverages().text()).toBe('-');
    });
  });
});
