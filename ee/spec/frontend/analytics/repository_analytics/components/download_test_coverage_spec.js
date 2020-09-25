import { shallowMount, createLocalVue } from '@vue/test-utils';
import { GlAlert, GlDropdown, GlDropdownItem, GlModal } from '@gitlab/ui';
import { useFakeDate } from 'helpers/fake_date';
import DownloadTestCoverage from 'ee/analytics/repository_analytics/components/download_test_coverage.vue';
import SelectProjectsDropdown from 'ee/analytics/repository_analytics/components/select_projects_dropdown.vue';

const localVue = createLocalVue();

describe('Download test coverage component', () => {
  useFakeDate();
  let wrapper;

  const findCodeCoverageModalButton = () =>
    wrapper.find('[data-testid="group-code-coverage-modal-button"]');
  const openCodeCoverageModal = () => {
    findCodeCoverageModalButton().vm.$emit('click');
  };
  const findCodeCoverageDownloadButton = () =>
    wrapper.find('[data-testid="group-code-coverage-download-button"]');
  const clickSelectAllProjectsButton = () =>
    wrapper
      .find('[data-testid="group-code-coverage-select-all-projects-button"]')
      .vm.$emit('click');
  const findAlert = () => wrapper.find(GlAlert);

  const defaultProps = {
    groupAnalyticsCoverageReportsPath: '/coverage.csv?ref_path=refs/heads/master',
    groupFullPath: 'gitlab-org',
  };

  const createComponent = (data = {}) => {
    wrapper = shallowMount(DownloadTestCoverage, {
      localVue,
      data() {
        return {
          hasError: false,
          ...data,
        };
      },
      propsData: {
        ...defaultProps,
      },
      stubs: { GlDropdown, GlDropdownItem, GlModal, SelectProjectsDropdown },
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
        createComponent({ hasError: true });
      });

      it('displays an alert for the failed query', () => {
        expect(findAlert().exists()).toBe(true);
      });
    });

    describe('when selecting a project', () => {
      // Due to the fake_date helper, we can always expect today's date to be 2020-07-06
      // and the default date 30 days ago to be 2020-06-06
      const groupAnalyticsCoverageReportsPathWithDates = `${defaultProps.groupAnalyticsCoverageReportsPath}&start_date=2020-06-06&end_date=2020-07-06`;

      describe('with all projects selected', () => {
        beforeEach(() => {
          createComponent({ allProjectsSelected: true });
        });

        it('renders primary action as a link with no project_ids param', () => {
          expect(findCodeCoverageDownloadButton().attributes('href')).toBe(
            groupAnalyticsCoverageReportsPathWithDates,
          );
        });
      });

      describe('with two or more projects selected without selecting all projects', () => {
        beforeEach(() => {
          createComponent({ allProjectsSelected: false, selectedProjectIds: [1, 2] });
        });

        it('renders primary action as a link with two project IDs as parameters', () => {
          const projectIdsQueryParam = `project_ids%5B%5D=1&project_ids%5B%5D=2`;
          const expectedPath = `${groupAnalyticsCoverageReportsPathWithDates}&${projectIdsQueryParam}`;

          expect(findCodeCoverageDownloadButton().attributes('href')).toBe(expectedPath);
        });
      });

      describe('with one project selected', () => {
        beforeEach(() => {
          createComponent({ allProjectsSelected: false, selectedProjectIds: [1] });
        });

        it('renders primary action as a link with one project ID as a parameter', () => {
          const projectIdsQueryParam = `project_ids%5B%5D=1`;
          const expectedPath = `${groupAnalyticsCoverageReportsPathWithDates}&${projectIdsQueryParam}`;

          expect(findCodeCoverageDownloadButton().attributes('href')).toBe(expectedPath);
        });
      });

      describe('with no projects selected', () => {
        beforeEach(() => {
          createComponent({ allProjectsSelected: false, selectedProjectIds: [] });
        });

        it('renders a disabled primary action button', () => {
          expect(findCodeCoverageDownloadButton().attributes('disabled')).toBe('true');
        });
      });

      describe('when clicking the select all button', () => {
        beforeEach(() => {
          createComponent({ allProjectsSelected: false, selectedProjectIds: [] });
        });

        it('selects all projects and removes the disabled attribute from the download button', () => {
          clickSelectAllProjectsButton();

          return wrapper.vm.$nextTick().then(() => {
            expect(findCodeCoverageDownloadButton().attributes('href')).toBe(
              groupAnalyticsCoverageReportsPathWithDates,
            );
            expect(findCodeCoverageDownloadButton().attributes('disabled')).toBeUndefined();
          });
        });
      });
    });

    describe('when selecting a date range', () => {
      it.each`
        date  | expected
        ${7}  | ${`${defaultProps.groupAnalyticsCoverageReportsPath}&start_date=2020-06-29&end_date=2020-07-06`}
        ${14} | ${`${defaultProps.groupAnalyticsCoverageReportsPath}&start_date=2020-06-22&end_date=2020-07-06`}
        ${30} | ${`${defaultProps.groupAnalyticsCoverageReportsPath}&start_date=2020-06-06&end_date=2020-07-06`}
        ${60} | ${`${defaultProps.groupAnalyticsCoverageReportsPath}&start_date=2020-05-07&end_date=2020-07-06`}
        ${90} | ${`${defaultProps.groupAnalyticsCoverageReportsPath}&start_date=2020-04-07&end_date=2020-07-06`}
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
