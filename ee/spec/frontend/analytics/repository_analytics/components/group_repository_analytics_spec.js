import { shallowMount, createLocalVue } from '@vue/test-utils';
import { GlDropdown, GlDropdownItem, GlModal } from '@gitlab/ui';
import { useFakeDate } from 'helpers/fake_date';
import { getProjectIdQueryParams } from 'ee/analytics/repository_analytics/utils';
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

  const injectedProperties = {
    groupAnalyticsCoverageReportsPath: '/coverage.csv?ref_path=refs/heads/master',
    groupFullPath: 'gitlab-org',
  };
  const groupProjectsData = [{ id: 1, name: '1' }, { id: 2, name: '2' }];

  const createComponent = () => {
    wrapper = shallowMount(GroupRepositoryAnalytics, {
      localVue,
      data() {
        return {
          // Ensure that isSelected is set to false for each project so that every test is reset properly
          groupProjects: groupProjectsData.map(project => ({ ...project, isSelected: false })),
        };
      },
      provide: {
        ...injectedProperties,
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

    describe('when selecting a project', () => {
      // Due to the fake_date helper, we can always expect today's date to be 2020-07-06
      // and the default date 30 days ago to be 2020-06-06
      const groupAnalyticsCoverageReportsPathWithDates = `${injectedProperties.groupAnalyticsCoverageReportsPath}&start_date=2020-06-06&end_date=2020-07-06`;

      describe('with all projects selected', () => {
        beforeEach(() => {
          selectAllCodeCoverageProjects();
        });

        it('renders primary action as a link with all project IDs as parameters', () => {
          const projectIdParams = getProjectIdQueryParams(groupProjectsData);
          const expectedPath = `${groupAnalyticsCoverageReportsPathWithDates}&${projectIdParams}`;

          expect(findCodeCoverageDownloadButton().attributes('href')).toBe(expectedPath);
        });
      });

      describe('with one project selected', () => {
        beforeEach(() => {
          selectCodeCoverageProjectById(groupProjectsData[0].id);
        });

        it('renders primary action as a link with one project ID as a parameter', () => {
          const expectedPath = `${groupAnalyticsCoverageReportsPathWithDates}&project_ids=${groupProjectsData[0].id}`;

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
    });

    describe('when selecting a date range', () => {
      const projectIdParams = '&project_ids=1,2';

      it.each`
        date  | expected
        ${7}  | ${`${injectedProperties.groupAnalyticsCoverageReportsPath}&start_date=2020-06-29&end_date=2020-07-06${projectIdParams}`}
        ${14} | ${`${injectedProperties.groupAnalyticsCoverageReportsPath}&start_date=2020-06-22&end_date=2020-07-06${projectIdParams}`}
        ${30} | ${`${injectedProperties.groupAnalyticsCoverageReportsPath}&start_date=2020-06-06&end_date=2020-07-06${projectIdParams}`}
        ${60} | ${`${injectedProperties.groupAnalyticsCoverageReportsPath}&start_date=2020-05-07&end_date=2020-07-06${projectIdParams}`}
        ${90} | ${`${injectedProperties.groupAnalyticsCoverageReportsPath}&start_date=2020-04-07&end_date=2020-07-06${projectIdParams}`}
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
