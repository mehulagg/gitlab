import {
  redirectTo,
  setUrlParams,
  relativePathToAbsolute,
  getBaseURL,
} from '~/lib/utils/url_utility';
import { getIdFromGraphQLId } from '~/graphql_shared/utils';

export const returnToPreviousPageFactory = ({
  onDemandScansPath,
  profilesLibraryPath,
  urlParamKey,
}) => (gid) => {
  // when previous page is not On-demand scans page
  // redirect user to profiles library page
  if (!document.referrer?.includes(onDemandScansPath)) {
    return redirectTo(profilesLibraryPath);
  }

  // Otherwise, redirect them back to On-demand scans page
  // with corresponding profile id, if available
  // for example, /on_demand_scans?site_profile_id=35
  const previousPagePath = gid
    ? setUrlParams(
        { [urlParamKey]: getIdFromGraphQLId(gid) },
        relativePathToAbsolute(onDemandScansPath, getBaseURL()),
      )
    : onDemandScansPath;
  return redirectTo(previousPagePath);
};
