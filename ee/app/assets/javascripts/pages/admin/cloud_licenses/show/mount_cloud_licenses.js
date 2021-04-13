import Vue from 'vue';
import VueApollo from 'vue-apollo';
import createDefaultClient from '~/lib/graphql';
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

  const { planName, freeTrialPath, buySubscriptionPath } = el.dataset;

  return new Vue({
    el,
    apolloProvider,
    provide: {
      planName,
      freeTrialPath,
      buySubscriptionPath,
    },
    render: (h) => h(CloudLicenseShowApp),
  });
};
