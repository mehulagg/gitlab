import Vue from 'vue';
import VueApollo from 'vue-apollo';
import createDefaultClient from '~/lib/graphql';
import CiCdAnalyticsApp from './components/app.vue';

Vue.use(VueApollo);

const apolloProvider = new VueApollo({
  defaultClient: createDefaultClient(),
});

export default () => {
  const el = document.querySelector('#js-group-ci-cd-analytics-app');

  if (!el) return false;

  const { fullPath } = el.dataset;

  return new Vue({
    el,
    apolloProvider,
    provide: {
      groupPath: fullPath,
    },
    render: (createElement) => createElement(CiCdAnalyticsApp),
  });
};
