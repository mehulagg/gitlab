import { mount, shallowMount, createLocalVue } from '@vue/test-utils';
import { useFakeDate } from 'helpers/fake_date';
import TestCoverageTable from 'ee/analytics/repository_analytics/components/test_coverage_table.vue';

const localVue = createLocalVue();

describe('Test coverage table component', () => {
  useFakeDate();
  let wrapper;

  const findEmptyState = () => wrapper.find('[data-testid="test-coverage-table-empty-state"]');
  const findLoadingState = () => wrapper.find('[data-testid="test-coverage-loading-state"');
  const findTable = () => wrapper.find('[data-testid="test-coverage-data-table"');
  const findProjectNameById = id => wrapper.find(`[data-testid="${id}-name"`);
  const findProjectAverageById = id => wrapper.find(`[data-testid="${id}-average"`);
  const findProjectCountById = id => wrapper.find(`[data-testid="${id}-count"`);
  const findProjectDateById = id => wrapper.find(`[data-testid="${id}-date"`);

  const createComponent = (data = {}, mountFn = shallowMount) => {
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
            coverageData: {
              query: jest.fn().mockResolvedValue(),
            },
          },
        },
      },
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
      createComponent({ isLoading: true });

      expect(findLoadingState().exists()).toBe(true);
    });
  });

  describe('when code coverage is available', () => {
    it('renders coverage table', () => {
      const id = 'gid://gitlab/Project/1';
      const name = 'GitLab';
      const average = '74.35';
      const count = '5';
      const yesterday = new Date();
      yesterday.setDate(yesterday.getDate() - 1);

      createComponent(
        {
          allCoverageData: [
            {
              id,
              name,
              codeCoverage: {
                average,
                count,
                lastUpdatedAt: yesterday.toISOString(),
              },
            },
          ],
          projectIds: {
            [id]: true,
          },
        },
        mount,
      );

      expect(findTable().exists()).toBe(true);
      expect(findProjectNameById(id).text()).toBe(name);
      expect(findProjectAverageById(id).text()).toBe(`${average}%`);
      expect(findProjectCountById(id).text()).toBe(count);
      expect(findProjectDateById(id).text()).toBe('1 day ago');
    });
  });
});
