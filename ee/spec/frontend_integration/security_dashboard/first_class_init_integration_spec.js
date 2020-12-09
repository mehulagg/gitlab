import initVulnerabilityReport from 'ee/security_dashboard/first_class_init';
import { DASHBOARD_TYPES } from 'ee/security_dashboard/store/constants';
import { TEST_HOST } from 'jest/helpers/test_constants';

const EMPTY_DIV = document.createElement('div');

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

describe('Vulnerability Report', () => {
  let vm;
  let root;

  beforeEach(() => {
    root = document.createElement('div');
    document.body.appendChild(root);

    global.jsdom.reconfigure({
      url: `${TEST_HOST}/-/security/vulnerabilities`,
    });
  });

  afterEach(() => {
    if (vm) {
      vm.$destroy();
    }
    vm = null;
    root.remove();
  });

  const createComponent = ({ data, type }) => {
    const el = document.createElement('div');
    Object.assign(el.dataset, { ...TEST_DATASET, ...data });
    root.appendChild(el);
    vm = initVulnerabilityReport(el, type);
  };

  const createEmptyComponent = () => {
    vm = initVulnerabilityReport(null, null);
  };

  describe('default states', () => {
    it('sets up project-level', () => {
      createComponent({
        data: {
          autoFixDocumentation: '/test/auto_fix_page',
          pipelineSecurityBuildsFailedCount: 1,
          pipelineSecurityBuildsFailedPath: '/test/faild_pipeline_02',
          projectFullPath: '/test/project',
        },
        type: DASHBOARD_TYPES.PROJECT,
      });

      // These assertions will be expanded in issue #220290
      expect(root).not.toStrictEqual(EMPTY_DIV);
    });

    it('sets up group-level', () => {
      createComponent({ data: { groupFullPath: '/test/' }, type: DASHBOARD_TYPES.GROUP });

      // These assertions will be expanded in issue #220290
      expect(root).not.toStrictEqual(EMPTY_DIV);
    });

    it('sets up instance-level', () => {
      createComponent({
        data: { instanceDashboardSettingsPath: '/instance/settings_page' },
        type: DASHBOARD_TYPES.INSTANCE,
      });

      // These assertions will be expanded in issue #220290
      expect(root).not.toStrictEqual(EMPTY_DIV);
    });
  });

  describe('error states', () => {
    it('does not have an element', () => {
      createEmptyComponent();

      expect(root).toStrictEqual(EMPTY_DIV);
    });

    it('has unavailable pages', () => {
      createComponent({ data: { isUnavailable: true } });

      expect(root).toMatchSnapshot();
    });
  });
});
