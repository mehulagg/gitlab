import Vue from 'vue';
import { convertObjectPropsToCamelCase } from '~/lib/utils/common_utils';
import apolloProvider from './graphql/provider';
import DastScannerProfileForm from './components/dast_scanner_profile_form.vue';

export default () => {
  const el = document.querySelector('.js-dast-scanner-profile-form');
  if (!el) {
    return false;
  }

  const { projectFullPath, profilesLibraryPath, onDemandScansPath } = el.dataset;

  const props = {
    projectFullPath,
    profilesLibraryPath,
    onDemandScansPath,
  };

  if (el.dataset.scannerProfile) {
    props.profile = convertObjectPropsToCamelCase(JSON.parse(el.dataset.scannerProfile));
  }

  return new Vue({
    el,
    apolloProvider,
    render(h) {
      return h(DastScannerProfileForm, {
        props,
      });
    },
  });
};
