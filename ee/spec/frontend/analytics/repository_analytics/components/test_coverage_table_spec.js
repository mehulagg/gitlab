import VueApollo from 'vue-apollo';
import { mount, shallowMount, createLocalVue } from '@vue/test-utils';
import { useFakeDate } from 'helpers/fake_date';
import createMockApollo from 'jest/helpers/mock_apollo_helper';
import waitForPromises from 'jest/helpers/wait_for_promises';
import TestCoverageTable from 'ee/analytics/repository_analytics/components/test_coverage_table.vue';
import getProjectsTestCoverage from 'ee/analytics/repository_analytics/graphql/queries/get_projects_test_coverage.query.graphql';
import getGroupProjects from 'ee/analytics/repository_analytics/graphql/queries/get_group_projects.query.graphql';

const localVue = createLocalVue();

describe('Test coverage table component', () => {
  useFakeDate();
  let wrapper;
  let fakeApollo;

  const findEmptyState = () => wrapper.find('[data-testid="test-coverage-table-empty-state"]');
  const findLoadingState = () => wrapper.find('[data-testid="test-coverage-loading-state"');
  const findTable = () => wrapper.find('[data-testid="test-coverage-data-table"');
  const findProjectNameById = id => wrapper.find(`[data-testid="${id}-name"`);
  const findProjectAverageById = id => wrapper.find(`[data-testid="${id}-average"`);
  const findProjectCountById = id => wrapper.find(`[data-testid="${id}-count"`);
  const findProjectDateById = id => wrapper.find(`[data-testid="${id}-date"`);

  const createComponent = ({ data = {}, mountFn = shallowMount } = {}) => {
    wrapper = mountFn(TestCoverageTable, {
      localVue,
      data() {
        return {
          allCoverageData: [],
          allProjectsSelected: false,
          hasError: false,
          isLoading: false,
          projectIds: {},
          ...data,
        };
      },
      mocks: {
        $apollo: {
          queries: {
            projects: {
              query: jest.fn().mockResolvedValue(),
            },
          },
        },
      },
    });
  };

  const createComponentWithApollo = ({
    data = {},
    mountFn = shallowMount,
    queryData = {},
  } = {}) => {
    localVue.use(VueApollo);
    fakeApollo = createMockApollo([
      [getGroupProjects, jest.fn().mockResolvedValue()],
      [getProjectsTestCoverage, jest.fn().mockResolvedValue(queryData)],
    ]);

    wrapper = mountFn(TestCoverageTable, {
      localVue,
      data() {
        return {
          allCoverageData: [],
          allProjectsSelected: false,
          hasError: false,
          isLoading: false,
          projectIds: {},
          ...data,
        };
      },
      apolloProvider: fakeApollo,
    });
  };

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
  });

  describe('when code coverage is empty', () => {
    it('renders empty state', () => {
      createComponent();
      expect(findEmptyState().exists()).toBe(true);
    });
  });

  describe('when query is loading', () => {
    it('renders loading state', () => {
      createComponent({ data: { isLoading: true } });

      expect(findLoadingState().exists()).toBe(true);
    });
  });

  describe('when code coverage is available', () => {
    it('renders coverage table', () => {
      const id = 'gid://gitlab/Project/1';
      const name = 'GitLab';
      const averageCoverage = '74.35';
      const coverageCount = '5';
      const yesterday = new Date();
      yesterday.setDate(yesterday.getDate() - 1);

      createComponent({
        data: {
          allCoverageData: [
            {
              id,
              name,
              codeCoverageSummary: {
                averageCoverage,
                coverageCount,
                lastUpdatedAt: yesterday.toISOString(),
              },
            },
          ],
          projectIds: {
            [id]: true,
          },
        },
        mountFn: mount,
      });

      expect(findTable().exists()).toBe(true);
      expect(findProjectNameById(id).text()).toBe(name);
      expect(findProjectAverageById(id).text()).toBe(`${averageCoverage}%`);
      expect(findProjectCountById(id).text()).toBe(coverageCount);
      expect(findProjectDateById(id).text()).toBe('1 day ago');
    });
  });

  describe('when selected project has no coverage', () => {
    it('sets coverage to default values', async () => {
      const name = 'test';
      const id = 1;
      createComponentWithApollo({
        data: {
          projectIds: { [id]: true },
        },
        queryData: {
          data: {
            projects: {
              nodes: [
                {
                  name,
                  id,
                  codeCoverageSummary: null,
                },
              ],
            },
          },
        },
        mountFn: mount,
      });
      jest.runOnlyPendingTimers();
      await waitForPromises();

      expect(findTable().exists()).toBe(true);
      expect(findProjectNameById(id).text()).toBe(name);
      expect(findProjectAverageById(id).text()).toBe('0.00%');
      expect(findProjectCountById(id).text()).toBe('0');
      expect(findProjectDateById(id).text()).toBe('just now');
    });
  });
});
