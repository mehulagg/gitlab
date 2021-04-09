import { GlLoadingIcon } from '@gitlab/ui';
import { shallowMount } from '@vue/test-utils';
import CsvExportButton from 'ee/security_dashboard/components/csv_export_button.vue';
import DashboardNotConfigured from 'ee/security_dashboard/components/empty_states/instance_dashboard_not_configured.vue';
import FirstClassInstanceDashboard from 'ee/security_dashboard/components/first_class_instance_security_dashboard.vue';
import FirstClassInstanceVulnerabilities from 'ee/security_dashboard/components/first_class_instance_security_dashboard_vulnerabilities.vue';
import Filters from 'ee/security_dashboard/components/first_class_vulnerability_filters.vue';
import SecurityDashboardLayout from 'ee/security_dashboard/components/security_dashboard_layout.vue';
import SurveyRequestBanner from 'ee/security_dashboard/components/survey_request_banner.vue';
import VulnerabilitiesCountList from 'ee/security_dashboard/components/vulnerability_count_list.vue';

describe('First Class Instance Dashboard Component', () => {
  let wrapper;

  const defaultMocks = ({ loading = false } = {}) => ({
    $apollo: { queries: { projects: { loading } } },
  });

  const findInstanceVulnerabilities = () =>
    wrapper.findComponent(FirstClassInstanceVulnerabilities);
  const findCsvExportButton = () => wrapper.findComponent(CsvExportButton);
  const findEmptyState = () => wrapper.findComponent(DashboardNotConfigured);
  const findFilters = () => wrapper.findComponent(Filters);
  const findVulnerabilitiesCountList = () => wrapper.findComponent(VulnerabilitiesCountList);
  const findHeader = () => wrapper.find('[data-testid="header"]');
  const findSurveyBanner = () => wrapper.findComponent(SurveyRequestBanner);

  const createWrapper = ({ data = {}, stubs, mocks = defaultMocks() }) => {
    return shallowMount(FirstClassInstanceDashboard, {
      data() {
        return { ...data };
      },
      mocks,
      stubs: {
        ...stubs,
        SecurityDashboardLayout,
      },
    });
  };

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
  });

  describe('when initialized', () => {
    beforeEach(() => {
      wrapper = createWrapper({
        data: {
          projects: [{ id: 1 }, { id: 2 }],
        },
      });
    });

    it('should show the header', () => {
      expect(findHeader().exists()).toBe(true);
    });

    it('should render the vulnerabilities', () => {
      expect(findInstanceVulnerabilities().props()).toEqual({
        filters: {},
      });
    });

    it('should show the survey banner', () => {
      expect(findSurveyBanner().exists()).toBe(true);
    });

    it('has filters', () => {
      expect(findFilters().exists()).toBe(true);
    });

    it('responds to the filterChange event', () => {
      const filters = { severity: 'critical' };
      findFilters().vm.$listeners.filterChange(filters);
      return wrapper.vm.$nextTick(() => {
        expect(wrapper.vm.filters).toEqual(filters);
        expect(findInstanceVulnerabilities().props('filters')).toEqual(filters);
      });
    });

    it('displays the csv export button', () => {
      expect(findCsvExportButton().exists()).toBe(true);
    });

    it('displays the vulnerability count list with the correct data', () => {
      expect(findVulnerabilitiesCountList().props()).toMatchObject({
        scope: 'instance',
        filters: wrapper.vm.filters,
      });
    });
  });

  describe('when loading projects', () => {
    beforeEach(() => {
      wrapper = createWrapper({
        mocks: defaultMocks({ loading: true }),
        data: {
          projects: [{ id: 1 }],
        },
      });
    });

    it('only shows the loading icon', () => {
      expect(wrapper.findComponent(GlLoadingIcon).exists()).toBe(true);
      expect(findCsvExportButton().exists()).toBe(false);
      expect(findVulnerabilitiesCountList().exists()).toBe(false);
      expect(findHeader().exists()).toBe(false);
      expect(findSurveyBanner().exists()).toBe(false);
    });
  });

  describe('when uninitialized', () => {
    beforeEach(() => {
      wrapper = createWrapper({
        data: {
          isManipulatingProjects: false,
        },
      });
    });

    it('only renders the empty state and survey banner', () => {
      expect(findEmptyState().exists()).toBe(true);
      expect(findSurveyBanner().exists()).toBe(true);
      expect(findCsvExportButton().exists()).toBe(false);
      expect(findInstanceVulnerabilities().exists()).toBe(false);
      expect(findFilters().exists()).toBe(false);
      expect(findVulnerabilitiesCountList().exists()).toBe(false);
      expect(findHeader().exists()).toBe(false);
    });
  });
});
