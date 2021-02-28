import Vue from 'vue';
import { convertObjectPropsToCamelCase } from '~/lib/utils/common_utils';
import DastScannerProfileForm from './components/dast_scanner_profile_form.vue';
import apolloProvider from './graphql/provider';
import { redirectTo } from '~/lib/utils/url_utility';

export default () => {
  const el = document.querySelector('.js-dast-scanner-profile-form');
  if (!el) {
    return false;
  }

  const { projectFullPath, profilesLibraryPath } = el.dataset;

  const props = {
    projectFullPath,
  };

  if (el.dataset.scannerProfile) {
    props.profile = convertObjectPropsToCamelCase(JSON.parse(el.dataset.scannerProfile));
  }

  const redirectToProfilesLibrary = () => {
    redirectTo(profilesLibraryPath);
  };

  return new Vue({
    el,
    apolloProvider,
    render(h) {
      return h(DastScannerProfileForm, {
        props,
        on: {
          success: redirectToProfilesLibrary,
          cancel: redirectToProfilesLibrary,
        },
      });
    },
  });
};
