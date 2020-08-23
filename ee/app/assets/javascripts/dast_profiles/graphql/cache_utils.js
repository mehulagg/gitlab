/**
 * Appends paginated results to existing ones
 * - to be used with $apollo.queries.x.fetchMore
 *
 * @param key
 * @returns {function(*, {fetchMoreResult: *}): *}
 */
export const appendToPreviousResult = key => (previousResult, { fetchMoreResult }) => {
  const newResult = { ...fetchMoreResult };
  const previousEdges = previousResult.project[key].edges;
  const newEdges = newResult.project[key].edges;

  newResult.project[key].edges = [...previousEdges, ...newEdges];

  return newResult;
};

/**
 * Removes profile with given id from the cache and writes the result to it
 *
 * @param key
 * @param store
 * @param queryBody
 * @param profileToBeDeletedId
 */
export const removeProfile = ({ profileId, profileType, store, queryBody }) => {
  const data = store.readQuery(queryBody);

  data.project[profileType].edges = data.project[profileType].edges.filter(({ node }) => {
    return node.id !== profileId;
  });

  store.writeQuery({ ...queryBody, data });
};

/**
 * Returns an object representing a optimistic response for site-profile deletion
 *
 * @returns {{__typename: string, dastSiteProfileDelete: {__typename: string, errors: []}}}
 */
export const dastProfilesDeleteResponse = profileType => ({
  // eslint-disable-next-line @gitlab/require-i18n-strings
  __typename: 'Mutation',
  [`${profileType}Delete`]: {
    __typename:
      profileType === 'siteProfile'
        ? 'DastSiteProfileDeletePayload'
        : 'DastScannerProfileDeletePayload',
    errors: [],
  },
});
