import Vue from 'vue';
import { convertObjectPropsToCamelCase } from '~/lib/utils/common_utils';
import apolloProvider from './graphql/provider';
import DastSiteProfileForm from './components/dast_site_profile_form.vue';

export default () => {
  const el = document.querySelector('.js-dast-site-profile-form');
  if (!el) {
    return;
  }

  const { fullPath, profilesLibraryPath, onDemandScansPath } = el.dataset;

  const props = {
    fullPath,
    profilesLibraryPath,
    onDemandScansPath,
  };

  if (el.dataset.siteProfile) {
    props.siteProfile = convertObjectPropsToCamelCase(JSON.parse(el.dataset.siteProfile));
  }

  // eslint-disable-next-line no-new
  new Vue({
    el,
    apolloProvider,
    render(h) {
      return h(DastSiteProfileForm, {
        props,
      });
    },
  });
};
