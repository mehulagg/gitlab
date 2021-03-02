import { GlLoadingIcon } from '@gitlab/ui';
import { shallowMount } from '@vue/test-utils';
import CsvExportButton from 'ee/security_dashboard/components/csv_export_button.vue';
import ReportNotConfigured from 'ee/security_dashboard/components/group/group_report_not_configured.vue';
import GroupReport from 'ee/security_dashboard/components/group/group_vulnerability_report.vue';
import GroupReportVulnerabilities from 'ee/security_dashboard/components/group/group_vulnerability_report_vulnerabilities.vue';
import Filters from 'ee/security_dashboard/components/shared/vulnerability_report_filters.vue';
import VulnerabilityReportLayout from 'ee/security_dashboard/components/shared/vulnerability_report_layout.vue';
import VulnerabilitiesCountList from 'ee/security_dashboard/components/vulnerability_count_list.vue';

describe('First Class Group Dashboard Component', () => {
  let wrapper;

  const dashboardDocumentation = 'dashboard-documentation';
  const emptyStateSvgPath = 'empty-state-path';
  const groupFullPath = 'group-full-path';
  const vulnerabilitiesExportEndpoint = '/vulnerabilities/exports';

  const findReportLayout = () => wrapper.find(VulnerabilityReportLayout);
  const findGroupVulnerabilities = () => wrapper.find(GroupReportVulnerabilities);
  const findCsvExportButton = () => wrapper.find(CsvExportButton);
  const findFilters = () => wrapper.find(Filters);
  const findLoadingIcon = () => wrapper.find(GlLoadingIcon);
  const findEmptyState = () => wrapper.find(ReportNotConfigured);
  const findVulnerabilitiesCountList = () => wrapper.find(VulnerabilitiesCountList);

  const createWrapper = ({ data } = {}) => {
    return shallowMount(GroupReport, {
      propsData: {
        dashboardDocumentation,
        emptyStateSvgPath,
        groupFullPath,
        vulnerabilitiesExportEndpoint,
      },
      data,
      stubs: {
        VulnerabilityReportLayout,
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

    it('dashboard should have display none because it needs to fetch the projects', () => {
      expect(findReportLayout().attributes('class')).toEqual('gl-display-none');
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
        groupFullPath,
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
      expect(findCsvExportButton().props('vulnerabilitiesExportEndpoint')).toBe(
        vulnerabilitiesExportEndpoint,
      );
    });

    it('loading button should not be rendered', () => {
      expect(findLoadingIcon().exists()).toBe(false);
    });

    it('dashboard should no more have display none', () => {
      expect(findReportLayout().attributes('class')).toEqual('');
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
      expect(findReportLayout().exists()).toBe(false);
    });

    it('should display the dashboard not configured component', () => {
      expect(findEmptyState().exists()).toBe(true);
    });
  });
});
