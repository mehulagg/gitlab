import Vue from 'vue';
import VueApollo from 'vue-apollo';
import { parseBoolean } from '~/lib/utils/common_utils';
import PolicyEditorApp from './components/policy_editor/policy_editor.vue';
import createStore from './store';
import { gqClient } from './utils';

Vue.use(VueApollo);

const apolloProvider = new VueApollo({
  defaultClient: gqClient,
});

export default () => {
  const el = document.querySelector('#js-policy-builder-app');
  const {
    assignedPolicyProject,
    disableScanExecutionUpdate,
    environmentsEndpoint,
    configureAgentHelpPath,
    createAgentHelpPath,
    networkPoliciesEndpoint,
    threatMonitoringPath,
    policy,
    projectPath,
    projectId,
    environmentId,
  } = el.dataset;

  const store = createStore();
  store.dispatch('threatMonitoring/setEndpoints', {
    environmentsEndpoint,
  });
  store.dispatch('networkPolicies/setEndpoints', {
    networkPoliciesEndpoint,
  });

  if (environmentId !== undefined) {
    store.dispatch('threatMonitoring/setCurrentEnvironmentId', parseInt(environmentId, 10));
  }

  const props = {};

  if (assignedPolicyProject) {
    props.assignedPolicyProject = JSON.parse(assignedPolicyProject) || undefined;
  }

  if (policy) {
    props.existingPolicy = JSON.parse(policy);
  }

  return new Vue({
    el,
    apolloProvider,
    provide: {
      configureAgentHelpPath,
      createAgentHelpPath,
      disableScanExecutionUpdate: parseBoolean(disableScanExecutionUpdate),
      projectId,
      projectPath,
      threatMonitoringPath,
    },
    store,
    render(createElement) {
      return createElement(PolicyEditorApp, { props });
    },
  });
};
