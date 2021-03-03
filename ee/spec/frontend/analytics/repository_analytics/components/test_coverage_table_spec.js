import { mount, shallowMount, createLocalVue } from '@vue/test-utils';
import VueApollo from 'vue-apollo';
import TestCoverageTable from 'ee/analytics/repository_analytics/components/test_coverage_table.vue';
import getGroupProjects from 'ee/analytics/repository_analytics/graphql/queries/get_group_projects.query.graphql';
import getProjectsTestCoverage from 'ee/analytics/repository_analytics/graphql/queries/get_projects_test_coverage.query.graphql';
import createMockApollo from 'helpers/mock_apollo_helper';
import waitForPromises from 'helpers/wait_for_promises';
import Api from '~/api';
import { getTimeago } from '~/lib/utils/datetime_utility';
import { defaultTestCoverageTable, projects } from '../mock_data';

jest.mock('~/api.js');

const localVue = createLocalVue();

describe('Test coverage table component', () => {
  let wrapper;
  const timeago = getTimeago();

  const findEmptyState = () => wrapper.find('[data-testid="test-coverage-table-empty-state"]');
  const findLoadingState = () => wrapper.find('[data-testid="test-coverage-loading-state"');
  const findTable = () => wrapper.find('[data-testid="test-coverage-data-table"');
  const findTableRows = () => findTable().findAll('tbody tr');
  const findProjectNameById = (id) => wrapper.find(`[data-testid="${id}-name"`);
  const findProjectAverageById = (id) => wrapper.find(`[data-testid="${id}-average"`);
  const findProjectCountById = (id) => wrapper.find(`[data-testid="${id}-count"`);
  const findProjectDateById = (id) => wrapper.find(`[data-testid="${id}-date"`);

  const createMockApolloProvider = () => {
    localVue.use(VueApollo);

    return createMockApollo([
      [getGroupProjects, jest.fn().mockResolvedValue()],
      [
        getProjectsTestCoverage,
        jest.fn().mockResolvedValue({
          data: { projects: { nodes: projects } },
        }),
      ],
    ]);
  };

  const createComponent = ({
    glFeatures = {},
    mockApollo,
    mockData = {},
    mountFn = shallowMount,
  } = {}) => {
    wrapper = mountFn(TestCoverageTable, {
      localVue,
      data() {
        return {
          ...defaultTestCoverageTable,
          ...mockData,
        };
      },
      apolloProvider: mockApollo,
      provide: {
        glFeatures,
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
      createComponent({ mockData: { isLoading: true } });

      expect(findLoadingState().exists()).toBe(true);
    });
  });

  describe('when code coverage is available', () => {
    it('renders coverage table', () => {
      const {
        id,
        name,
        codeCoverageSummary: { averageCoverage, coverageCount, lastUpdatedOn },
      } = projects[0];
      createComponent({
        mockData: {
          allCoverageData: projects,
          projectIds: { [id]: true },
        },
        mountFn: mount,
      });

      expect(findTable().exists()).toBe(true);
      expect(findProjectNameById(id).text()).toBe(name);
      expect(findProjectAverageById(id).text()).toBe(`${averageCoverage}%`);
      expect(findProjectCountById(id).text()).toBe(coverageCount);
      expect(findProjectDateById(id).text()).toBe(timeago.format(lastUpdatedOn));
    });

    it('sorts the table by the most recently updated report', () => {
      const project = projects[0];
      const today = '2021-01-30T20:34:14.302Z';
      const yesterday = '2021-01-29T20:34:14.302Z';
      createComponent({
        mockData: {
          allCoverageData: [
            {
              ...project,
              name: 'should be last',
              id: 1,
              codeCoverageSummary: {
                ...project.codeCoverageSummary,
                lastUpdatedOn: yesterday,
              },
            },
            {
              ...project,
              name: 'should be first',
              id: 2,
              codeCoverageSummary: {
                ...project.codeCoverageSummary,
                lastUpdatedOn: today,
              },
            },
          ],
          projectIds: {
            1: true,
            2: true,
          },
        },
        mountFn: mount,
      });

      expect(findTable().exists()).toBe(true);
      expect(findTableRows().at(0).text()).toContain('should be first');
      expect(findTableRows().at(1).text()).toContain('should be last');
    });

    it('renders the correct link', async () => {
      const {
        id,
        fullPath,
        repository: { rootRef },
      } = projects[0];
      const expectedPath = `/${fullPath}/-/graphs/${rootRef}/charts`;
      createComponent({
        mockApollo: createMockApolloProvider(),
        mockData: {
          projectIds: { [id]: true },
        },
        mountFn: mount,
      });
      // We have to wait for apollo to make the mock query and fill the table before
      // we can click on the project link inside the table. Neither `runOnlyPendingTimers`
      // nor `waitForPromises` work on their own to accomplish this.
      jest.runOnlyPendingTimers();
      await waitForPromises();

      expect(findTable().exists()).toBe(true);
      expect(findProjectNameById(id).attributes('href')).toBe(expectedPath);
    });

    describe('with usage metrics', () => {
      describe('with :usageDataITestingGroupCodeCoverageProjectClickTotal enabled', () => {
        it('tracks i_testing_group_code_coverage_project_click_total metric', async () => {
          const { id } = projects[0];
          createComponent({
            glFeatures: { usageDataITestingGroupCodeCoverageProjectClickTotal: true },
            mockApollo: createMockApolloProvider(),
            mockData: {
              projectIds: { [id]: true },
            },
            mountFn: mount,
          });
          // We have to wait for apollo to make the mock query and fill the table before
          // we can click on the project link inside the table. Neither `runOnlyPendingTimers`
          // nor `waitForPromises` work on their own to accomplish this.
          jest.runOnlyPendingTimers();
          await waitForPromises();
          findProjectNameById(id).trigger('click');

          expect(Api.trackRedisHllUserEvent).toHaveBeenCalledTimes(1);
          expect(Api.trackRedisHllUserEvent).toHaveBeenCalledWith(
            wrapper.vm.$options.usagePingProjectEvent,
          );
        });
      });

      describe('with :usageDataITestingGroupCodeCoverageProjectClickTotal disabled', () => {
        it('does not track i_testing_group_code_coverage_project_click_total metric', async () => {
          const { id } = projects[0];
          createComponent({
            glFeatures: { usageDataITestingGroupCodeCoverageProjectClickTotal: false },
            mockApollo: createMockApolloProvider(),
            mockData: {
              projectIds: { [id]: true },
            },
            mountFn: mount,
          });
          // We have to wait for apollo to make the mock query and fill the table before
          // we can click on the project link inside the table. Neither `runOnlyPendingTimers`
          // nor `waitForPromises` work on their own to accomplish this.
          jest.runOnlyPendingTimers();
          await waitForPromises();
          findProjectNameById(id).trigger('click');

          expect(Api.trackRedisHllUserEvent).not.toHaveBeenCalled();
        });
      });
    });
  });
});
