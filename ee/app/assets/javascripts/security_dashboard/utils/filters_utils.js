const gl = 'GitLab';
const createDisplayName = (name, vendor = gl) => `${name} - ${vendor}`;

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
 *     "SAST": { vendor: "GitLab", reportType: "SAST", externalIds: ["brakeman", "gosec"],
 *   },
 *   "Whitesource": {
 *     "SAST": { vendor: "Whitesource", reportType: "SAST", externalIds: ["whitesource_sast"],
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
      externalIds: [],
    };

    acc[vendor][reportType].externalIds.push(externalId);

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
 *      "displayName": "SAST - WHITESOURCE",
 *      "name": "SAST",
 *      "id": "sast",
 *      "vendor": "WHITESOURCE",
 *      "scanners": ["whitesource_sast"]
 *   },
 * ]
 */
export const createCustomFilters = (reportTypes, specificFilters) =>
  Object.keys(specificFilters).reduce((filters, vendor) => {
    if (vendor !== gl) {
      const newFilters = Object.values(specificFilters[vendor]).reduce((acc, filter) => {
        const { reportType: id, externalIds: scanners } = filter;
        const name = reportTypes[id.toLowerCase()];
        const customFilter = {
          displayName: createDisplayName(name, vendor),
          id,
          name,
          scanners,
          vendor,
        };

        acc.push(customFilter);
        return acc;
      }, []);
      // eslint-disable-next-line no-param-reassign
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
 *      "displayName": "SAST - GitLab",
 *      "name": "SAST",
 *      "id": "sast",
 *      "scanners": ["brakeman", "gosec"]
 *   },
 * ]
 */
export const createGitlabFilters = (reportTypes, specificFilters) =>
  Object.entries(reportTypes).reduce((acc, [id, name]) => {
    let scanners = [];
    if (specificFilters[gl] && specificFilters[gl][id.toUpperCase()]) {
      scanners = specificFilters[gl][id.toUpperCase()].externalIds;
    }

    const filter = {
      displayName: createDisplayName(name),
      id: id.toUpperCase(),
      name,
      vendor: gl,
      scanners,
    };

    acc.push(filter);
    return acc;
  }, []);

export default {};
