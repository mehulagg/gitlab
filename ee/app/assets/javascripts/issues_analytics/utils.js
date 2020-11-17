/**
 * This util method takes the global page filters and transforms parameters which
 * are not standardized between the internal issue analytics api and the public
 * issues api.
 *
 * @param {Object} filters the global filters used to fetch issues data
 *
 * @returns {Object} the transformed filters for the public api
 */
export const transformFilters = ({
  label_name: labels = null,
  milestone_title: milestone = null,
  ...restOfFilters
}) => ({
  ...restOfFilters,
  labels,
  milestone,
});
