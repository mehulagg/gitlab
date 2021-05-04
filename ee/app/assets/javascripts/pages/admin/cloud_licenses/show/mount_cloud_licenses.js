import Vue from 'vue';
import VueApollo from 'vue-apollo';
import { helpPagePath } from '~/helpers/help_page_helper';
import createDefaultClient from '~/lib/graphql';
import { parseBoolean } from '~/lib/utils/common_utils';
import CloudLicenseShowApp from '../components/app.vue';

Vue.use(VueApollo);

const apolloProvider = new VueApollo({
  defaultClient: createDefaultClient(
    {},
    {
      assumeImmutableResults: true,
    },
  ),
});

export default () => {
  const el = document.getElementById('js-show-cloud-license-page');

  if (!el) {
    return null;
  }

  const { hasActiveLicense, freeTrialPath, buySubscriptionPath, subscriptionSyncPath } = el.dataset;
  const connectivityHelpURL = helpPagePath('/user/admin_area/license.html', {
    anchor: 'activate-gitlab-ee-with-a-license',
  });

  return new Vue({
    el,
    apolloProvider,
    provide: {
      freeTrialPath,
      buySubscriptionPath,
      connectivityHelpURL,
      subscriptionSyncPath,
    },
    render: (h) =>
      h(CloudLicenseShowApp, {
        props: {
          hasActiveLicense: parseBoolean(hasActiveLicense),
        },
      }),
  });
};
