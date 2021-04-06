import { getIdFromGraphQLId } from '~/graphql_shared/utils';
import {
  redirectTo,
  setUrlParams,
  relativePathToAbsolute,
  getBaseURL,
} from '~/lib/utils/url_utility';

export const returnToPreviousPageFactory = ({
  onDemandScansPath,
  profilesLibraryPath,
  urlParamKey,
}) => ({ id } = {}) => {
  // when previous page is not On-demand scans page
  // redirect user to profiles library page
  if (!document.referrer?.includes(onDemandScansPath)) {
    return redirectTo(profilesLibraryPath);
  }

  // Otherwise, redirect them back to On-demand scans page
  // with corresponding profile id, if available
  // for example, /on_demand_scans?site_profile_id=35
  const previousPagePath = id
    ? setUrlParams(
        { [urlParamKey]: getIdFromGraphQLId(id) },
        relativePathToAbsolute(onDemandScansPath, getBaseURL()),
      )
    : onDemandScansPath;
  return redirectTo(previousPagePath);
};
