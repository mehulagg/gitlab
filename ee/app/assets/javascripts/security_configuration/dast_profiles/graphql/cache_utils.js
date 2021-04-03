import gql from 'graphql-tag';
import { produce } from 'immer';
import dastSiteProfilesQuery from 'ee/security_configuration/dast_profiles/graphql/dast_site_profiles.query.graphql';

/**
 * Appends paginated results to existing ones
 * - to be used with $apollo.queries.x.fetchMore
 *
 * @param {*} profileType
 * @returns {function(*, {fetchMoreResult: *}): *}
 */
export const appendToPreviousResult = (profileType) => (previousResult, { fetchMoreResult }) => {
  const newResult = { ...fetchMoreResult };
  const previousEdges = previousResult.project[profileType].edges;
  const newEdges = newResult.project[profileType].edges;

  newResult.project[profileType].edges = [...previousEdges, ...newEdges];

  return newResult;
};

/**
 * Removes profile with given id from the cache and writes the result to it
 *
 * @param profileId
 * @param profileType
 * @param store
 * @param queryBody
 */
export const removeProfile = ({ profileId, profileType, store, queryBody }) => {
  const sourceData = store.readQuery(queryBody);

  const data = produce(sourceData, (draftState) => {
    draftState.project[profileType].edges = draftState.project[profileType].edges.filter(
      ({ node }) => {
        return node.id !== profileId;
      },
    );
  });

  store.writeQuery({ ...queryBody, data });
};

/**
 * Returns an object representing a optimistic response for site-profile deletion
 *
 * @param mutationName
 * @param payloadTypeName
 * @returns {{[p: string]: string, __typename: string}}
 */
export const dastProfilesDeleteResponse = ({ mutationName, payloadTypeName }) => ({
  // eslint-disable-next-line @gitlab/require-i18n-strings
  __typename: 'Mutation',
  [mutationName]: {
    __typename: payloadTypeName,
    errors: [],
  },
});

export const updateSiteProfilesStatuses = ({ fullPath, normalizedTargetUrl, status, store }) => {
  const queryBody = {
    query: dastSiteProfilesQuery,
    variables: {
      fullPath,
    },
  };

  const sourceData = store.readQuery(queryBody);

  const profilesWithNormalizedTargetUrl = sourceData.project.siteProfiles.edges.flatMap(
    ({ node }) => (node.normalizedTargetUrl === normalizedTargetUrl ? node : []),
  );

  profilesWithNormalizedTargetUrl.forEach(({ id }) => {
    store.writeFragment({
      id: `DastSiteProfile:${id}`,
      fragment: gql`
        fragment profile on DastSiteProfile {
          validationStatus
          __typename
        }
      `,
      data: {
        validationStatus: status,
        __typename: 'DastSiteProfile',
      },
    });
  });
};
