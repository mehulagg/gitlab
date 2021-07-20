import dastScannerProfilesQuery from 'ee/security_configuration/dast_profiles/graphql/dast_scanner_profiles.query.graphql';
import dastSiteProfilesQuery from 'ee/security_configuration/dast_profiles/graphql/dast_site_profiles.query.graphql';
import { s__ } from '~/locale';

export const ERROR_RUN_SCAN = 'ERROR_RUN_SCAN';
export const ERROR_FETCH_SCANNER_PROFILES = 'ERROR_FETCH_SCANNER_PROFILES';
export const ERROR_FETCH_SITE_PROFILES = 'ERROR_FETCH_SITE_PROFILES';

export const ERROR_MESSAGES = {
  [ERROR_RUN_SCAN]: s__('OnDemandScans|Could not run the scan. Please try again.'),
  [ERROR_FETCH_SCANNER_PROFILES]: s__(
    'OnDemandScans|Could not fetch scanner profiles. Please refresh the page, or try again later.',
  ),
  [ERROR_FETCH_SITE_PROFILES]: s__(
    'OnDemandScans|Could not fetch site profiles. Please refresh the page, or try again later.',
  ),
};

export const SCANNER_PROFILES_QUERY = {
  field: 'dastScannerProfileId',
  fetchQuery: dastScannerProfilesQuery,
  fetchError: ERROR_FETCH_SCANNER_PROFILES,
};

export const SITE_PROFILES_QUERY = {
  field: 'dastSiteProfileId',
  fetchQuery: dastSiteProfilesQuery,
  fetchError: ERROR_FETCH_SITE_PROFILES,
};
