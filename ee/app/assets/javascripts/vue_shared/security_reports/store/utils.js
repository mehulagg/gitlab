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
 * Takes an object of options and returns an externalized string representing
 * the critical, high, and other severity vulnerabilities for a given report.
 *
 * The resulting string _may_ still contain sprintf-style placeholders. These
 * are left in place so they can be replaced with markup, via the
 * SecuritySummary component.
 * @param {{reportType: string, status: string, critical: number, high: number, other: number}} options
 * @returns {string}
 */
export const groupedTextBuilder = ({
  reportType = '',
  status = '',
  critical = 0,
  high = 0,
  other = 0,
} = {}) => {
  // This approach uses bitwise (ish) flags to determine which vulnerabilities
  // we have, without the need for too many nested levels of if/else statements.
  //
  // Here's a video explaining how it works
  // https://youtu.be/qZzKNC7TPbA
  //
  // Here's a link to a similar approach on MDN:
  // https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Operators/Bitwise_Operators#Examples

  let options = 0;
  const HAS_CRITICAL = 1;
  const HAS_HIGH = 2;
  const HAS_OTHER = 4;
  let message;

  if (critical) {
    options += HAS_CRITICAL;
  }
  if (high) {
    options += HAS_HIGH;
  }
  if (other) {
    options += HAS_OTHER;
  }

  switch (options) {
    case HAS_CRITICAL:
      message = n__(
        '%{reportType} %{status} detected %{criticalStart}%{critical} critical%{criticalEnd} severity vulnerability.',
        '%{reportType} %{status} detected %{criticalStart}%{critical} critical%{criticalEnd} severity vulnerabilities.',
        critical,
      );
      break;

    case HAS_HIGH:
      message = n__(
        '%{reportType} %{status} detected %{highStart}%{high} high%{highEnd} severity vulnerability.',
        '%{reportType} %{status} detected %{highStart}%{high} high%{highEnd} severity vulnerabilities.',
        high,
      );
      break;

    case HAS_OTHER:
      message = n__(
        '%{reportType} %{status} detected %{other} vulnerability.',
        '%{reportType} %{status} detected %{other} vulnerabilities.',
        other,
      );
      break;

    case HAS_CRITICAL + HAS_HIGH:
      message = __(
        '%{reportType} %{status} detected %{criticalStart}%{critical} critical%{criticalEnd} and %{highStart}%{high} high%{highEnd} severity vulnerabilities.',
      );
      break;

    case HAS_CRITICAL + HAS_OTHER:
      message = __(
        '%{reportType} %{status} detected %{criticalStart}%{critical} critical%{criticalEnd} severity vulnerabilities out of %{total}.',
      );
      break;

    case HAS_HIGH + HAS_OTHER:
      message = __(
        '%{reportType} %{status} detected %{highStart}%{high} high%{highEnd} severity vulnerabilities out of %{total}.',
      );
      break;

    case HAS_CRITICAL + HAS_HIGH + HAS_OTHER:
      message = __(
        '%{reportType} %{status} detected %{criticalStart}%{critical} critical%{criticalEnd} and %{highStart}%{high} high%{highEnd} severity vulnerabilities out of %{total}.',
      );
      break;

    default:
      message = __('%{reportType} %{status} detected no vulnerabilities.');
  }

  return sprintf(message, {
    reportType,
    status,
    critical,
    high,
    other,
    total: critical + high + other,
  }).replace(/\s\s+/g, ' ');
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
    return errorMessage;
  }

  if (report.isLoading) {
    return loadingMessage;
  }

  return groupedTextBuilder({
    reportType,
    ...countVulnerabilities(report.newIssues),
  });
};
