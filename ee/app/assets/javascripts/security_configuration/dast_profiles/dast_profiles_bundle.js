import Vue from 'vue';
import apolloProvider from './graphql/provider';
import DastProfiles from './components/dast_profiles.vue';

export default () => {
  const el = document.querySelector('.js-dast-profiles');

  if (!el) {
    return undefined;
  }

  const {
    dataset: { newDastScannerProfilePath, newDastSiteProfilePath, projectFullPath },
  } = el;

  const provide = {
    projectFullPath,
  };

  const props = {
    createNewProfilePaths: {
      scannerProfile: newDastScannerProfilePath,
      siteProfile: newDastSiteProfilePath,
    },
  };

  return new Vue({
    el,
    apolloProvider,
    provide,
    render(h) {
      return h(DastProfiles, {
        props,
      });
    },
  });
};
