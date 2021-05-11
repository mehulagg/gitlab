import Vue from 'vue';
import VueApollo from 'vue-apollo';
import createDefaultClient from '~/lib/graphql';
import ThreatMonitoringApp from './components/app.vue';
import createStore from './store';

Vue.use(VueApollo);

const apolloProvider = new VueApollo({
  defaultClient: createDefaultClient(),
});

export default () => {
  const el = document.querySelector('#js-threat-monitoring-app');
  const {
    networkPolicyStatisticsEndpoint,
    environmentsEndpoint,
    networkPoliciesEndpoint,
    emptyStateSvgPath,
    networkPolicyNoDataSvgPath,
    newPolicyPath,
    documentationPath,
    defaultEnvironmentId,
    projectPath,
  } = el.dataset;

  const store = createStore();
  store.dispatch('threatMonitoring/setEndpoints', {
    networkPolicyStatisticsEndpoint,
    environmentsEndpoint,
  });
  store.dispatch('networkPolicies/setEndpoints', {
    networkPoliciesEndpoint,
  });

  return new Vue({
    apolloProvider,
    el,
    provide: {
      documentationPath,
      emptyStateSvgPath,
      projectPath,
    },
    store,
    render(createElement) {
      return createElement(ThreatMonitoringApp, {
        props: {
          networkPolicyNoDataSvgPath,
          defaultEnvironmentId: parseInt(defaultEnvironmentId, 10),
          newPolicyPath,
        },
      });
    },
  });
};
