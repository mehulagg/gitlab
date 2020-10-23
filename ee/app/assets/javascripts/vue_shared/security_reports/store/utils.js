import { CRITICAL, HIGH } from 'ee/security_dashboard/store/modules/vulnerabilities/constants';
import { __, n__, sprintf } from '~/locale';

/**
 * Returns the index of an issue in given list
 * @param {Array} issues
 * @param {Object} issue
 */
export const findIssueIndex = (issues, issue) =>
  issues.findIndex(el => el.project_fingerprint === issue.project_fingerprint);

/**
 * Returns given vulnerability enriched with the corresponding
 * feedback (`dismissal` or `issue` type)
 * @param {Object} vulnerability
 * @param {Array} feedback
 */
export const enrichVulnerabilityWithFeedback = (vulnerability, feedback = []) =>
  feedback
    .filter(fb => fb.project_fingerprint === vulnerability.project_fingerprint)
    .reduce((vuln, fb) => {
      if (fb.feedback_type === 'dismissal') {
        return {
          ...vuln,
          isDismissed: true,
          dismissalFeedback: fb,
        };
      }
      if (fb.feedback_type === 'issue' && fb.issue_iid) {
        return {
          ...vuln,
          hasIssue: true,
          issue_feedback: fb,
        };
      }
      if (fb.feedback_type === 'merge_request' && fb.merge_request_iid) {
        return {
          ...vuln,
          hasMergeRequest: true,
          merge_request_feedback: fb,
        };
      }
      return vuln;
    }, vulnerability);

/**
 * Takes an object of options and returns the object with an externalized string representing
 * the critical, high, and other severity vulnerabilities for a given report.
 *
 * The resulting string _may_ still contain sprintf-style placeholders. These
 * are left in place so they can be replaced with markup, via the
 * SecuritySummary component.
 * @param {{reportType: string, status: string, critical: number, high: number, other: number}} options
 * @returns {Object} the parameters with an externalized string
 */
export const groupedTextBuilder = ({
  reportType = '',
  status = '',
  critical = 0,
  high = 0,
  other = 0,
} = {}) => {
  const total = critical + high + other;
  let message;

  if (status === 'loading') {
    message = __('Loading %{reportType} results');
  } else if (status === 'error') {
    message = __('Security scanning results pending the completion of all security jobs.');
  } else if (!total) {
    message = __('%{reportType} detected no vulnerabilities.');
  } else {
    message = __(
      '%{reportType} detected %{total} potential vulnerabilities %{criticalStart}%{critical} critical%{criticalEnd} %{highStart}%{high} high%{highEnd} and %{otherStart}%{other} Others%{otherEnd}',
    );
  }

  return {
    message: sprintf(message, {
      reportType,
      critical,
      high,
      other,
      total,
    }).replace(/\s\s+/g, ' '),
    status,
    critical,
    high,
    other,
  };
};

export const statusIcon = (loading = false, failed = false, newIssues = 0, neutralIssues = 0) => {
  if (loading) {
    return 'loading';
  }

  if (failed || newIssues > 0 || neutralIssues > 0) {
    return 'warning';
  }

  return 'success';
};

/**
 * Counts vulnerabilities.
 * Returns the amount of critical, high, and other vulnerabilities.
 *
 * @param {Array} vulnerabilities The raw vulnerabilities to parse
 * @returns {{critical: number, high: number, other: number}}
 */
export const countVulnerabilities = (vulnerabilities = []) => {
  const critical = vulnerabilities.filter(vuln => vuln.severity === CRITICAL).length;
  const high = vulnerabilities.filter(vuln => vuln.severity === HIGH).length;
  const other = vulnerabilities.length - critical - high;

  return {
    critical,
    high,
    other,
  };
};

/**
 * Generates a report message based on some of the report parameters and supplied messages.
 *
 * @param {Object} report The report to generate the text for
 * @param {String} reportType The report type. e.g. SAST
 * @param {String} errorMessage The message to show if there's an error in the report
 * @param {String} loadingMessage The message to show if the report is still loading
 * @returns {String}
 */
export const groupedReportText = (report, reportType, errorMessage, loadingMessage) => {
  if (report.hasError) {
    return { message: errorMessage };
  }

  if (report.isLoading) {
    return { message: loadingMessage };
  }

  return groupedTextBuilder({
    reportType,
    ...countVulnerabilities(report.newIssues),
  });
};

/**
 * Generates the added, fixed, and existing vulnerabilities from the API report.
 *
 * @param {Object} diff The original reports.
 * @param {Object} enrichData Feedback data to add to the reports.
 * @returns {Object}
 */
export const parseDiff = (diff, enrichData) => {
  const enrichVulnerability = vulnerability => ({
    ...enrichVulnerabilityWithFeedback(vulnerability, enrichData),
    category: vulnerability.report_type,
    title: vulnerability.message || vulnerability.name,
  });

  return {
    added: diff.added ? diff.added.map(enrichVulnerability) : [],
    fixed: diff.fixed ? diff.fixed.map(enrichVulnerability) : [],
    existing: diff.existing ? diff.existing.map(enrichVulnerability) : [],
  };
};
