const gl = 'GitLab';

const createLinkedFilter = (linkId, id = []) => ({ linkId, id });
const createDisplayName = (name, vendor = gl) => `${name} - ${vendor}`;
const createLinkId = (id, vendor = gl) => `${id}_${vendor.toLowerCase()}`;

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
 *     "SAST": ["brakeman", "gosec"],
 *   },
 *   "Whitesource": {
 *     "SAST": ["whitesource_sast"],
 *   }
 * }
 */
export const parseSpecificFilters = nodes => {
  return nodes.reduce((acc, curr) => {
    const { externalId, reportType } = curr;
    const vendor = curr.vendor || gl;

    if (!acc[vendor]) {
      acc[vendor] = {};
    }

    if (!acc[vendor][reportType]) {
      acc[vendor][reportType] = {
        vendor,
        reportType,
        externalIds: [externalId],
      };
    } else {
      acc[vendor][reportType].externalIds.push(externalId);
    }

    return acc;
  }, {});
};

/**
 * Creates filter options from custom scanners
 * @param {Object} reportTypes all possible report types
 * @param {Object} specificFilters data returned from parseSpecificFilters method above
 * @returns {Object} custom filters with corresponding linked filters
 * Example return
 * {
 *   filters: [
 *     {
 *        "displayName": "SAST - WHITESOURCE",
 *        "name": "SAST",
 *        "id": "sast",
 *        "link": { id: 'scanner', linkId: 'sast_whitesource'}
 *     },
 *   ],
 *   linkedFilters: [
 *     { linkId: 'sast_whitesource', id: ["whitesource_sast"], }
 *   ]
 * }
 */
export const createCustomFilters = (reportTypes, specificFilters) =>
  Object.keys(specificFilters).reduce(
    (all, vendor) => {
      if (vendor !== gl) {
        const newFilters = Object.values(specificFilters[vendor]).reduce(
          (acc, filter) => {
            const { reportType: id, externalIds } = filter;
            const name = reportTypes[id.toLowerCase()];
            const linkId = createLinkId(id, vendor);
            const customFilter = {
              displayName: createDisplayName(name, vendor),
              id,
              name,
              link: { id: 'scanner', linkId },
            };

            const linkedFilter = createLinkedFilter(linkId, externalIds);

            acc.customFilters.push(customFilter);
            acc.linkedFilters.push(linkedFilter);
            return acc;
          },
          { customFilters: [], linkedFilters: [] },
        );
        all.filters.push(...newFilters.customFilters);
        all.linkedFilters.push(...newFilters.linkedFilters);
      }
      return all;
    },
    { filters: [], linkedFilters: [] },
  );

/**
 * Creates filter options from GitLab scanners
 * @param {Object} reportTypes all possible report types
 * @param {Object} specificFilters data returned from parseSpecificFilters method above
 * @returns {Object} GitLab filters with corresponding linked filters
 * Example return
 * {
 *   filters: [
 *     {
 *        "displayName": "SAST - GitLab",
 *        "name": "SAST",
 *        "id": "sast",
 *        "link": { id: 'scanner', linkId: 'sast_gitlab'}
 *     },
 *   ],
 *   linkedFilters: [
 *     { linkId: 'sast_gitlab', id: ["brakeman", "gosec"], }
 *   ]
 * }
 */
export const createGitlabFilters = (reportTypes, specificFilters) =>
  Object.entries(reportTypes).reduce(
    (acc, [id, name]) => {
      const linkId = createLinkId(id);
      const filter = {
        displayName: createDisplayName(name),
        id: id.toUpperCase(),
        name,
        link: { id: 'scanner', linkId },
      };

      const linkedFilter = createLinkedFilter(linkId);
      if (specificFilters[gl] && specificFilters[gl][id.toUpperCase()]) {
        linkedFilter.id = specificFilters[gl][id.toUpperCase()].externalIds;
      }

      acc.filters.push(filter);
      acc.linkedFilters.push(linkedFilter);
      return acc;
    },
    { filters: [], linkedFilters: [] },
  );
export default {};
