import { GlAlert, GlDropdown, GlDropdownItem, GlModal } from '@gitlab/ui';
import { shallowMount, createLocalVue } from '@vue/test-utils';
import DownloadTestCoverage from 'ee/analytics/repository_analytics/components/download_test_coverage.vue';
import SelectProjectsDropdown from 'ee/analytics/repository_analytics/components/select_projects_dropdown.vue';
import { useFakeDate } from 'helpers/fake_date';

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

  const injectedProperties = {
    groupAnalyticsCoverageReportsPath: '/coverage.csv?ref_path=refs/heads/master',
  };

  const createComponent = () => {
    wrapper = shallowMount(DownloadTestCoverage, {
      localVue,
      data() {
        return {
          hasError: false,
          allProjectsSelected: false,
          selectedProjectIds: [],
        };
      },
      provide: {
        ...injectedProperties,
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
      it('displays an alert for the failed query', () => {
        wrapper.setData({ hasError: true });

        return wrapper.vm.$nextTick().then(() => {
          expect(findAlert().exists()).toBe(true);
        });
      });
    });

    describe('when selecting a project', () => {
      // Due to the fake_date helper, we can always expect today's date to be 2020-07-06
      // and the default date 30 days ago to be 2020-06-06
      const groupAnalyticsCoverageReportsPathWithDates = `${injectedProperties.groupAnalyticsCoverageReportsPath}&start_date=2020-06-06&end_date=2020-07-06`;

      describe('with all projects selected', () => {
        it('renders primary action as a link with no project_ids param', () => {
          wrapper.setData({ allProjectsSelected: true, selectedProjectIds: [] });

          return wrapper.vm.$nextTick().then(() => {
            expect(findCodeCoverageDownloadButton().attributes('href')).toBe(
              groupAnalyticsCoverageReportsPathWithDates,
            );
          });
        });
      });

      describe('with two or more projects selected without selecting all projects', () => {
        it('renders primary action as a link with two project IDs as parameters', () => {
          wrapper.setData({ allProjectsSelected: false, selectedProjectIds: [1, 2] });
          const projectIdsQueryParam = `project_ids%5B%5D=1&project_ids%5B%5D=2`;
          const expectedPath = `${groupAnalyticsCoverageReportsPathWithDates}&${projectIdsQueryParam}`;

          return wrapper.vm.$nextTick().then(() => {
            expect(findCodeCoverageDownloadButton().attributes('href')).toBe(expectedPath);
          });
        });
      });

      describe('with one project selected', () => {
        it('renders primary action as a link with one project ID as a parameter', () => {
          wrapper.setData({ allProjectsSelected: false, selectedProjectIds: [1] });
          const projectIdsQueryParam = `project_ids%5B%5D=1`;
          const expectedPath = `${groupAnalyticsCoverageReportsPathWithDates}&${projectIdsQueryParam}`;

          return wrapper.vm.$nextTick().then(() => {
            expect(findCodeCoverageDownloadButton().attributes('href')).toBe(expectedPath);
          });
        });
      });

      describe('with no projects selected', () => {
        it('renders a disabled primary action button', () => {
          expect(findCodeCoverageDownloadButton().attributes('disabled')).toBe('true');
        });
      });

      describe('when clicking the select all button', () => {
        it('selects all projects and removes the disabled attribute from the download button', () => {
          wrapper.setData({ allProjectsSelected: false, selectedProjectIds: [] });
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
