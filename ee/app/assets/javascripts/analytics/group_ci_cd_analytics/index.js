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

  return new Vue({
    el,
    apolloProvider,
    provide: {
      fullPath: 'releases-group', // TODO
    },
    render: (createElement) => createElement(CiCdAnalyticsApp),
  });
};
