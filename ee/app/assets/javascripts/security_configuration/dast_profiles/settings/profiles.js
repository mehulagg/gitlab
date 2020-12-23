import dastSiteProfilesQuery from 'ee/security_configuration/dast_profiles/graphql/dast_site_profiles.query.graphql';
import dastSiteProfilesDelete from 'ee/security_configuration/dast_profiles/graphql/dast_site_profiles_delete.mutation.graphql';
import dastScannerProfilesQuery from 'ee/security_configuration/dast_profiles/graphql/dast_scanner_profiles.query.graphql';
import dastScannerProfilesDelete from 'ee/security_configuration/dast_profiles/graphql/dast_scanner_profiles_delete.mutation.graphql';
import { dastProfilesDeleteResponse } from 'ee/security_configuration/dast_profiles/graphql/cache_utils';
import DastSiteProfileList from 'ee/security_configuration/dast_profiles/components/dast_site_profiles_list.vue';
import DastScannerProfileList from 'ee/security_configuration/dast_profiles/components/dast_scanner_profiles_list.vue';
import { s__ } from '~/locale';

export const getProfileSettings = ({ createNewProfilePaths }) => ({
  siteProfiles: {
    profileType: 'siteProfiles',
    createNewProfilePath: createNewProfilePaths.siteProfile,
    graphQL: {
      query: dastSiteProfilesQuery,
      deletion: {
        mutation: dastSiteProfilesDelete,
        optimisticResponse: dastProfilesDeleteResponse({
          mutationName: 'siteProfilesDelete',
          payloadTypeName: 'DastSiteProfileDeletePayload',
        }),
      },
    },
    component: DastSiteProfileList,
    tableFields: [
      { label: s__('Site name'), key: 'profileName' },
      { label: s__('URL'), key: 'targetUrl' },
      { label: s__('Validation Status'), key: 'validationStatus' },
    ],
    i18n: {
      createNewLinkText: s__('DastProfiles|Site Profile'),
      name: s__('DastProfiles|Site Profiles'),
      errorMessages: {
        fetchNetworkError: s__(
          'DastProfiles|Could not fetch site profiles. Please refresh the page, or try again later.',
        ),
        deletionNetworkError: s__(
          'DastProfiles|Could not delete site profile. Please refresh the page, or try again later.',
        ),
        deletionBackendError: s__('DastProfiles|Could not delete site profiles:'),
      },
    },
  },
  scannerProfiles: {
    profileType: 'scannerProfiles',
    createNewProfilePath: createNewProfilePaths.scannerProfile,
    graphQL: {
      query: dastScannerProfilesQuery,
      deletion: {
        mutation: dastScannerProfilesDelete,
        optimisticResponse: dastProfilesDeleteResponse({
          mutationName: 'scannerProfilesDelete',
          payloadTypeName: 'DastScannerProfileDeletePayload',
        }),
      },
    },
    component: DastScannerProfileList,
    tableFields: [
      { label: s__('Scanner name'), key: 'profileName' },
      { label: s__('Scan mode'), key: 'scanType' },
    ],
    i18n: {
      createNewLinkText: s__('DastProfiles|Scanner Profile'),
      name: s__('DastProfiles|Scanner Profiles'),
      errorMessages: {
        fetchNetworkError: s__(
          'DastProfiles|Could not fetch scanner profiles. Please refresh the page, or try again later.',
        ),
        deletionNetworkError: s__(
          'DastProfiles|Could not delete scanner profile. Please refresh the page, or try again later.',
        ),
        deletionBackendError: s__('DastProfiles|Could not delete scanner profiles:'),
      },
    },
  },
});
