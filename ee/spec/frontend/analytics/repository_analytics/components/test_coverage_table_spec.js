import { mount, shallowMount, createLocalVue } from '@vue/test-utils';
import { useFakeDate } from 'helpers/fake_date';
import TestCoverageTable from 'ee/analytics/repository_analytics/components/test_coverage_table.vue';

const localVue = createLocalVue();

describe('Test coverage table component', () => {
  useFakeDate();
  let wrapper;

  const createComponent = (mountFn = shallowMount, data = {}) => {
    wrapper = mountFn(TestCoverageTable, {
      localVue,
      provide: {
        coverageTableEmptyStateSvgPath: '/empty.svg',
      },
      data() {
        return {
          coverageData: [],
          hasError: false,
          allProjectsSelected: false,
          selectedProjectIds: [],
          isLoading: false,
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
      const emptyState = wrapper.find('[data-testid="test-coverage-table-empty-state"]');

      expect(emptyState.exists()).toBe(true);
    });
  });

  describe('when query is loading', () => {
    it('renders loading state', () => {
      createComponent(shallowMount, { isLoading: true });
      const loadingState = wrapper.find('[data-testid="test-coverage-loading-state"');

      expect(loadingState.exists()).toBe(true);
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

      createComponent(mount, {
        coverageData: [
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
      });
      const coverageTable = wrapper.find('[data-testid="test-coverage-data-table"');
      const expectedName = wrapper.find(`[data-testid="${id}-name"`);
      const expectedAverage = wrapper.find(`[data-testid="${id}-average"`);
      const expectedCount = wrapper.find(`[data-testid="${id}-count"`);
      const expectedDate = wrapper.find(`[data-testid="${id}-date"`);

      expect(coverageTable.exists()).toBe(true);
      expect(expectedName.text()).toBe(name);
      expect(expectedAverage.text()).toBe(`${average}%`);
      expect(expectedCount.text()).toBe(count);
      expect(expectedDate.text()).toBe('1 day ago');
    });
  });
});
