import '@testing-library/jest-dom/extend-expect';
import { screen } from '@testing-library/dom';
import initVulnerabilityReport from 'ee/security_dashboard/first_class_init';
import { DASHBOARD_TYPES } from 'ee/security_dashboard/store/constants';
import { TEST_HOST } from 'jest/helpers/test_constants';
import { enableExperimentalFragmentVariables } from 'graphql-tag';

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
    describe('project-level', () => {
      describe('without pipeline-id', () => {
        beforeEach(() => {
          const { pipelineId, ...dataWithoutPipelineId } = PROJECT_LEVEL_TEST_DATASET;
          createComponent({
            data: dataWithoutPipelineId,
            type: DASHBOARD_TYPES.PROJECT,
          });
        });

        it('matches snapshot', () => {
          expect(root).toMatchSnapshot();
        });

        it('shows a message describing the feature', () => {
          expect(
            screen.getByText(
              /The security dashboard displays the latest security report. Use it to find and fix vulnerabilities./i,
            ),
          ).not.toBe(null);
        });

        it('shows a "learn more" link to the help page', () => {
          expect(screen.getByRole('link', { name: /learn more/i })).toHaveAttribute(
            'href',
            TEST_DATASET.securityDashboardHelpPath,
          );
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
      createEmptyComponent();

      expect(root).toBeEmptyDOMElement();
      expect(vm).toBe(null);
    });

    it('has unavailable pages', () => {
      createComponent({ data: { isUnavailable: true } });

      expect(root).toMatchSnapshot();
    });
  });
});
