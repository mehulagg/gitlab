import { GlLoadingIcon } from '@gitlab/ui';
import { shallowMount } from '@vue/test-utils';
import CsvExportButton from 'ee/security_dashboard/components/csv_export_button.vue';
import DashboardNotConfigured from 'ee/security_dashboard/components/empty_states/group_dashboard_not_configured.vue';
import FirstClassGroupDashboard from 'ee/security_dashboard/components/first_class_group_security_dashboard.vue';
import FirstClassGroupVulnerabilities from 'ee/security_dashboard/components/first_class_group_security_dashboard_vulnerabilities.vue';
import Filters from 'ee/security_dashboard/components/first_class_vulnerability_filters.vue';
import SecurityDashboardLayout from 'ee/security_dashboard/components/security_dashboard_layout.vue';
import VulnerabilitiesCountList from 'ee/security_dashboard/components/vulnerability_count_list.vue';

describe('First Class Group Dashboard Component', () => {
  let wrapper;

  const dashboardDocumentation = 'dashboard-documentation';
  const emptyStateSvgPath = 'empty-state-path';
  const groupFullPath = 'group-full-path';

  const findDashboardLayout = () => wrapper.find(SecurityDashboardLayout);
  const findGroupVulnerabilities = () => wrapper.find(FirstClassGroupVulnerabilities);
  const findCsvExportButton = () => wrapper.find(CsvExportButton);
  const findFilters = () => wrapper.find(Filters);
  const findLoadingIcon = () => wrapper.find(GlLoadingIcon);
  const findEmptyState = () => wrapper.find(DashboardNotConfigured);
  const findVulnerabilitiesCountList = () => wrapper.find(VulnerabilitiesCountList);

  const createWrapper = ({ data } = {}) => {
    return shallowMount(FirstClassGroupDashboard, {
      propsData: {
        dashboardDocumentation,
        emptyStateSvgPath,
      },
      provide: { groupFullPath },
      data,
      stubs: {
        SecurityDashboardLayout,
      },
    });
  };

  afterEach(() => {
    wrapper.destroy();
  });

  describe('when loading', () => {
    beforeEach(() => {
      wrapper = createWrapper();
    });

    it('loading button should be visible', () => {
      expect(findLoadingIcon().exists()).toBe(true);
    });

    it('should not display the dashboard not configured component', () => {
      expect(findEmptyState().exists()).toBe(false);
    });
  });

  describe('when has projects', () => {
    beforeEach(() => {
      wrapper = createWrapper({
        data: () => ({ projects: [{ id: 1, name: 'GitLab Org' }], projectsWereFetched: true }),
      });
    });

    it('should render correctly', () => {
      expect(findGroupVulnerabilities().props()).toEqual({
        filters: {},
      });
    });

    it('has filters', () => {
      expect(findFilters().exists()).toBe(true);
    });

    it('loads projects from data', () => {
      const projects = [{ id: 1, name: 'GitLab Org' }];
      expect(findFilters().props('projects')).toEqual(projects);
    });

    it('responds to the filterChange event', () => {
      const filters = { severity: 'critical' };
      findFilters().vm.$listeners.filterChange(filters);
      return wrapper.vm.$nextTick(() => {
        expect(wrapper.vm.filters).toEqual(filters);
        expect(findGroupVulnerabilities().props('filters')).toEqual(filters);
      });
    });

    it('displays the csv export button', () => {
      expect(findCsvExportButton().exists()).toBe(true);
    });

    it('loading button should not be rendered', () => {
      expect(findLoadingIcon().exists()).toBe(false);
    });

    it('should not display the dashboard not configured component', () => {
      expect(findEmptyState().exists()).toBe(false);
    });

    it('should display the vulnerability count list with the correct data', () => {
      expect(findVulnerabilitiesCountList().props()).toMatchObject({
        scope: 'group',
        fullPath: groupFullPath,
        filters: wrapper.vm.filters,
      });
    });
  });

  describe('when has no projects', () => {
    beforeEach(() => {
      wrapper = createWrapper({
        data: () => ({ projectsWereFetched: true }),
      });
    });

    it('loading button should not be rendered', () => {
      expect(findLoadingIcon().exists()).toBe(false);
    });

    it('dashboard should not be rendered', () => {
      expect(findDashboardLayout().exists()).toBe(false);
    });

    it('should display the dashboard not configured component', () => {
      expect(findEmptyState().exists()).toBe(true);
    });
  });
});
