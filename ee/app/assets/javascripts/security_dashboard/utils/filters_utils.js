const gl = 'GitLab';
const createName = (name, vendor = gl) => `${name} - ${vendor}`;
const createReportTypeScannerId = (reportType, vendor = gl) => `${reportType}-${vendor}`;

/**
 * Parses the returned data from the project-specific scanners GraphQL query into a format
 * more usable for searching with
 * @param {Array} nodes the list of project-specific filter objects
 * Example nodes parameter
 * [
 *   {
 *     "externalId": "brakeman",
 *     "name": "Brakeman",
 *     "reportType": "SAST",
 *     "vendor": "GitLab"
 *   },
 *   {
 *     "externalId": "gosec",
 *     "name": "gosec",
 *     "reportType": "SAST",
 *     "vendor": "GitLab"
 *   },
 *   {
 *     "externalId": "bundler_audit",
 *     "name": "bundler_audit",
 *     "reportType": "DEPENDENCY_SCANNING",
 *     "vendor": "GitLab"
 *   },
 *   {
 *     "externalId": "whitesource_sast",
 *     "name": "whitesource_sast",
 *     "reportType": "SAST",
 *     "vendor": "Whitesource"
 *   },
 * ]
 * @returns {Object} refactored data to be used for searching against
 * Example returned value
 * {
 *   "GitLab": {
 *     "SAST": { vendor: "GitLab", reportType: "SAST", scanners: ["brakeman", "gosec"],
 *     "DEPENDENCY_SCANNING": { vendor: "GitLab", reportType: "DEPENDENCY_SCANNING", scanners: ["bundler_audit"],
 *   },
 *   "Whitesource": {
 *     "SAST": { vendor: "Whitesource", reportType: "SAST", scanners: ["whitesource_sast"],
 *   }
 * }
 */
export const parseSpecificFilters = nodes => {
  return nodes.reduce((acc, curr) => {
    const { externalId, reportType } = curr;
    const vendor = curr.vendor || gl;

    acc[vendor] = acc[vendor] || {};
    acc[vendor][reportType] = acc[vendor][reportType] || {
      vendor,
      reportType,
      scanners: [],
    };

    acc[vendor][reportType].scanners.push(externalId);

    return acc;
  }, {});
};

/**
 * Creates filter options from custom scanners
 * @param {Object} reportTypes all possible report types
 * @param {Object} specificFilters data returned from parseSpecificFilters method above
 * @returns {Object} custom filters with corresponding linked filters
 * Example return
 * [
 *   {
 *      "id": "dependency_scanning-Custom Scanner",
 *      "name": "Dependency Scanning - Custom Scanner",
 *      "reportType": "DEPENDENCY_SCANNING"
 *      "scanners": ["custom_scanner_dependency_scanning-01", "custom_scanner_dependency_scanning-02"]
 *      "vendor": "Custom Scanner",
 *   },
 *   {
 *      "id": "SAST-Custom Scanner",
 *      "name": "SAST - Custom Scanner",
 *      "reportType": "SAST"
 *      "scanners": ["custom_scanner_sast"]
 *      "vendor": "Custom Scanner",
 *   },
 * ]
 */
export const createCustomFilters = (reportTypes, specificFilters) =>
  Object.keys(specificFilters).reduce((filters, vendor) => {
    if (vendor !== gl) {
      const newFilters = Object.values(specificFilters[vendor]).reduce((acc, filter) => {
        const { reportType, scanners } = filter;
        const name = reportTypes[reportType.toLowerCase()];
        const customFilter = {
          id: createReportTypeScannerId(reportType, vendor),
          name: createName(name, vendor),
          reportType,
          scanners,
          vendor,
        };

        acc.push(customFilter);
        return acc;
      }, []);
      filters.push(...newFilters);
    }
    return filters;
  }, []);

/**
 * Creates filter options from GitLab scanners
 * @param {Object} reportTypes all possible report types
 * @param {Object} specificFilters data returned from parseSpecificFilters method above
 * @returns {Object} GitLab filters with corresponding linked filters
 * Example return
 * [
 *   {
 *      "id": "dependency_scanning-GitLab",
 *      "name": "Dependency Scanning - GitLab",
 *      "reportType": "DEPENDENCY_SCANNING"
 *      "scanners": ["bundler_audit"]
 *      "vendor": "GitLab",
 *   },
 *   {
 *      "id": "sast-GitLab",
 *      "name": "SAST - GitLab",
 *      "reportType": "sast"
 *      "scanners": ["brakeman", "gosec"]
 *      "vendor": "GitLab",
 *   },
 * ]
 */
export const createGitlabFilters = (reportTypes, specificFilters) =>
  Object.entries(reportTypes).reduce((acc, [reportType, name]) => {
    let scanners = [];
    const vendor = gl;

    if (specificFilters[gl] && specificFilters[gl][reportType.toUpperCase()]) {
      scanners = specificFilters[gl][reportType.toUpperCase()].scanners;
    }

    const filter = {
      id: createReportTypeScannerId(reportType),
      name: createName(name),
      reportType: reportType.toUpperCase(),
      scanners,
      vendor,
    };

    acc.push(filter);
    return acc;
  }, []);

export default {};
