import isPlainObject from 'lodash/isPlainObject';
import { ALL, BASE_FILTERS } from 'ee/security_dashboard/store/modules/filters/constants';
import { REPORT_TYPES, SEVERITY_LEVELS } from 'ee/security_dashboard/store/constants';
import { VULNERABILITY_STATES } from 'ee/vulnerabilities/constants';
import { convertObjectPropsToSnakeCase } from '~/lib/utils/common_utils';
import { s__, __ } from '~/locale';

const parseOptions = obj =>
  Object.entries(obj).map(([id, name]) => ({ id: id.toUpperCase(), name }));

export const mapProjects = projects =>
  projects.map(p => ({ id: p.id.split('/').pop(), name: p.name }));

export const filters = {
  stateFilter: {
    name: s__('SecurityReports|Status'),
    id: 'state',
    allOption: { id: ALL, name: s__('VulnerabilityStatusTypes|All') },
    options: parseOptions(VULNERABILITY_STATES),
  },

  severityFilter: {
    name: s__('SecurityReports|Severity'),
    id: 'severity',
    allOption: BASE_FILTERS.severity,
    options: parseOptions(SEVERITY_LEVELS),
  },

  scannerFilter: {
    name: s__('Reports|Scanner'),
    id: 'reportType',
    allOption: BASE_FILTERS.report_type,
    options: parseOptions(REPORT_TYPES),
  },

  getProjectFilter: projects => {
    if (!projects?.length) return undefined;

    return {
      name: s__('SecurityReports|Project'),
      id: 'projectId',
      allOption: BASE_FILTERS.project_id,
      options: mapProjects(projects),
    };
  },
};

/**
 * Provided a security reports summary from the GraphQL API, this returns an array of arrays
 * representing a properly formatted report ready to be displayed in the UI. Each sub-array consists
 * of the user-friend report's name, and the summary's payload. Note that summary entries are
 * considered empty and are filtered out of the return if the payload is `null` or don't include
 * a vulnerabilitiesCount property. Report types whose name can't be matched to a user-friendly
 * name are filtered out as well.
 *
 * Take the following summary for example:
 * {
 *   containerScanning: { vulnerabilitiesCount: 123 },
 *   invalidReportType: { vulnerabilitiesCount: 123 },
 *   dast: null,
 * }
 *
 * The formatted summary would look like this:
 * [
 *   ['containerScanning', { vulnerabilitiesCount: 123 }]
 * ]
 *
 * Note that `invalidReportType` was filtered out as it can't be matched with a user-friendly name,
 * and the DAST report was omitted because it's empty (`null`).
 *
 * @param {Object} rawSummary
 * @returns {Array}
 */
export const getFormattedSummary = (rawSummary = {}) => {
  if (!isPlainObject(rawSummary)) {
    return [];
  }
  // Convert keys to snake case so they can be matched against REPORT_TYPES keys for translation
  const snakeCasedSummary = convertObjectPropsToSnakeCase(rawSummary);
  // Convert object to an array of entries to make it easier to loop through
  const summaryEntries = Object.entries(snakeCasedSummary);
  // Filter out empty entries as we don't want to display those in the summary
  const withoutEmptyEntries = summaryEntries.filter(
    ([, scanSummary]) => scanSummary?.vulnerabilitiesCount !== undefined,
  );
  // Replace keys with translations found in REPORT_TYPES if available
  const formattedEntries = withoutEmptyEntries.map(([scanType, scanSummary]) => {
    const name = REPORT_TYPES[scanType];
    return name ? [name, scanSummary] : null;
  });
  // Filter out keys that could not be matched with any translation and are thus considered invalid
  return formattedEntries.filter(entry => entry !== null);
};

/**
 * We have disabled loading hasNextPage from GraphQL as it causes timeouts in database,
 * instead we have to calculate that value based on the existence of endCursor. When endCursor
 * is empty or has null value, that means that there is no next page to be loaded from GraphQL API.
 *
 * @param {Object} pageInfo
 * @returns {Object}
 */
export const preparePageInfo = pageInfo => {
  return { ...pageInfo, hasNextPage: Boolean(pageInfo?.endCursor) };
};

export const createProjectLoadingError = () => __('An error occurred while retrieving projects.');

export default () => ({});
