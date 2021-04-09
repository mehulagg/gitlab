import { GlBanner } from '@gitlab/ui';
import { within } from '@testing-library/dom';
import { shallowMount } from '@vue/test-utils';
import Cookies from 'js-cookie';
import AutoFixUserCallout from 'ee/security_dashboard/components/auto_fix_user_callout.vue';
import CsvExportButton from 'ee/security_dashboard/components/csv_export_button.vue';
import ReportsNotConfigured from 'ee/security_dashboard/components/empty_states/reports_not_configured.vue';
import FirstClassProjectSecurityDashboard from 'ee/security_dashboard/components/first_class_project_security_dashboard.vue';
import Filters from 'ee/security_dashboard/components/first_class_vulnerability_filters.vue';
import ProjectPipelineStatus from 'ee/security_dashboard/components/project_pipeline_status.vue';
import ProjectVulnerabilitiesApp from 'ee/security_dashboard/components/project_vulnerabilities.vue';
import SecurityDashboardLayout from 'ee/security_dashboard/components/security_dashboard_layout.vue';
import SurveyRequestBanner from 'ee/security_dashboard/components/survey_request_banner.vue';
import VulnerabilityCountList from 'ee/security_dashboard/components/vulnerability_count_list.vue';

const props = {
  notEnabledScannersHelpPath: '/help/docs/',
  noPipelineRunScannersHelpPath: '/new/pipeline',
  pipeline: {
    createdAt: '2020-10-06T20:08:07Z',
    id: '214',
    path: '/mixed-vulnerabilities/dependency-list-test-01/-/pipelines/214',
  },
  securityDashboardHelpPath: '/security/dashboard/help-path',
};

const provide = {
  projectFullPath: '/group/project',
  dashboardDocumentation: '/help/docs',
  autoFixDocumentation: '/auto/fix/documentation',
  emptyStateSvgPath: '/svgs/empty/svg',
  glFeatures: {
    securityAutoFix: true,
  },
};

const filters = { foo: 'bar' };

describe('First class Project Security Dashboard component', () => {
  let wrapper;

  const findFilters = () => wrapper.findComponent(Filters);
  const findProjectPipelineStatus = () => wrapper.findComponent(ProjectPipelineStatus);
  const findVulnerabilities = () => wrapper.findComponent(ProjectVulnerabilitiesApp);
  const findVulnerabilityCountList = () => wrapper.findComponent(VulnerabilityCountList);
  const findUnconfiguredState = () => wrapper.findComponent(ReportsNotConfigured);
  const findCsvExportButton = () => wrapper.findComponent(CsvExportButton);
  const findAutoFixUserCallout = () => wrapper.findComponent(AutoFixUserCallout);
  const findSurveyRequestBanner = () => wrapper.findComponent(SurveyRequestBanner);

  const createComponent = (options) => {
    wrapper = shallowMount(FirstClassProjectSecurityDashboard, {
      propsData: {
        ...props,
        ...options.props,
      },
      provide,
      stubs: { SecurityDashboardLayout, GlBanner },
      ...options,
    });
  };

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
  });

  describe('on render when there are vulnerabilities', () => {
    beforeEach(() => {
      createComponent({
        props: { hasVulnerabilities: true },
        data: () => ({ filters }),
      });
    });

    it('should render the header correctly', () => {
      expect(
        within(wrapper.element).getByRole('heading', { name: 'Vulnerability Report' }),
      ).not.toBe(null);
    });

    it('should render the vulnerabilities', () => {
      expect(findVulnerabilities().exists()).toBe(true);
    });

    it('should pass down the properties correctly to the vulnerabilities', () => {
      expect(findVulnerabilities().props()).toEqual({
        projectFullPath: props.projectFullPath,
        filters,
      });
    });

    it('should pass down the properties correctly to the vulnerability count list', () => {
      expect(findVulnerabilityCountList().props()).toEqual({
        scope: 'project',
        fullPath: provide.projectFullPath,
        filters,
      });
    });

    it('should render the filters component', () => {
      expect(findFilters().exists()).toBe(true);
    });

    it('does not display the unconfigured state', () => {
      expect(findUnconfiguredState().exists()).toBe(false);
    });

    it('should display the csv export button', () => {
      expect(findCsvExportButton().props('vulnerabilitiesExportEndpoint')).toEqual(
        props.vulnerabilitiesExportEndpoint,
      );
    });

    it('should display the project pipeline status', () => {
      expect(findProjectPipelineStatus()).toExist();
    });

    it('should show the survey request banner', () => {
      expect(findSurveyRequestBanner().exists()).toBe(true);
    });
  });

  describe('auto-fix user callout', () => {
    describe('feature flag disabled', () => {
      beforeEach(() => {
        createComponent({
          props: { hasVulnerabilities: true },
          provide: {
            ...provide,
            glFeatures: {
              securityAutoFix: false,
            },
          },
        });
      });

      it('does not show user callout', () => {
        expect(findAutoFixUserCallout().exists()).toBe(false);
      });
    });

    describe('cookie not set', () => {
      beforeEach(() => {
        jest.spyOn(Cookies, 'set');
        createComponent({
          props: { hasVulnerabilities: true },
        });
      });

      it('shows user callout by default', () => {
        expect(findAutoFixUserCallout().exists()).toBe(true);
      });

      it('when dismissed, hides the user callout and sets the cookie', async () => {
        await findAutoFixUserCallout().vm.$emit('close');

        expect(findAutoFixUserCallout().exists()).toBe(false);
        expect(Cookies.set).toHaveBeenCalledWith('auto_fix_user_callout_dismissed', 'true');
      });
    });

    describe('cookie set', () => {
      beforeEach(() => {
        jest.doMock('js-cookie', () => ({
          get: jest.fn().mockReturnValue(true),
        }));
        createComponent({
          props: { hasVulnerabilities: true },
        });
      });

      it('does not show user callout', () => {
        expect(findAutoFixUserCallout().exists()).toBe(false);
      });
    });
  });

  describe('with filter data', () => {
    beforeEach(() => {
      createComponent({
        props: {
          hasVulnerabilities: true,
        },
        data() {
          return { filters };
        },
      });
    });

    it('should pass the filter data down to the vulnerabilities', () => {
      expect(findVulnerabilities().props().filters).toEqual(filters);
    });
  });

  describe('when there is no vulnerability', () => {
    beforeEach(() => {
      createComponent({
        props: {
          pipeline: { id: undefined },
        },
      });
    });

    it('displays the unconfigured state', () => {
      expect(findUnconfiguredState().exists()).toBe(true);
    });

    it('shows the survey request banner', () => {
      expect(findSurveyRequestBanner().exists()).toBe(true);
    });
  });
});
