import { mount } from '@vue/test-utils';
import MockAdapter from 'axios-mock-adapter';
import Vue from 'vue';
import GroupedSecurityReportsApp from 'ee/vue_shared/security_reports/grouped_security_reports_app.vue';
import appStore from 'ee/vue_shared/security_reports/store';
import { trackMrSecurityReportDetails } from 'ee/vue_shared/security_reports/store/constants';
import * as apiFuzzingTypes from 'ee/vue_shared/security_reports/store/modules/api_fuzzing/mutation_types';
import * as sastTypes from 'ee/vue_shared/security_reports/store/modules/sast/mutation_types';
import * as secretDetectionTypes from 'ee/vue_shared/security_reports/store/modules/secret_detection/mutation_types';
import * as types from 'ee/vue_shared/security_reports/store/mutation_types';
import { trimText } from 'helpers/text_helper';
import { mockTracking, unmockTracking } from 'helpers/tracking_helper';
import { waitForMutation } from 'helpers/vue_test_utils_helper';
import axios from '~/lib/utils/axios_utils';
import { mrStates } from '~/mr_popover/constants';
import GroupedIssuesList from '~/reports/components/grouped_issues_list.vue';
import ReportSection from '~/reports/components/report_section.vue';

import {
  sastDiffSuccessMock,
  dastDiffSuccessMock,
  containerScanningDiffSuccessMock,
  dependencyScanningDiffSuccessMock,
  secretScanningDiffSuccessMock,
  coverageFuzzingDiffSuccessMock,
  apiFuzzingDiffSuccessMock,
  mockFindings,
} from './mock_data';

const CONTAINER_SCANNING_DIFF_ENDPOINT = 'container_scanning.json';
const DEPENDENCY_SCANNING_DIFF_ENDPOINT = 'dependency_scanning.json';
const DAST_DIFF_ENDPOINT = 'dast.json';
const SAST_DIFF_ENDPOINT = 'sast.json';
const PIPELINE_JOBS_ENDPOINT = 'jobs.json';
const SECRET_DETECTION_DIFF_ENDPOINT = 'secret_detection.json';
const API_FUZZING_DIFF_ENDPOINT = 'api_fuzzing.json';
const COVERAGE_FUZZING_DIFF_ENDPOINT = 'coverage_fuzzing.json';

describe('Grouped security reports app', () => {
  let wrapper;
  let mock;

  const findReportSection = () => wrapper.find(ReportSection);

  const props = {
    headBlobPath: 'path',
    baseBlobPath: 'path',
    sastHelpPath: 'path',
    containerScanningHelpPath: 'path',
    dastHelpPath: 'path',
    dependencyScanningHelpPath: 'path',
    secretScanningHelpPath: 'path',
    canReadVulnerabilityFeedbackPath: true,
    vulnerabilityFeedbackPath: 'vulnerability_feedback_path.json',
    coverageFuzzingHelpPath: 'path',
    apiFuzzingHelpPath: 'path',
    pipelineId: 123,
    projectId: 321,
    mrIid: 123,
    projectFullPath: 'path',
    targetProjectFullPath: 'path',
    apiFuzzingComparisonPath: API_FUZZING_DIFF_ENDPOINT,
    containerScanningComparisonPath: CONTAINER_SCANNING_DIFF_ENDPOINT,
    coverageFuzzingComparisonPath: COVERAGE_FUZZING_DIFF_ENDPOINT,
    dastComparisonPath: DAST_DIFF_ENDPOINT,
    dependencyScanningComparisonPath: DEPENDENCY_SCANNING_DIFF_ENDPOINT,
    sastComparisonPath: SAST_DIFF_ENDPOINT,
    secretScanningComparisonPath: SECRET_DETECTION_DIFF_ENDPOINT,
  };

  const defaultDastSummary = {
    scannedResourcesCount: 211,
    scannedResources: { nodes: [] },
    scannedResourcesCsvPath: '',
  };

  const glModalDirective = jest.fn();

  const createWrapper = (propsData, options, provide) => {
    wrapper = mount(GroupedSecurityReportsApp, {
      propsData,
      mocks: {
        $apollo: {
          queries: {
            reportArtifacts: {
              loading: false,
            },
          },
        },
      },
      data() {
        return {
          dastSummary: defaultDastSummary,
          ...options?.data,
        };
      },
      directives: {
        glModal: {
          bind(el, { value }) {
            glModalDirective(value);
          },
        },
      },
      store: appStore(),
      provide: {
        ...provide,
      },
    });
  };

  beforeEach(() => {
    mock = new MockAdapter(axios);
    mock.onGet('vulnerability_feedback_path.json').reply(200, []);
  });

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
    mock.restore();
  });

  describe('all reports', () => {
    const allReportProps = {
      ...props,
      enabledReports: {
        sast: true,
        dast: true,
        containerScanning: true,
        dependencyScanning: true,
        secretDetection: true,
        coverageFuzzing: true,
        apiFuzzing: true,
      },
    };

    describe('with error', () => {
      beforeEach(() => {
        mock.onGet(CONTAINER_SCANNING_DIFF_ENDPOINT).reply(500);
        mock.onGet(DEPENDENCY_SCANNING_DIFF_ENDPOINT).reply(500);
        mock.onGet(DAST_DIFF_ENDPOINT).reply(500);
        mock.onGet(SAST_DIFF_ENDPOINT).reply(500);
        mock.onGet(SECRET_DETECTION_DIFF_ENDPOINT).reply(500);
        mock.onGet(COVERAGE_FUZZING_DIFF_ENDPOINT).reply(500);
        mock.onGet(API_FUZZING_DIFF_ENDPOINT).reply(500);

        createWrapper(allReportProps);

        return Promise.all([
          waitForMutation(wrapper.vm.$store, `sast/${sastTypes.RECEIVE_DIFF_ERROR}`),
          waitForMutation(wrapper.vm.$store, types.RECEIVE_CONTAINER_SCANNING_DIFF_ERROR),
          waitForMutation(wrapper.vm.$store, types.RECEIVE_DAST_DIFF_ERROR),
          waitForMutation(wrapper.vm.$store, types.RECEIVE_DEPENDENCY_SCANNING_DIFF_ERROR),
          waitForMutation(
            wrapper.vm.$store,
            `secretDetection/${secretDetectionTypes.RECEIVE_DIFF_ERROR}`,
          ),
          waitForMutation(wrapper.vm.$store, types.RECEIVE_COVERAGE_FUZZING_DIFF_ERROR),
          waitForMutation(wrapper.vm.$store, `apiFuzzing/${apiFuzzingTypes.RECEIVE_DIFF_ERROR}`),
        ]);
      });

      it('renders error state', () => {
        expect(wrapper.vm.$el.querySelector('.gl-spinner')).toBeNull();
        expect(
          wrapper.vm.$el
            .querySelector('[data-testid="report-section-code-text"]')
            .textContent.trim(),
        ).toEqual('Security scanning failed loading any results');

        expect(wrapper.vm.$el.querySelector('.js-collapse-btn').textContent.trim()).toEqual(
          'Expand',
        );

        expect(trimText(wrapper.vm.$el.textContent)).toContain(
          'SAST: Loading resulted in an error',
        );

        expect(trimText(wrapper.vm.$el.textContent)).toContain(
          'Dependency scanning: Loading resulted in an error',
        );

        expect(wrapper.vm.$el.textContent).toContain(
          'Container scanning: Loading resulted in an error',
        );

        expect(wrapper.vm.$el.textContent).toContain('DAST: Loading resulted in an error');

        expect(wrapper.text()).toContain('Secret scanning: Loading resulted in an error');
      });
    });

    describe('while loading', () => {
      beforeEach(() => {
        mock.onGet(PIPELINE_JOBS_ENDPOINT).reply(200, {});
        mock.onGet(CONTAINER_SCANNING_DIFF_ENDPOINT).reply(200, {});
        mock.onGet(DEPENDENCY_SCANNING_DIFF_ENDPOINT).reply(200, {});
        mock.onGet(DAST_DIFF_ENDPOINT).reply(200, {});
        mock.onGet(SAST_DIFF_ENDPOINT).reply(200, {});
        mock.onGet(SECRET_DETECTION_DIFF_ENDPOINT).reply(200, {});
        mock.onGet(COVERAGE_FUZZING_DIFF_ENDPOINT).reply(200, {});
        mock.onGet(API_FUZZING_DIFF_ENDPOINT).reply(200, {});

        createWrapper(allReportProps);
      });

      it('renders loading summary text + spinner', () => {
        expect(wrapper.vm.$el.querySelector('.gl-spinner')).not.toBeNull();
        expect(
          wrapper.vm.$el
            .querySelector('[data-testid="report-section-code-text"]')
            .textContent.trim(),
        ).toEqual('Security scanning is loading');

        expect(wrapper.vm.$el.querySelector('.js-collapse-btn').textContent.trim()).toEqual(
          'Expand',
        );

        expect(wrapper.vm.$el.textContent).toContain('SAST is loading');
        expect(wrapper.vm.$el.textContent).toContain('Dependency scanning is loading');
        expect(wrapper.vm.$el.textContent).toContain('Container scanning is loading');
        expect(wrapper.vm.$el.textContent).toContain('DAST is loading');
        expect(wrapper.vm.$el.textContent).toContain('Coverage fuzzing is loading');
        expect(wrapper.vm.$el.textContent).toContain('API fuzzing is loading');
      });
    });

    describe('with empty reports', () => {
      beforeEach(() => {
        const emptyResponse = { ...dastDiffSuccessMock, fixed: [], added: [] };
        mock.onGet(CONTAINER_SCANNING_DIFF_ENDPOINT).reply(200, emptyResponse);
        mock.onGet(DEPENDENCY_SCANNING_DIFF_ENDPOINT).reply(200, emptyResponse);
        mock.onGet(DAST_DIFF_ENDPOINT).reply(200, emptyResponse);
        mock.onGet(SAST_DIFF_ENDPOINT).reply(200, emptyResponse);
        mock.onGet(SECRET_DETECTION_DIFF_ENDPOINT).reply(200, emptyResponse);
        mock.onGet(COVERAGE_FUZZING_DIFF_ENDPOINT).reply(200, emptyResponse);
        mock.onGet(API_FUZZING_DIFF_ENDPOINT).reply(200, emptyResponse);

        createWrapper(allReportProps);

        return Promise.all([
          waitForMutation(wrapper.vm.$store, `sast/${sastTypes.RECEIVE_DIFF_SUCCESS}`),
          waitForMutation(wrapper.vm.$store, types.RECEIVE_DAST_DIFF_SUCCESS),
          waitForMutation(wrapper.vm.$store, types.RECEIVE_CONTAINER_SCANNING_DIFF_SUCCESS),
          waitForMutation(wrapper.vm.$store, types.RECEIVE_DEPENDENCY_SCANNING_DIFF_SUCCESS),
          waitForMutation(
            wrapper.vm.$store,
            `secretDetection/${secretDetectionTypes.RECEIVE_DIFF_SUCCESS}`,
          ),
          waitForMutation(wrapper.vm.$store, types.RECEIVE_COVERAGE_FUZZING_DIFF_SUCCESS),
          waitForMutation(wrapper.vm.$store, `apiFuzzing/${apiFuzzingTypes.RECEIVE_DIFF_SUCCESS}`),
        ]);
      });

      it('renders reports', () => {
        // It's not loading
        expect(wrapper.vm.$el.querySelector('.gl-spinner')).toBeNull();

        // Renders the summary text
        expect(
          wrapper.vm.$el
            .querySelector('[data-testid="report-section-code-text"]')
            .textContent.trim(),
        ).toEqual('Security scanning detected no vulnerabilities.');

        // Renders Sast result
        expect(trimText(wrapper.vm.$el.textContent)).toContain('SAST detected no vulnerabilities.');

        // Renders DSS result
        expect(trimText(wrapper.vm.$el.textContent)).toContain(
          'Dependency scanning detected no vulnerabilities.',
        );

        // Renders container scanning result
        expect(wrapper.vm.$el.textContent).toContain(
          'Container scanning detected no vulnerabilities.',
        );

        // Renders DAST result
        expect(wrapper.vm.$el.textContent).toContain('DAST detected no vulnerabilities.');

        // Renders Coverage Fuzzing result
        expect(wrapper.vm.$el.textContent).toContain(
          'Coverage fuzzing detected no vulnerabilities.',
        );

        // Renders API Fuzzing result
        expect(wrapper.vm.$el.textContent).toContain('API fuzzing detected no vulnerabilities.');
      });
    });

    describe('with successful responses', () => {
      beforeEach(() => {
        mock.onGet(CONTAINER_SCANNING_DIFF_ENDPOINT).reply(200, containerScanningDiffSuccessMock);
        mock.onGet(DEPENDENCY_SCANNING_DIFF_ENDPOINT).reply(200, dependencyScanningDiffSuccessMock);
        mock.onGet(DAST_DIFF_ENDPOINT).reply(200, dastDiffSuccessMock);
        mock.onGet(SAST_DIFF_ENDPOINT).reply(200, sastDiffSuccessMock);
        mock.onGet(SECRET_DETECTION_DIFF_ENDPOINT).reply(200, secretScanningDiffSuccessMock);
        mock.onGet(COVERAGE_FUZZING_DIFF_ENDPOINT).reply(200, coverageFuzzingDiffSuccessMock);
        mock.onGet(API_FUZZING_DIFF_ENDPOINT).reply(200, apiFuzzingDiffSuccessMock);

        createWrapper(allReportProps);

        return Promise.all([
          waitForMutation(wrapper.vm.$store, `sast/${sastTypes.RECEIVE_DIFF_SUCCESS}`),
          waitForMutation(wrapper.vm.$store, types.RECEIVE_DAST_DIFF_SUCCESS),
          waitForMutation(wrapper.vm.$store, types.RECEIVE_CONTAINER_SCANNING_DIFF_SUCCESS),
          waitForMutation(wrapper.vm.$store, types.RECEIVE_DEPENDENCY_SCANNING_DIFF_SUCCESS),
          waitForMutation(
            wrapper.vm.$store,
            `secretDetection/${secretDetectionTypes.RECEIVE_DIFF_SUCCESS}`,
          ),
          waitForMutation(wrapper.vm.$store, types.RECEIVE_COVERAGE_FUZZING_DIFF_SUCCESS),
          waitForMutation(wrapper.vm.$store, `apiFuzzing/${apiFuzzingTypes.RECEIVE_DIFF_SUCCESS}`),
        ]);
      });

      it('renders reports', () => {
        // It's not loading
        expect(wrapper.vm.$el.querySelector('.gl-spinner')).toBeNull();

        // Renders the summary text
        expect(
          trimText(
            wrapper.vm.$el.querySelector('[data-testid="report-section-code-text"]').textContent,
          ),
        ).toEqual(
          'Security scanning detected 12 potential vulnerabilities 7 Critical 5 High and 0 Others',
        );

        // Renders the expand button
        expect(wrapper.vm.$el.querySelector('.js-collapse-btn').textContent.trim()).toEqual(
          'Expand',
        );

        // Renders Sast result
        expect(trimText(wrapper.vm.$el.textContent)).toContain(
          'SAST detected 1 potential vulnerability 1 Critical 0 High and 0 Others',
        );

        // Renders DSS result
        expect(trimText(wrapper.vm.$el.textContent)).toContain(
          'Dependency scanning detected 2 potential vulnerabilities 1 Critical 1 High and 0 Others',
        );

        // Renders container scanning result
        expect(trimText(wrapper.vm.$el.textContent)).toContain(
          'Container scanning detected 2 potential vulnerabilities 1 Critical 1 High and 0 Others',
        );

        // Renders DAST result
        expect(trimText(wrapper.vm.$el.textContent)).toContain(
          'DAST detected 1 potential vulnerability 1 Critical 0 High and 0 Others',
        );

        // Renders coverage fuzzing scanning result
        expect(trimText(wrapper.vm.$el.textContent)).toContain(
          'Coverage fuzzing detected 2 potential vulnerabilities 1 Critical 1 High and 0 Others',
        );

        // Renders api fuzzing scanning result
        expect(trimText(wrapper.vm.$el.textContent)).toContain(
          'API fuzzing detected 2 potential vulnerabilities 1 Critical 1 High and 0 Others',
        );
      });

      it('opens modal with more information', () => {
        wrapper.vm.$el.querySelector('[aria-label="Vulnerability Name"]').click();

        return Vue.nextTick().then(() => {
          expect(document.querySelector('.modal-title').textContent.trim()).toEqual(
            mockFindings[0].name,
          );

          expect(document.querySelector('.modal-body').textContent).toContain(
            mockFindings[0].solution,
          );
        });
      });

      it.each`
        reportType               | resolvedIssues                             | unresolvedIssues
        ${'sast'}                | ${sastDiffSuccessMock.fixed}               | ${sastDiffSuccessMock.added}
        ${'dependency-scanning'} | ${dependencyScanningDiffSuccessMock.fixed} | ${dependencyScanningDiffSuccessMock.added}
        ${'container-scanning'}  | ${containerScanningDiffSuccessMock.fixed}  | ${containerScanningDiffSuccessMock.added}
        ${'dast'}                | ${dastDiffSuccessMock.fixed}               | ${dastDiffSuccessMock.added}
        ${'secret-scanning'}     | ${secretScanningDiffSuccessMock.fixed}     | ${secretScanningDiffSuccessMock.added}
        ${'coverage-fuzzing'}    | ${coverageFuzzingDiffSuccessMock.fixed}    | ${coverageFuzzingDiffSuccessMock.added}
        ${'api-fuzzing'}         | ${apiFuzzingDiffSuccessMock.fixed}         | ${apiFuzzingDiffSuccessMock.added}
      `(
        'renders a grouped-issues-list with the correct props for "$reportType" issues',
        ({ reportType, resolvedIssues, unresolvedIssues }) => {
          const issuesList = wrapper.find(`[data-testid="${reportType}-issues-list"]`);

          expect(issuesList.is(GroupedIssuesList)).toBe(true);

          expect(issuesList.props()).toMatchObject({
            resolvedIssues,
            unresolvedIssues,
            component: 'SecurityIssueBody',
          });
        },
      );
    });
  });

  describe('with the pipelinePath prop', () => {
    const pipelinePath = '/path/to/the/pipeline';

    beforeEach(() => {
      createWrapper({
        headBlobPath: 'path',
        pipelinePath,
        projectFullPath: 'path',
        targetProjectFullPath: 'path',
        mrIid: 123,
      });
    });

    it('should calculate the security tab path', () => {
      const button = wrapper.find('.report-btn');
      expect(button.attributes('target')).toBe('_blank');
      expect(button.attributes('href')).toBe(`${pipelinePath}/security`);
    });

    it('should render view full report button', () => {
      const button = wrapper.find('.report-btn');
      expect(button.exists()).toBe(true);
    });
  });

  describe('coverage fuzzing reports', () => {
    beforeEach(() => {
      createWrapper(
        {
          ...props,
          enabledReports: {
            coverageFuzzing: true,
          },
        },
        {},
      );
    });

    it('renders', () => {
      expect(wrapper.find('.js-coverage-fuzzing-widget').exists()).toBe(true);
    });
  });

  describe('api fuzzing reports', () => {
    beforeEach(() => {
      mock.onGet(API_FUZZING_DIFF_ENDPOINT).reply(200, apiFuzzingDiffSuccessMock);

      createWrapper({
        ...props,
        enabledReports: {
          apiFuzzing: true,
        },
      });

      return waitForMutation(
        wrapper.vm.$store,
        `apiFuzzing/${apiFuzzingTypes.RECEIVE_DIFF_SUCCESS}`,
      );
    });

    it('should set setApiFuzzingDiffEndpoint', () => {
      expect(wrapper.vm.apiFuzzing.paths.diffEndpoint).toEqual(API_FUZZING_DIFF_ENDPOINT);
    });

    it('should display the correct numbers of vulnerabilities', () => {
      expect(trimText(wrapper.text())).toContain(
        'API fuzzing detected 2 potential vulnerabilities 1 Critical 1 High and 0 Others',
      );
    });
  });

  describe('container scanning reports', () => {
    beforeEach(() => {
      mock.onGet(CONTAINER_SCANNING_DIFF_ENDPOINT).reply(200, containerScanningDiffSuccessMock);

      createWrapper({
        ...props,
        enabledReports: {
          containerScanning: true,
        },
      });

      return waitForMutation(wrapper.vm.$store, types.RECEIVE_CONTAINER_SCANNING_DIFF_SUCCESS);
    });

    it('should set setContainerScanningDiffEndpoint', () => {
      expect(wrapper.vm.containerScanning.paths.diffEndpoint).toEqual(
        CONTAINER_SCANNING_DIFF_ENDPOINT,
      );
    });

    it('should display the correct numbers of vulnerabilities', () => {
      expect(trimText(wrapper.text())).toContain(
        'Container scanning detected 2 potential vulnerabilities 1 Critical 1 High and 0 Others',
      );
    });
  });

  describe('dependency scanning reports', () => {
    beforeEach(() => {
      mock.onGet(DEPENDENCY_SCANNING_DIFF_ENDPOINT).reply(200, dependencyScanningDiffSuccessMock);

      createWrapper({
        ...props,
        enabledReports: {
          dependencyScanning: true,
        },
      });

      return waitForMutation(wrapper.vm.$store, types.RECEIVE_DEPENDENCY_SCANNING_DIFF_SUCCESS);
    });

    it('should set setDependencyScanningDiffEndpoint', () => {
      expect(wrapper.vm.dependencyScanning.paths.diffEndpoint).toEqual(
        DEPENDENCY_SCANNING_DIFF_ENDPOINT,
      );
    });

    it('should display the correct numbers of vulnerabilities', () => {
      expect(trimText(wrapper.vm.$el.textContent)).toContain(
        'Dependency scanning detected 2 potential vulnerabilities 1 Critical 1 High and 0 Others',
      );
    });
  });

  describe('dast reports', () => {
    beforeEach(() => {
      mock.onGet(DAST_DIFF_ENDPOINT).reply(200, {
        ...dastDiffSuccessMock,
        base_report_out_of_date: true,
      });

      createWrapper({
        ...props,
        enabledReports: {
          dast: true,
        },
      });

      return waitForMutation(wrapper.vm.$store, types.RECEIVE_DAST_DIFF_SUCCESS);
    });

    it('should set setDastDiffEndpoint', () => {
      expect(wrapper.vm.dast.paths.diffEndpoint).toEqual(DAST_DIFF_ENDPOINT);
    });

    it('should display the correct numbers of vulnerabilities', () => {
      expect(trimText(wrapper.vm.$el.textContent)).toContain(
        'DAST detected 1 potential vulnerability 1 Critical 0 High and 0 Others',
      );
    });

    it('shows the scanned URLs count and opens a modal', async () => {
      const jobLink = wrapper.find('[data-testid="dast-ci-job-link"]');

      expect(wrapper.text()).toContain('211 URLs scanned');
      expect(jobLink.exists()).toBe(true);
      expect(jobLink.text()).toBe('View details');

      jobLink.vm.$emit('click');
      await wrapper.vm.$nextTick();

      expect(glModalDirective).toHaveBeenCalled();
    });

    it('does not show scanned resources info if there is 0 scanned URL', () => {
      mock.onGet(DAST_DIFF_ENDPOINT).reply(200, {
        ...dastDiffSuccessMock,
        base_report_out_of_date: true,
      });

      // set scanned urls count to 0
      const summaryWithoutUrls = {
        ...defaultDastSummary,
        scannedResourcesCount: 0,
      };

      createWrapper(
        {
          ...props,
          enabledReports: {
            dast: true,
          },
        },
        {
          data: {
            dastSummary: summaryWithoutUrls,
          },
        },
      );

      return waitForMutation(wrapper.vm.$store, types.RECEIVE_DAST_DIFF_SUCCESS).then(() => {
        expect(wrapper.text()).not.toContain('0 URLs scanned');
        expect(wrapper.find('[data-testid="dast-ci-job-link"]').exists()).toBe(false);
      });
    });

    it('show download option when scanned resources are not available', () => {
      mock.onGet(DAST_DIFF_ENDPOINT).reply(200, {
        ...dastDiffSuccessMock,
        base_report_out_of_date: true,
      });

      const summaryWithoutScannedResources = {
        scannedResourcesCsvPath: 'http://test',
      };

      createWrapper(
        {
          ...props,
          enabledReports: {
            dast: true,
          },
        },
        {
          data: {
            dastSummary: summaryWithoutScannedResources,
          },
        },
      );

      return waitForMutation(wrapper.vm.$store, types.RECEIVE_DAST_DIFF_SUCCESS).then(() => {
        const findDownloadLink = wrapper.find('[data-testid="download-link"]');

        expect(findDownloadLink.vm.$el.querySelector('[data-testid="download-icon"]')).toExist();
        expect(findDownloadLink.exists()).toBe(true);
        expect(findDownloadLink.attributes('href')).toBe('http://test');
      });
    });
  });

  describe('secret scanning reports', () => {
    const initSecretScan = (isEnabled = true) => {
      mock.onGet(SECRET_DETECTION_DIFF_ENDPOINT).reply(200, secretScanningDiffSuccessMock);

      createWrapper({
        ...props,
        enabledReports: {
          secretDetection: isEnabled,
        },
      });

      return waitForMutation(
        wrapper.vm.$store,
        `secretDetection/${secretDetectionTypes.RECEIVE_DIFF_SUCCESS}`,
      );
    };

    describe('enabled', () => {
      beforeEach(() => {
        return initSecretScan();
      });

      it('should render the component', () => {
        expect(wrapper.find('[data-testid="secret-scan-report"]').exists()).toBe(true);
      });

      it('should set diffEndpoint', () => {
        expect(wrapper.vm.secretDetection.paths.diffEndpoint).toEqual(
          SECRET_DETECTION_DIFF_ENDPOINT,
        );
      });

      it('should display the correct numbers of vulnerabilities', () => {
        expect(trimText(wrapper.text())).toContain(
          'Secret scanning detected 2 potential vulnerabilities 1 Critical 1 High and 0 Others',
        );
      });
    });

    describe('disabled', () => {
      beforeEach(() => {
        initSecretScan(false);
      });

      it('should not render the component', () => {
        expect(wrapper.find('[data-testid="secret-scan-report"]').exists()).toBe(false);
      });
    });
  });

  describe('sast reports', () => {
    beforeEach(() => {
      mock.onGet(SAST_DIFF_ENDPOINT).reply(200, { ...sastDiffSuccessMock });

      createWrapper({
        ...props,
        enabledReports: {
          sast: true,
        },
      });

      return waitForMutation(wrapper.vm.$store, `sast/${sastTypes.RECEIVE_DIFF_SUCCESS}`);
    });

    it('should set setSastDiffEndpoint', () => {
      expect(wrapper.vm.sast.paths.diffEndpoint).toEqual(SAST_DIFF_ENDPOINT);
    });

    it('should display the correct numbers of vulnerabilities', () => {
      expect(trimText(wrapper.vm.$el.textContent)).toContain(
        'SAST detected 1 potential vulnerability 1 Critical 0 High and 0 Others',
      );
    });
  });

  describe('Out of date report', () => {
    const createComponent = (extraProp, done) => {
      mock
        .onGet(SAST_DIFF_ENDPOINT)
        .reply(200, { ...sastDiffSuccessMock, base_report_out_of_date: true });

      createWrapper({
        ...props,
        ...extraProp,
        targetBranch: 'main',
        enabledReports: {
          sast: true,
        },
      });

      waitForMutation(wrapper.vm.$store, `sast/${sastTypes.RECEIVE_DIFF_SUCCESS}`)
        .then(done)
        .catch(done.fail);
    };

    describe('with active MR', () => {
      beforeEach((done) => {
        createComponent({ mrState: mrStates.open }, done);
      });

      it('should display out of date message', () => {
        expect(wrapper.vm.$el.textContent).toContain(
          'Security report is out of date. Run a new pipeline for the target branch (main)',
        );
      });
    });

    describe('with active MR and diverged commit', () => {
      beforeEach((done) => {
        createComponent({ mrState: mrStates.open, divergedCommitsCount: 1 }, done);
      });

      it('should display out of date message', () => {
        expect(wrapper.vm.$el.textContent).toContain(
          'Security report is out of date. Please update your branch with the latest changes from the target branch (main)',
        );
      });
    });

    describe('with closed MR', () => {
      beforeEach((done) => {
        createComponent({ mrState: mrStates.closed }, done);
      });

      it('should not display out of date message', () => {
        expect(wrapper.vm.$el.textContent).not.toContain('Security report is out of date.');
      });
    });

    describe('with merged MR', () => {
      beforeEach((done) => {
        createComponent({ mrState: mrStates.merged }, done);
      });

      it('should not display out of date message', () => {
        expect(wrapper.vm.$el.textContent).not.toContain('Security report is out of date.');
      });
    });
  });

  describe('track report section expansion using Snowplow', () => {
    let trackingSpy;
    const { category, action } = trackMrSecurityReportDetails;

    beforeEach(() => {
      createWrapper(props);
      trackingSpy = mockTracking(category, wrapper.vm.$el, jest.spyOn);
    });

    afterEach(() => {
      unmockTracking();
    });

    it('tracks an event when toggled', () => {
      expect(trackingSpy).not.toHaveBeenCalled();
      findReportSection().vm.$emit('toggleEvent');
      return wrapper.vm.$nextTick().then(() => {
        expect(trackingSpy).toHaveBeenCalledWith(category, action);
      });
    });

    it('tracks an event only the first time it is toggled', () => {
      const report = findReportSection();

      expect(trackingSpy).not.toHaveBeenCalled();
      report.vm.$emit('toggleEvent');
      return wrapper.vm
        .$nextTick()
        .then(() => {
          expect(trackingSpy).toHaveBeenCalledWith(category, action);
          expect(trackingSpy).toHaveBeenCalledTimes(1);
          report.vm.$emit('toggleEvent');
        })
        .then(wrapper.vm.$nextTick())
        .then(() => {
          expect(trackingSpy).toHaveBeenCalledTimes(1);
        });
    });
  });
});
