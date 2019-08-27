import sha1 from 'sha1';
import _ from 'lodash-es';
import axios from 'axios';
import { stripHtml } from '~/lib/utils/text_utility';
import { n__, s__, sprintf } from '~/locale';
import Poll from '~/lib/utils/poll';
import httpStatusCodes from '~/lib/utils/http_status';

/**
 * Returns the index of an issue in given list
 * @param {Array} issues
 * @param {Object} issue
 */
export const findIssueIndex = (issues, issue) =>
  issues.findIndex(el => el.project_fingerprint === issue.project_fingerprint);

/**
 *
 * Returns whether a vulnerability has a match in an array of fixes
 *
 * @param fixes {Array} Array of fixes (vulnerability identifiers) of a remediation
 * @param vulnerability {Object} Vulnerability
 * @returns {boolean}
 */
const hasMatchingFix = (fixes, vulnerability) =>
  Array.isArray(fixes) ? fixes.some(fix => _.isMatch(vulnerability, fix)) : false;

/**
 *
 * Returns the remediations that fix the given vulnerability
 *
 * @param {Array} remediations
 * @param {Object} vulnerability
 * @returns {Array}
 */
export const findMatchingRemediations = (remediations, vulnerability) => {
  if (!Array.isArray(remediations)) {
    return [];
  }
  return remediations.filter(rem => hasMatchingFix(rem.fixes, vulnerability));
};

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
      } else if (fb.feedback_type === 'issue' && fb.issue_iid) {
        return {
          ...vuln,
          hasIssue: true,
          issue_feedback: fb,
        };
      } else if (fb.feedback_type === 'merge_request' && fb.merge_request_iid) {
        return {
          ...vuln,
          hasMergeRequest: true,
          merge_request_feedback: fb,
        };
      }
      return vuln;
    }, vulnerability);

/**
 * Generates url to repository file and highlight section between start and end lines.
 *
 * @param {Object} location
 * @param {String} pathPrefix
 * @returns {String}
 */
function fileUrl(location, pathPrefix) {
  let lineSuffix = '';
  if (location.start_line) {
    lineSuffix += `#L${location.start_line}`;
    if (location.end_line) {
      lineSuffix += `-${location.end_line}`;
    }
  }
  return `${pathPrefix}/${location.file}${lineSuffix}`;
}

/**
 * Parses issues with deprecated JSON format and adapts it to the new one.
 *
 * @param {Object} issue
 * @returns {Object}
 */
function adaptDeprecatedIssueFormat(issue) {
  // Skip issue with new format (old format does not have a location property)
  if (issue.location) {
    return issue;
  }

  const adapted = {
    ...issue,
  };

  // Add the new links property
  const links = [];
  if (!_.isEmpty(adapted.url)) {
    links.push({ url: adapted.url });
  }

  Object.assign(adapted, {
    // Add the new location property
    location: {
      file: adapted.file,
      start_line: adapted.line ? parseInt(adapted.line, 10) : undefined,
    },
    links,
  });

  return adapted;
}

/**
 *
 * Wraps old report formats (plain array of vulnerabilities).
 *
 * @param {Array|Object} report
 * @returns {Object}
 */
function adaptDeprecatedReportFormat(report) {
  if (Array.isArray(report)) {
    return {
      vulnerabilities: report,
      remediations: [],
    };
  }

  return report;
}

/**
 * Parses SAST results into a common format to allow to use the same Vue component.
 *
 * @param {Array|Object} report
 * @param {Array} feedback
 * @param {String} path
 * @returns {Array}
 */
export const parseSastIssues = (report = [], feedback = [], path = '') =>
  adaptDeprecatedReportFormat(report).vulnerabilities.map(issue => {
    const parsed = {
      ...adaptDeprecatedIssueFormat(issue),
      category: 'sast',
      project_fingerprint: sha1(issue.cve),
      title: issue.message,
    };

    return {
      ...parsed,
      path: parsed.location.file,
      urlPath: fileUrl(parsed.location, path),
      ...enrichVulnerabilityWithFeedback(parsed, feedback),
    };
  });

/**
 * Parses Dependency Scanning results into a common format to allow to use the same Vue component.
 *
 * @param {Array|Object} report
 * @param {Array} feedback
 * @param {String} path
 * @returns {Array}
 */
export const parseDependencyScanningIssues = (report = [], feedback = [], path = '') => {
  const { vulnerabilities, remediations } = adaptDeprecatedReportFormat(report);
  return vulnerabilities.map(issue => {
    const parsed = {
      ...adaptDeprecatedIssueFormat(issue),
      category: 'dependency_scanning',
      project_fingerprint: sha1(issue.cve || issue.message),
      title: issue.message,
    };

    const matchingRemediations = findMatchingRemediations(remediations, parsed);

    if (remediations) {
      parsed.remediations = matchingRemediations;
    }

    return {
      ...parsed,
      path: parsed.location.file,
      urlPath: fileUrl(parsed.location, path),
      ...enrichVulnerabilityWithFeedback(parsed, feedback),
    };
  });
};

/**
 * Forces the site property to be an Array in DAST reports.
 * We do this to also support single-site legacy DAST reports.
 *
 * @param {Object|Array} sites
 */
export const getDastSites = sites => (Array.isArray(sites) ? sites : [sites]);

/**
 * Parses DAST into a common format to allow to use the same Vue component.
 * DAST report is currently the straigh output from the underlying tool (ZAProxy)
 * hence the formatting happenning here.
 *
 * @param {Array} sites
 * @param {Array} feedback
 * @returns {Array}
 */
export const parseDastIssues = (sites = [], feedback = []) =>
  getDastSites(sites).reduce(
    (acc, site) => [
      ...acc,
      ...(site.alerts || []).map(issue => {
        const parsed = {
          ...issue,
          category: 'dast',
          project_fingerprint: sha1(issue.pluginid),
          title: issue.name,
          description: stripHtml(issue.desc, ' '),
          solution: stripHtml(issue.solution, ' '),
        };

        if (!_.isEmpty(issue.cweid)) {
          Object.assign(parsed, {
            identifiers: [
              {
                type: 'CWE',
                name: `CWE-${issue.cweid}`,
                value: issue.cweid,
                url: `https://cwe.mitre.org/data/definitions/${issue.cweid}.html`,
              },
            ],
          });
        }

        if (issue.riskdesc && issue.riskdesc !== '') {
          // Split riskdesc into severity and confidence.
          // Riskdesc format is: "severity (confidence)"
          const [, severity, confidence] = issue.riskdesc.match(/(.*) \((.*)\)/);
          Object.assign(parsed, {
            severity,
            confidence,
          });
        }

        return {
          ...parsed,
          ...enrichVulnerabilityWithFeedback(parsed, feedback),
        };
      }),
    ],
    [],
  );

export const getUnapprovedVulnerabilities = (issues = [], unapproved = []) =>
  issues.filter(item => unapproved.find(el => el === item.vulnerability));

export const groupedTextBuilder = ({
  reportType = '',
  paths = {},
  added = 0,
  fixed = 0,
  existing = 0,
  dismissed = 0,
  status = '',
}) => {
  let baseString = '';

  if (!paths.base && !paths.diffEndpoint) {
    if (added && !dismissed) {
      // added
      baseString = n__(
        'ciReport|%{reportType} %{status} detected %{newCount} vulnerability for the source branch only',
        'ciReport|%{reportType} %{status} detected %{newCount} vulnerabilities for the source branch only',
        added,
      );
    } else if (!added && dismissed) {
      // dismissed
      baseString = n__(
        'ciReport|%{reportType} %{status} detected %{dismissedCount} dismissed vulnerability for the source branch only',
        'ciReport|%{reportType} %{status} detected %{dismissedCount} dismissed vulnerabilities for the source branch only',
        dismissed,
      );
    } else if (added && dismissed) {
      // added & dismissed
      baseString = s__(
        'ciReport|%{reportType} %{status} detected %{newCount} new, and %{dismissedCount} dismissed vulnerabilities for the source branch only',
      );
    } else {
      // no vulnerabilities
      baseString = s__(
        'ciReport|%{reportType} %{status} detected no vulnerabilities for the source branch only',
      );
    }
  } else if (paths.head || paths.diffEndpoint) {
    if (added && !fixed && !dismissed) {
      // added
      baseString = n__(
        'ciReport|%{reportType} %{status} detected %{newCount} new vulnerability',
        'ciReport|%{reportType} %{status} detected %{newCount} new vulnerabilities',
        added,
      );
    } else if (!added && fixed && !dismissed) {
      // fixed
      baseString = n__(
        'ciReport|%{reportType} %{status} detected %{fixedCount} fixed vulnerability',
        'ciReport|%{reportType} %{status} detected %{fixedCount} fixed vulnerabilities',
        fixed,
      );
    } else if (!added && !fixed && dismissed) {
      // dismissed
      baseString = n__(
        'ciReport|%{reportType} %{status} detected %{dismissedCount} dismissed vulnerability',
        'ciReport|%{reportType} %{status} detected %{dismissedCount} dismissed vulnerabilities',
        dismissed,
      );
    } else if (added && fixed && !dismissed) {
      // added & fixed
      baseString = s__(
        'ciReport|%{reportType} %{status} detected %{newCount} new, and %{fixedCount} fixed vulnerabilities',
      );
    } else if (added && !fixed && dismissed) {
      // added & dismissed
      baseString = s__(
        'ciReport|%{reportType} %{status} detected %{newCount} new, and %{dismissedCount} dismissed vulnerabilities',
      );
    } else if (!added && fixed && dismissed) {
      // fixed & dismissed
      baseString = s__(
        'ciReport|%{reportType} %{status} detected %{fixedCount} fixed, and %{dismissedCount} dismissed vulnerabilities',
      );
    } else if (added && fixed && dismissed) {
      // added & fixed & dismissed
      baseString = s__(
        'ciReport|%{reportType} %{status} detected %{newCount} new, %{fixedCount} fixed, and %{dismissedCount} dismissed vulnerabilities',
      );
    } else if (existing) {
      baseString = s__('ciReport|%{reportType} %{status} detected no new vulnerabilities');
    } else {
      baseString = s__('ciReport|%{reportType} %{status} detected no vulnerabilities');
    }
  }

  if (!status) {
    baseString = baseString.replace('%{status}', '').replace('  ', ' ');
  }

  return sprintf(baseString, {
    status,
    reportType,
    newCount: added,
    fixedCount: fixed,
    dismissedCount: dismissed,
  });
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
 * Counts issues. Simply returns the amount of existing and fixed Issues.
 * New Issues are divided into dismissed and added.
 *
 * @param newIssues
 * @param resolvedIssues
 * @param allIssues
 * @returns {{existing: number, added: number, dismissed: number, fixed: number}}
 */
export const countIssues = ({ newIssues = [], resolvedIssues = [], allIssues = [] } = {}) => {
  const dismissed = newIssues.reduce((sum, issue) => (issue.isDismissed ? sum + 1 : sum), 0);

  return {
    added: newIssues.length - dismissed,
    dismissed,
    existing: allIssues.length,
    fixed: resolvedIssues.length,
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
  const { paths } = report;

  if (report.hasError) {
    return errorMessage;
  }

  if (report.isLoading) {
    return loadingMessage;
  }

  return groupedTextBuilder({
    ...countIssues(report),
    reportType,
    paths,
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

/**
 * Polls an endpoint untill it returns either an error or a 200.
 * Resolving or rejecting the promise accordingly.
 *
 * @param {String} endpoint the endpoint to poll.
 * @returns {Promise}
 */
export const pollUntilComplete = endpoint =>
  new Promise((resolve, reject) => {
    const eTagPoll = new Poll({
      resource: {
        getReports(url) {
          return axios.get(url);
        },
      },
      data: endpoint,
      method: 'getReports',
      successCallback: response => {
        if (response.status === httpStatusCodes.OK) {
          resolve(response);
          eTagPoll.stop();
        }
      },
      errorCallback: reject,
    });

    eTagPoll.makeRequest();
  });
