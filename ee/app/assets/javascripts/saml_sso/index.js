import {
  AUTO_REDIRECT_TO_PROVIDER_QUERY_PARAM,
  AUTO_REDIRECT_TO_PROVIDER_BUTTON_SELECTOR,
} from './constants';
import { getParameterByName, parseBoolean } from '~/lib/utils/common_utils';

export const redirectUserWithSSOIdentity = () => {
  const shouldRedirect = parseBoolean(getParameterByName(AUTO_REDIRECT_TO_PROVIDER_QUERY_PARAM));
  const signInButton = document.querySelector(AUTO_REDIRECT_TO_PROVIDER_BUTTON_SELECTOR);

  if (!shouldRedirect || !signInButton) {
    return;
  }

  signInButton.click();
};
