import { TEST_HOST } from 'jest/helpers/test_constants';
import { DASHBOARD_TYPES } from 'ee/security_dashboard/store/constants';
import initVulnerabilityReport from 'ee/security_dashboard/first_class_init';

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
    vm.$destroy();
    vm = null;
    root.remove();
  });

  const createComponent = ({ type, CUSTOM_DATA }) => {
    const el = document.createElement('div');
    Object.assign(el.dataset, { ...TEST_DATASET, ...CUSTOM_DATA });
    root.appendChild(el);
    vm = initVulnerabilityReport(el, type);
  };

  it('runs for the project-level', () => {
    createComponent({
      type: DASHBOARD_TYPES.PROJECT,
      CUSTOM_DATA: {
        autoFixDocumentation: '/test/auto_fix_page',
        pipelineSecurityBuildsFailedCount: 1,
        pipelineSecurityBuildsFailedPath: '/test/faild_pipeline_02',
        projectFullPath: '/test/project',
      },
    });

    expect(root).toMatchSnapshot();
  });

  it('runs for the group-level', () => {
    createComponent({ type: DASHBOARD_TYPES.GROUP, CUSTOM_DATA: { groupFullPath: '/test/' } });

    expect(root).toMatchSnapshot();
  });

  it('runs for the instance-level', () => {
    createComponent({
      type: DASHBOARD_TYPES.INSTANCE,
      CUSTOM_DATA: { instanceDashboardSettingsPath: '/instance/settings_page' },
    });

    expect(root).toMatchSnapshot();
  });
});
