import { within } from '@testing-library/dom';
import { shallowMount } from '@vue/test-utils';
import CsvExportButton from 'ee/security_dashboard/components/csv_export_button.vue';
import ReportNotConfigured from 'ee/security_dashboard/components/instance/instance_report_not_configured.vue';
import InstanceReport from 'ee/security_dashboard/components/instance/instance_vulnerability_report.vue';
import InstanceReportVulnerabilities from 'ee/security_dashboard/components/instance/instance_vulnerability_report_vulnerabilities.vue';
import Filters from 'ee/security_dashboard/components/shared/vulnerability_report_filters.vue';
import ReportLayout from 'ee/security_dashboard/components/shared/vulnerability_report_layout.vue';
import VulnerabilitiesCountList from 'ee/security_dashboard/components/vulnerability_count_list.vue';

describe('First Class Instance Dashboard Component', () => {
  let wrapper;

  const defaultMocks = ({ loading = false } = {}) => ({
    $apollo: { queries: { projects: { loading } } },
  });

  const vulnerabilitiesExportEndpoint = '/vulnerabilities/exports';

  const findInstanceVulnerabilities = () => wrapper.find(InstanceReportVulnerabilities);
  const findCsvExportButton = () => wrapper.find(CsvExportButton);
  const findEmptyState = () => wrapper.find(ReportNotConfigured);
  const findFilters = () => wrapper.find(Filters);
  const findVulnerabilitiesCountList = () => wrapper.find(VulnerabilitiesCountList);

  const createWrapper = ({ data = {}, stubs, mocks = defaultMocks() }) => {
    return shallowMount(InstanceReport, {
      data() {
        return { ...data };
      },
      mocks,
      propsData: {
        vulnerabilitiesExportEndpoint,
      },
      stubs: {
        ...stubs,
        ReportLayout,
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

    it('should render the vulnerabilities', () => {
      expect(findInstanceVulnerabilities().props()).toEqual({
        filters: {},
      });
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
      expect(findCsvExportButton().props('vulnerabilitiesExportEndpoint')).toBe(
        vulnerabilitiesExportEndpoint,
      );
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

    it('does not render the export button', () => {
      expect(findCsvExportButton().exists()).toBe(false);
    });

    it('does not render the vulnerabilities count list', () => {
      expect(findVulnerabilitiesCountList().exists()).toBe(false);
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

    it('renders the empty state', () => {
      expect(findEmptyState().props()).toEqual({});
    });

    it('does not render the export button', () => {
      expect(findCsvExportButton().exists()).toBe(false);
    });

    it('does not render the vulnerability list', () => {
      expect(findInstanceVulnerabilities().exists()).toBe(false);
    });

    it('has no filters', () => {
      expect(findFilters().exists()).toBe(false);
    });

    it('does not render the vulnerabilities count list', () => {
      expect(findVulnerabilitiesCountList().exists()).toBe(false);
    });
  });

  describe('always', () => {
    beforeEach(() => {
      wrapper = createWrapper({});
    });

    it('has the security dashboard title', () => {
      expect(
        within(wrapper.element).getByRole('heading', { name: 'Vulnerability Report' }),
      ).not.toBe(null);
    });
  });
});
