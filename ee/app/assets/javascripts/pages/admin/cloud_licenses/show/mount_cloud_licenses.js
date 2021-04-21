import Vue from 'vue';
import VueApollo from 'vue-apollo';
import createDefaultClient from '~/lib/graphql';
import { parseBoolean } from '~/lib/utils/common_utils';
import CloudLicenseShowApp from '../components/app.vue';

Vue.use(VueApollo);

const apolloProvider = new VueApollo({
  defaultClient: createDefaultClient(),
});

export default () => {
  const el = document.getElementById('js-show-cloud-license-page');

  if (!el) {
    return null;
  }

  const { hasActiveLicense } = el.dataset;

  return new Vue({
    el,
    apolloProvider,
    render: (h) =>
      h(CloudLicenseShowApp, {
        props: {
          hasActiveLicense: parseBoolean(hasActiveLicense),
        },
      }),
  });
};
