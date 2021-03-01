import gql from 'graphql-tag';
import { produce } from 'immer';
import dastScannerProfilesQuery from 'ee/security_configuration/dast_profiles/graphql/dast_scanner_profiles.query.graphql';
import dastSiteProfilesQuery from 'ee/security_configuration/dast_profiles/graphql/dast_site_profiles.query.graphql';

export const addOrUpdateProfile = ({ isNew, fullPath, profile, store }) => {
  const queryBody = {
    query: dastScannerProfilesQuery,
    variables: {
      fullPath,
    },
  };

  if (isNew) {
    const sourceData = store.readQuery(queryBody);

    const data = produce(sourceData, (draftState) => {
      let newProfile = {
        node: {
          ...profile,
          editPath: 'a',
          __typename: 'DastScannerProfile',
        },
        cursor: 'eyJpZCI6IjEzIn0',
        __typename: 'DastScannerProfileEdge',
      };

      // eslint-disable-next-line no-param-reassign
      draftState.project.scannerProfiles.edges = [
        ...draftState.project.scannerProfiles.edges,
        newProfile,
      ];
    });

    store.writeQuery({ ...queryBody, data });
  } else {
    store.writeFragment({
      id: `DastScannerProfile:${profile.id}`,
      fragment: gql`
        fragment profile on DastScannerProfile {
          profileName
          spiderTimeout
          targetTimeout
          scanType
          useAjaxSpider
          showDebugMessages
          __typename
        }
      `,
      data: {
        ...profile,
        __typename: 'DastScannerProfile',
      },
    });
  }
};

// export const updateProfile = ({ fullPath, profile, store }) => {
//   const sourceData = store.readQuery(queryBody);

//   const profilesWithNormalizedTargetUrl = sourceData.project.scannerProfiles.edges.flatMap(
//     ({ node }) => (node.id === profile.id ? node : []),
//   );

//   profilesWithNormalizedTargetUrl.forEach(({ id }) => {
//     store.writeFragment({
//       id: `DastScannerProfile:${id}`,
//       fragment: gql`
//         fragment profile on DastScannerProfile {
//           profileName
//           spiderTimeout
//           targetTimeout
//           scanType
//           useAjaxSpider
//           showDebugMessages
//           __typename
//         }
//       `,
//       data: {
//         ...profile,
//         __typename: 'DastScannerProfile',
//       },
//     });
//   });
// };

// export const addProfile = ({ fullPath, profile, store }) => {
//   const queryBody = {
//     query: dastScannerProfilesQuery,
//     variables: {
//       fullPath,
//     },
//   };

//   const sourceData = store.readQuery(queryBody);

//   const data = produce(sourceData, (draftState) => {
//     let newProfile = {
//       ...draftState.project.scannerProfiles.edges[0],
//       node: {
//         id: 'gid://gitlab/DastScannerProfile/66',
//         profileName: 'Dj1',
//         scanType: 'ACTIVE',
//         showDebugMessages: true,
//         editPath: 'a',
//         spiderTimeout: 12,
//         targetTimeout: 2,
//         useAjaxSpider: true,
//         __typename: 'DastScannerProfile',
//       },
//     };
//     // eslint-disable-next-line no-param-reassign
//     draftState.project.scannerProfiles.edges = [
//       ...draftState.project.scannerProfiles.edges,
//       newProfile,
//     ];
//   });

//   store.writeQuery({ ...queryBody, data });
// };
