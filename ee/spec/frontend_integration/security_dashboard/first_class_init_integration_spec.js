import '@testing-library/jest-dom/extend-expect';
import { omit } from 'lodash';
import { createWrapper } from '@vue/test-utils';
import initVulnerabilityReport from 'ee/security_dashboard/first_class_init';
import ReportsNotConfigured from 'ee/security_dashboard/components/empty_states/reports_not_configured.vue';
import { DASHBOARD_TYPES } from 'ee/security_dashboard/store/constants';
import { TEST_HOST } from 'jest/helpers/test_constants';

const TEST_DATASET = {
  dashboardDocumentation: '/test/dashboard_page',
  emptyStateSvgPath: '/test/empty_state.svg',
  hasVulnerabilities: true,
  link: '/test/link',
  noPipelineRunScannersHelpPath: '/test/no_pipeline_run_page',
  notEnabledScannersHelpPath: '/test/security_dashboard_not_enabled_page',
  noVulnerabilitiesSvgPath: '/test/no_vulnerability_state.svg',
  projectAddEndpoint: '/test/add-projects',
  projectListEndpoint: '/test/list-projects',
  securityDashboardHelpPath: '/test/security_dashboard_page',
  svgPath: '/test/no_changes_state.svg',
  vulnerabilitiesExportEndpoint: '/test/export-vulnerabilities',
};

const PROJECT_LEVEL_TEST_DATASET = {
  autoFixDocumentation: '/test/auto_fix_page',
  pipelineSecurityBuildsFailedCount: 1,
  pipelineSecurityBuildsFailedPath: '/test/faild_pipeline_02',
  projectFullPath: '/test/project',
};

describe('Vulnerability Report', () => {
  let wrapper;
  let root;

  beforeEach(() => {
    root = document.createElement('div');
    document.body.appendChild(root);

    global.jsdom.reconfigure({
      url: `${TEST_HOST}/-/security/vulnerabilities`,
    });
  });

  afterEach(() => {
    if (wrapper) {
      wrapper.vm.$destroy();
    }
    wrapper = null;
    root.remove();
  });

  const createComponent = ({ data, type }) => {
    const el = document.createElement('div');
    Object.assign(el.dataset, { ...TEST_DATASET, ...data });
    root.appendChild(el);
    wrapper = createWrapper(initVulnerabilityReport(el, type));
  };

  describe('default states', () => {
    describe('project-level', () => {
      describe('without a pipeline-id', () => {
        beforeEach(() => {
          const dataWithoutPipelineId = omit(PROJECT_LEVEL_TEST_DATASET, 'pipelineId');
          createComponent({
            data: dataWithoutPipelineId,
            type: DASHBOARD_TYPES.PROJECT,
          });
        });

        it('matches snapshot', () => {
          expect(root).toMatchSnapshot();
        });

        it('shows that reports are not configured and provides a link to the help page', () => {
          const reportsNotConfigured = wrapper.find(ReportsNotConfigured);
          expect(reportsNotConfigured.exists()).toBe(true);
          expect(reportsNotConfigured.props()).toMatchObject({
            helpPath: TEST_DATASET.securityDashboardHelpPath,
          });
        });
      });
    });

    it('sets up group-level', () => {
      createComponent({ data: { groupFullPath: '/test/' }, type: DASHBOARD_TYPES.GROUP });

      // These assertions will be expanded in issue #220290
      expect(root).not.toBeEmptyDOMElement();
    });

    it('sets up instance-level', () => {
      createComponent({
        data: { instanceDashboardSettingsPath: '/instance/settings_page' },
        type: DASHBOARD_TYPES.INSTANCE,
      });

      // These assertions will be expanded in issue #220290
      expect(root).not.toBeEmptyDOMElement();
    });
  });

  describe('error states', () => {
    it('does not have an element', () => {
      const vm = initVulnerabilityReport(null, null);

      expect(root).toBeEmptyDOMElement();
      expect(vm).toBe(null);
    });

    it('has unavailable pages', () => {
      createComponent({ data: { isUnavailable: true } });

      expect(root).toMatchSnapshot();
    });
  });
});
