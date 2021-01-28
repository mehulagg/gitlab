import { mount, shallowMount, createLocalVue } from '@vue/test-utils';
import VueApollo from 'vue-apollo';
import TestCoverageTable from 'ee/analytics/repository_analytics/components/test_coverage_table.vue';
import getGroupProjects from 'ee/analytics/repository_analytics/graphql/queries/get_group_projects.query.graphql';
import getProjectsTestCoverage from 'ee/analytics/repository_analytics/graphql/queries/get_projects_test_coverage.query.graphql';
import { useFakeDate } from 'helpers/fake_date';
import createMockApollo from 'helpers/mock_apollo_helper';
import waitForPromises from 'helpers/wait_for_promises';
import Api from '~/api';

jest.mock('~/api.js');

const localVue = createLocalVue();

describe('Test coverage table component', () => {
  useFakeDate();
  let wrapper;
  let fakeApollo;

  const findEmptyState = () => wrapper.find('[data-testid="test-coverage-table-empty-state"]');
  const findLoadingState = () => wrapper.find('[data-testid="test-coverage-loading-state"');
  const findTable = () => wrapper.find('[data-testid="test-coverage-data-table"');
  const findTableRows = () => findTable().findAll('tbody tr');
  const findProjectNameById = (id) => wrapper.find(`[data-testid="${id}-name"`);
  const findProjectAverageById = (id) => wrapper.find(`[data-testid="${id}-average"`);
  const findProjectCountById = (id) => wrapper.find(`[data-testid="${id}-count"`);
  const findProjectDateById = (id) => wrapper.find(`[data-testid="${id}-date"`);

  const mockQueryDataNode = {
    fullPath: 'test/test',
    name: 'test',
    id: 1,
    repository: {
      rootRef: 'master',
    },
    codeCoverageSummary: {
      averageCoverage: '1.45',
      coverageCount: '1',
      lastUpdatedOn: new Date().toISOString(),
    },
  };

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
    glFeatures = {},
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
      createComponent({ data: { isLoading: true } });

      expect(findLoadingState().exists()).toBe(true);
    });
  });

  describe('when code coverage is available', () => {
    it('renders coverage table', () => {
      const fullPath = 'gitlab-org/gitlab';
      const id = 'gid://gitlab/Project/1';
      const name = 'GitLab';
      const rootRef = 'master';
      const averageCoverage = '74.35';
      const coverageCount = '5';
      const yesterday = new Date();
      yesterday.setDate(yesterday.getDate() - 1);

      createComponent({
        data: {
          allCoverageData: [
            {
              fullPath,
              id,
              name,
              repository: {
                rootRef,
              },
              codeCoveragePath: '#',
              codeCoverageSummary: {
                averageCoverage,
                coverageCount,
                lastUpdatedOn: yesterday.toISOString(),
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

    it('sorts the table by the most recently updated report', () => {
      const today = new Date();
      const yesterday = new Date();
      yesterday.setDate(yesterday.getDate() - 1);
      const allCoverageData = [
        {
          ...mockQueryDataNode,
          name: 'should be last',
          codeCoverageSummary: {
            ...mockQueryDataNode.codeCoverageSummary,
            lastUpdatedOn: yesterday.toISOString(),
          },
        },
        {
          ...mockQueryDataNode,
          name: 'should be first',
          id: 2,
          codeCoverageSummary: {
            ...mockQueryDataNode.codeCoverageSummary,
            lastUpdatedOn: today.toISOString(),
          },
        },
      ];
      createComponent({
        data: {
          allCoverageData,
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
      const id = 1;
      const fullPath = 'test/test';
      const rootRef = 'master';
      const expectedPath = `/${fullPath}/-/graphs/${rootRef}/charts`;
      createComponentWithApollo({
        data: {
          projectIds: { [id]: true },
        },
        queryData: {
          data: {
            projects: {
              nodes: [
                {
                  ...mockQueryDataNode,
                  fullPath,
                  id,
                  repository: {
                    rootRef,
                  },
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
      expect(findProjectNameById(id).attributes('href')).toBe(expectedPath);
    });

    describe('with usage metrics', () => {
      describe('with :usageDataITestingGroupCodeCoverageProjectClickTotal enabled', () => {
        it('tracks i_testing_group_code_coverage_project_click_total metric', async () => {
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
                      ...mockQueryDataNode,
                      id,
                    },
                  ],
                },
              },
            },
            mountFn: mount,
            glFeatures: { usageDataITestingGroupCodeCoverageProjectClickTotal: true },
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
                      ...mockQueryDataNode,
                      id,
                    },
                  ],
                },
              },
            },
            mountFn: mount,
            glFeatures: { usageDataITestingGroupCodeCoverageProjectClickTotal: false },
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

  describe('when selected project has no coverage', () => {
    it('does not render the table', async () => {
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
                  ...mockQueryDataNode,
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

      expect(findTable().exists()).toBe(false);
    });
  });
});
