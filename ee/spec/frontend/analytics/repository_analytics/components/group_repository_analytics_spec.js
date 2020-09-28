import { shallowMount, createLocalVue } from '@vue/test-utils';
import {
  GlAlert,
  GlDropdown,
  GlDropdownItem,
  GlIntersectionObserver,
  GlLoadingIcon,
  GlModal,
} from '@gitlab/ui';
import { useFakeDate } from 'helpers/fake_date';
import GroupRepositoryAnalytics from 'ee/analytics/repository_analytics/components/group_repository_analytics.vue';

const localVue = createLocalVue();

describe('Group repository analytics app', () => {
  useFakeDate();
  let wrapper;

  const findCodeCoverageModalButton = () =>
    wrapper.find('[data-testid="group-code-coverage-modal-button"]');
  const openCodeCoverageModal = () => {
    findCodeCoverageModalButton().vm.$emit('click');
  };
  const findCodeCoverageDownloadButton = () =>
    wrapper.find('[data-testid="group-code-coverage-download-button"]');
  const selectAllCodeCoverageProjects = () =>
    wrapper
      .find('[data-testid="group-code-coverage-download-select-all-projects"]')
      .trigger('click');
  const selectCodeCoverageProjectById = id =>
    wrapper
      .find(`[data-testid="group-code-coverage-download-select-project-${id}"]`)
      .trigger('click');
  const findIntersectionObserver = () => wrapper.find(GlIntersectionObserver);
  const findLoadingIcon = () => wrapper.find(GlLoadingIcon);
  const findAlert = () => wrapper.find(GlAlert);

  const injectedProperties = {
    groupAnalyticsCoverageReportsPath: '/coverage.csv?ref_path=refs/heads/master',
    groupFullPath: 'gitlab-org',
  };
  const groupProjectsData = [{ id: 1, name: '1' }, { id: 2, name: '2' }];

  const createComponent = ({ data = {}, apolloGroupProjects = {} } = {}) => {
    wrapper = shallowMount(GroupRepositoryAnalytics, {
      localVue,
      data() {
        return {
          // Ensure that isSelected is set to false for each project so that every test is reset properly
          groupProjects: groupProjectsData.map(project => ({ ...project, isSelected: false })),
          hasError: false,
          projectsPageInfo: {
            hasNextPage: false,
            endCursor: null,
          },
          ...data,
        };
      },
      provide: {
        ...injectedProperties,
      },
      mocks: {
        $apollo: {
          queries: {
            groupProjects: {
              fetchMore: jest.fn().mockResolvedValue(),
              ...apolloGroupProjects,
            },
          },
        },
      },
      stubs: { GlDropdown, GlDropdownItem, GlModal },
    });
  };

  beforeEach(() => {
    createComponent();
  });

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
  });

  it('renders button to open download code coverage modal', () => {
    expect(findCodeCoverageModalButton().exists()).toBe(true);
  });

  describe('when download code coverage modal is displayed', () => {
    beforeEach(() => {
      openCodeCoverageModal();
    });

    describe('when there is an error fetching the projects', () => {
      beforeEach(() => {
        createComponent({ data: { hasError: true } });
      });

      it('displays an alert for the failed query', () => {
        expect(findAlert().exists()).toBe(true);
      });
    });

    describe('when selecting a project', () => {
      // Due to the fake_date helper, we can always expect today's date to be 2020-07-06
      // and the default date 30 days ago to be 2020-06-06
      const groupAnalyticsCoverageReportsPathWithDates = `${injectedProperties.groupAnalyticsCoverageReportsPath}&start_date=2020-06-06&end_date=2020-07-06`;

      describe('with all projects selected', () => {
        beforeEach(() => {
          selectAllCodeCoverageProjects();
        });

        it('renders primary action as a link with no project_ids param', () => {
          expect(findCodeCoverageDownloadButton().attributes('href')).toBe(
            groupAnalyticsCoverageReportsPathWithDates,
          );
        });
      });

      describe('with two or more projects selected without selecting all projects', () => {
        beforeEach(() => {
          selectCodeCoverageProjectById(groupProjectsData[0].id);
          selectCodeCoverageProjectById(groupProjectsData[1].id);
        });

        it('renders primary action as a link with two project IDs as parameters', () => {
          const projectIdsQueryParam = `project_ids%5B%5D=${groupProjectsData[0].id}&project_ids%5B%5D=${groupProjectsData[1].id}`;
          const expectedPath = `${groupAnalyticsCoverageReportsPathWithDates}&${projectIdsQueryParam}`;

          expect(findCodeCoverageDownloadButton().attributes('href')).toBe(expectedPath);
        });
      });

      describe('with one project selected', () => {
        beforeEach(() => {
          selectCodeCoverageProjectById(groupProjectsData[0].id);
        });

        it('renders primary action as a link with one project ID as a parameter', () => {
          const projectIdsQueryParam = `project_ids%5B%5D=${groupProjectsData[0].id}`;
          const expectedPath = `${groupAnalyticsCoverageReportsPathWithDates}&${projectIdsQueryParam}`;

          expect(findCodeCoverageDownloadButton().attributes('href')).toBe(expectedPath);
        });
      });

      describe('with no projects selected', () => {
        beforeEach(() => {
          // Select a project to make sure that "Select all" is unchecked
          selectCodeCoverageProjectById(groupProjectsData[0].id);
          // Click the same project again to unselect it
          selectCodeCoverageProjectById(groupProjectsData[0].id);
        });

        it('renders a disabled primary action button', () => {
          expect(findCodeCoverageDownloadButton().attributes('disabled')).toBe('true');
        });
      });

      describe('when there is only one page of projects', () => {
        it('should not render the intersection observer component', () => {
          expect(findIntersectionObserver().exists()).toBe(false);
        });
      });

      describe('when there is more than a page of projects', () => {
        beforeEach(() => {
          createComponent({ data: { projectsPageInfo: { hasNextPage: true } } });
        });

        it('should render the intersection observer component', () => {
          expect(findIntersectionObserver().exists()).toBe(true);
        });

        describe('when the intersection observer component appears in view', () => {
          beforeEach(() => {
            jest
              .spyOn(wrapper.vm.$apollo.queries.groupProjects, 'fetchMore')
              .mockImplementation(jest.fn().mockResolvedValue());

            findIntersectionObserver().vm.$emit('appear');
            return wrapper.vm.$nextTick();
          });

          it('makes a query to fetch more projects', () => {
            expect(wrapper.vm.$apollo.queries.groupProjects.fetchMore).toHaveBeenCalledTimes(1);
          });

          describe('when the fetchMore query throws an error', () => {
            beforeEach(() => {
              jest
                .spyOn(wrapper.vm.$apollo.queries.groupProjects, 'fetchMore')
                .mockImplementation(jest.fn().mockRejectedValue());

              findIntersectionObserver().vm.$emit('appear');
              return wrapper.vm.$nextTick();
            });

            it('displays an alert for the failed query', () => {
              expect(findAlert().exists()).toBe(true);
            });
          });
        });

        describe('when a query is loading a new page of projects', () => {
          beforeEach(() => {
            createComponent({
              data: { projectsPageInfo: { hasNextPage: true } },
              apolloGroupProjects: {
                loading: true,
              },
            });
          });

          it('should render the loading spinner', () => {
            expect(findLoadingIcon().exists()).toBe(true);
          });
        });
      });
    });

    describe('when selecting a date range', () => {
      it.each`
        date  | expected
        ${7}  | ${`${injectedProperties.groupAnalyticsCoverageReportsPath}&start_date=2020-06-29&end_date=2020-07-06`}
        ${14} | ${`${injectedProperties.groupAnalyticsCoverageReportsPath}&start_date=2020-06-22&end_date=2020-07-06`}
        ${30} | ${`${injectedProperties.groupAnalyticsCoverageReportsPath}&start_date=2020-06-06&end_date=2020-07-06`}
        ${60} | ${`${injectedProperties.groupAnalyticsCoverageReportsPath}&start_date=2020-05-07&end_date=2020-07-06`}
        ${90} | ${`${injectedProperties.groupAnalyticsCoverageReportsPath}&start_date=2020-04-07&end_date=2020-07-06`}
      `(
        'updates CSV path to have the start date be $date days before today',
        ({ date, expected }) => {
          wrapper
            .find(`[data-testid="group-code-coverage-download-select-date-${date}"]`)
            .vm.$emit('click');

          return wrapper.vm.$nextTick().then(() => {
            expect(findCodeCoverageDownloadButton().attributes('href')).toBe(expected);
          });
        },
      );
    });
  });
});
