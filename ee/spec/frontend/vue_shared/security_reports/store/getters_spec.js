import createState from 'ee/vue_shared/security_reports/store/state';
import createSastState from 'ee/vue_shared/security_reports/store/modules/sast/state';
import {
  groupedContainerScanningText,
  groupedDastText,
  groupedDependencyText,
  groupedSecretScanningText,
  groupedCoverageFuzzingText,
  groupedSummaryText,
  allReportsHaveError,
  noBaseInAllReports,
  areReportsLoading,
  containerScanningStatusIcon,
  dastStatusIcon,
  dependencyScanningStatusIcon,
  anyReportHasError,
  summaryCounts,
  isBaseSecurityReportOutOfDate,
  canCreateIssue,
  canCreateMergeRequest,
  canDismissVulnerability,
} from 'ee/vue_shared/security_reports/store/getters';
import {
  CRITICAL,
  HIGH,
  MEDIUM,
  LOW,
} from 'ee/security_dashboard/store/modules/vulnerabilities/constants';

const MOCK_PATH = 'fake/path.json';

const generateVuln = severity => ({ severity });

describe('Security reports getters', () => {
  let state = {};

  beforeEach(() => {
    state = createState();
    state.sast = createSastState();
  });

  describe.each`
    name                     | scanner                 | getter
    ${'Secret scanning'}     | ${'secretScanning'}     | ${groupedSecretScanningText}
    ${'Dependency scanning'} | ${'dependencyScanning'} | ${groupedDependencyText}
    ${'Container scanning'}  | ${'containerScanning'}  | ${groupedContainerScanningText}
    ${'DAST'}                | ${'dast'}               | ${groupedDastText}
    ${'Coverage fuzzing'}    | ${'coverageFuzzing'}    | ${groupedCoverageFuzzingText}
  `('grouped text for $name', ({ name, scanner, getter }) => {
    describe('with no issues', () => {
      it('returns no issues text', () => {
        expect(getter(state)).toEqual(`${name} detected no vulnerabilities.`);
      });
    });

    it.each`
      vulnerabilities                                     | message
      ${[]}                                               | ${`${name} detected no vulnerabilities.`}
      ${[generateVuln(CRITICAL), generateVuln(CRITICAL)]} | ${`${name} detected %{criticalStart}2 critical%{criticalEnd} severity vulnerabilities.`}
      ${[generateVuln(HIGH), generateVuln(HIGH)]}         | ${`${name} detected %{highStart}2 high%{highEnd} severity vulnerabilities.`}
      ${[generateVuln(LOW), generateVuln(MEDIUM)]}        | ${`${name} detected 2 vulnerabilities.`}
      ${[generateVuln(CRITICAL), generateVuln(HIGH)]}     | ${`${name} detected %{criticalStart}1 critical%{criticalEnd} and %{highStart}1 high%{highEnd} severity vulnerabilities.`}
      ${[generateVuln(CRITICAL), generateVuln(LOW)]}      | ${`${name} detected %{criticalStart}1 critical%{criticalEnd} severity vulnerabilities out of 2.`}
    `('should build the message as "$message"', ({ vulnerabilities, message }) => {
      state[scanner].newIssues = vulnerabilities;
      expect(getter(state)).toEqual(message);
    });
  });

  describe('summaryCounts', () => {
    it('returns 0 count for empty state', () => {
      expect(summaryCounts(state)).toEqual({
        critical: 0,
        high: 0,
        other: 0,
      });
    });

    describe('combines all reports', () => {
      it('of the same severity', () => {
        state.containerScanning.newIssues = [generateVuln(CRITICAL)];
        state.dast.newIssues = [generateVuln(CRITICAL)];
        state.dependencyScanning.newIssues = [generateVuln(CRITICAL)];
        state.coverageFuzzing.newIssues = [generateVuln(CRITICAL)];

        expect(summaryCounts(state)).toEqual({
          critical: 4,
          high: 0,
          other: 0,
        });
      });

      it('of different severities', () => {
        state.containerScanning.newIssues = [generateVuln(CRITICAL)];
        state.dast.newIssues = [generateVuln(CRITICAL), generateVuln(HIGH)];
        state.dependencyScanning.newIssues = [generateVuln(LOW)];
        state.coverageFuzzing.newIssues = [generateVuln(HIGH)];

        expect(summaryCounts(state)).toEqual({
          critical: 2,
          high: 2,
          other: 1,
        });
      });
    });
  });

  describe('groupedSummaryText', () => {
    it('returns failed text', () => {
      expect(
        groupedSummaryText(state, {
          allReportsHaveError: true,
          areReportsLoading: false,
          summaryCounts: {},
        }),
      ).toEqual('Security scanning failed loading any results');
    });

    it('returns is loading text', () => {
      expect(
        groupedSummaryText(state, {
          allReportsHaveError: false,
          areReportsLoading: true,
          summaryCounts: {},
        }),
      ).toContain('(is loading)');
    });

    it('returns vulnerabilities while loading text', () => {
      expect(
        groupedSummaryText(state, {
          allReportsHaveError: false,
          areReportsLoading: true,
          summaryCounts: {
            critical: 2,
            high: 4,
          },
        }),
      ).toEqual(
        'Security scanning (is loading) detected %{criticalStart}2 critical%{criticalEnd} and %{highStart}4 high%{highEnd} severity vulnerabilities.',
      );
    });

    it('returns no new text if there are existing ones', () => {
      expect(
        groupedSummaryText(state, {
          allReportsHaveError: false,
          areReportsLoading: false,
          summaryCounts: {},
        }),
      ).toEqual('Security scanning detected no vulnerabilities.');
    });
  });

  describe('dastStatusIcon', () => {
    it('returns warning with new issues', () => {
      state.dast.newIssues = [{}];

      expect(dastStatusIcon(state)).toEqual('warning');
    });

    it('returns warning with failed report', () => {
      state.dast.hasError = true;

      expect(dastStatusIcon(state)).toEqual('warning');
    });

    it('returns success with no new issues or failed report', () => {
      expect(dastStatusIcon(state)).toEqual('success');
    });
  });

  describe('containerScanningStatusIcon', () => {
    it('returns warning with new issues', () => {
      state.containerScanning.newIssues = [{}];

      expect(containerScanningStatusIcon(state)).toEqual('warning');
    });

    it('returns warning with failed report', () => {
      state.containerScanning.hasError = true;

      expect(containerScanningStatusIcon(state)).toEqual('warning');
    });

    it('returns success with no new issues or failed report', () => {
      expect(containerScanningStatusIcon(state)).toEqual('success');
    });
  });

  describe('dependencyScanningStatusIcon', () => {
    it('returns warning with new issues', () => {
      state.dependencyScanning.newIssues = [{}];

      expect(dependencyScanningStatusIcon(state)).toEqual('warning');
    });

    it('returns warning with failed report', () => {
      state.dependencyScanning.hasError = true;

      expect(dependencyScanningStatusIcon(state)).toEqual('warning');
    });

    it('returns success with no new issues or failed report', () => {
      expect(dependencyScanningStatusIcon(state)).toEqual('success');
    });
  });

  describe('areReportsLoading', () => {
    it('returns true when any report is loading', () => {
      state.dast.isLoading = true;

      expect(areReportsLoading(state)).toEqual(true);
    });

    it('returns false when none of the reports are loading', () => {
      expect(areReportsLoading(state)).toEqual(false);
    });
  });

  describe('allReportsHaveError', () => {
    it('returns true when all reports have error', () => {
      state.sast.hasError = true;
      state.dast.hasError = true;
      state.containerScanning.hasError = true;
      state.dependencyScanning.hasError = true;
      state.secretScanning.hasError = true;
      state.coverageFuzzing.hasError = true;

      expect(allReportsHaveError(state)).toEqual(true);
    });

    it('returns false when none of the reports have error', () => {
      expect(allReportsHaveError(state)).toEqual(false);
    });

    it('returns false when one of the reports does not have error', () => {
      state.dast.hasError = false;
      state.containerScanning.hasError = true;
      state.dependencyScanning.hasError = true;
      state.secretScanning.hasError = true;

      expect(allReportsHaveError(state)).toEqual(false);
    });
  });

  describe('anyReportHasError', () => {
    it('returns true when any of the reports has error', () => {
      state.dast.hasError = true;

      expect(anyReportHasError(state)).toEqual(true);
    });

    it('returns false when none of the reports has error', () => {
      expect(anyReportHasError(state)).toEqual(false);
    });
  });

  describe('noBaseInAllReports', () => {
    it('returns true when none reports have base', () => {
      expect(noBaseInAllReports(state)).toEqual(true);
    });

    it('returns false when any of the reports has a base', () => {
      state.dast.hasBaseReport = true;

      expect(noBaseInAllReports(state)).toEqual(false);
    });
  });

  describe('isBaseSecurityReportOutOfDate', () => {
    it('returns false when none reports are out of date', () => {
      expect(isBaseSecurityReportOutOfDate(state)).toEqual(false);
    });

    it('returns true when any of the reports is out of date', () => {
      state.dast.baseReportOutofDate = true;
      expect(isBaseSecurityReportOutOfDate(state)).toEqual(true);
    });
  });

  describe('canCreateIssue', () => {
    it('returns false if no feedback path is defined', () => {
      expect(canCreateIssue(state)).toEqual(false);
    });

    it('returns true if a feedback path is defined', () => {
      state.createVulnerabilityFeedbackIssuePath = MOCK_PATH;

      expect(canCreateIssue(state)).toEqual(true);
    });
  });

  describe('canCreateMergeRequest', () => {
    it('returns false if no feedback path is defined', () => {
      expect(canCreateMergeRequest(state)).toEqual(false);
    });

    it('returns true if a feedback path is defined', () => {
      state.createVulnerabilityFeedbackMergeRequestPath = MOCK_PATH;

      expect(canCreateMergeRequest(state)).toEqual(true);
    });
  });

  describe('canDismissVulnerability', () => {
    it('returns false if no feedback path is defined', () => {
      expect(canDismissVulnerability(state)).toEqual(false);
    });

    it('returns true if a feedback path is defined', () => {
      state.createVulnerabilityFeedbackDismissalPath = MOCK_PATH;

      expect(canDismissVulnerability(state)).toEqual(true);
    });
  });
});
