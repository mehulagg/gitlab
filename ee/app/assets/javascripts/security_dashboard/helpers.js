import isPlainObject from 'lodash/isPlainObject';
import { VULNERABILITY_STATES } from 'ee/vulnerabilities/constants';
import { s__, __ } from '~/locale';
import { convertObjectPropsToSnakeCase } from '~/lib/utils/common_utils';
import { ALL, BASE_FILTERS } from './store/modules/filters/constants';
import { REPORT_TYPES, SEVERITY_LEVELS } from './store/constants';
import { createCustomFilters, createGitlabFilters } from './utils/filters_utils';

const allReportTypeFilter = { title: 'All', options: [BASE_FILTERS.report_type] };

/**
 * Parses the available report types and specific scanner filters and creates the report type
 * filters with the links to the appropriate scanner filters
 * @param {Object} reportTypes all the different report types supported by GitLab
 * @param {Object} specificFilters the project specific filters retrieved
 * @returns {Object} the reportType and scanner options arrays
 */
const parseReportTypes = (reportTypes, specificFilters = {}) => {
  const customFilters = createCustomFilters(reportTypes, specificFilters);
  const gitlabFilters = createGitlabFilters(reportTypes, specificFilters);
  return { gitlabFilters, customFilters };
};

const parseOptions = obj =>
  Object.entries(obj).map(([id, name]) => ({ id: id.toUpperCase(), name }));

export const mapProjects = projects =>
  projects.map(p => ({ id: p.id.split('/').pop(), name: p.name }));

/**
 * Modifies the existing reportType and scanner filters with project specific filters
 *
 * @param {Array} filters the exisiting filters
 * @param {Object} specificFilters the map of project-specific filters
 * @returns {Array} the updated filters
 */
export const modifyReportTypeFilter = (filters, specificFilters) => {
  console.log('modifyReportTypeAndScannerFilters filters: ', filters);
  const { gitlabFilters, customFilters } = parseReportTypes(REPORT_TYPES, specificFilters);
  // eslint-disable-next-line no-param-reassign
  filters.options = [allReportTypeFilter, gitlabFilters, ...customFilters];
  return filters;
};

export const initFirstClassVulnerabilityFilters = projects => {
  const { gitlabFilters } = parseReportTypes(REPORT_TYPES);

  const filters = [
    {
      name: s__('SecurityReports|Status'),
      id: 'state',
      options: [
        { id: ALL, name: s__('VulnerabilityStatusTypes|All') },
        ...parseOptions(VULNERABILITY_STATES),
      ],
      selection: new Set([ALL]),
      component: 'dashboard',
    },
    {
      name: s__('SecurityReports|Severity'),
      id: 'severity',
      options: [BASE_FILTERS.severity, ...parseOptions(SEVERITY_LEVELS)],
      selection: new Set([ALL]),
      component: 'dashboard',
    },
    {
      name: s__('Reports|Scanner'),
      id: 'reportType',
      options: [allReportTypeFilter, gitlabFilters],
      selection: new Set([ALL]),
      component: 'scanner',
    },
  ];

  if (Array.isArray(projects)) {
    filters.push({
      name: s__('SecurityReports|Project'),
      id: 'projectId',
      options: [BASE_FILTERS.project_id, ...mapProjects(projects)],
      selection: new Set([ALL]),
      component: 'dashboard',
    });
  }

  return filters;
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
