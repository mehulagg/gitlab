import Vue from 'vue';
import VueApollo from 'vue-apollo';
import createStore from 'ee_else_ce/issue_show/components/incidents/store';
import createDefaultClient from '~/lib/graphql';
import issuableApp from './components/app.vue';
import incidentTabs from './components/incidents/incident_tabs.vue';
import { parseBoolean } from '~/lib/utils/common_utils';

Vue.use(VueApollo);

export default function initIssuableApp(issuableData = {}) {
  const apolloProvider = new VueApollo({
    defaultClient: createDefaultClient(),
  });

  const {
    canUpdate,
    iid,
    projectNamespace,
    projectPath,
    projectId,
    slaFeatureAvailable,
    uploadMetricsFeatureAvailable,
  } = issuableData;

  const fullPath = `${projectNamespace}/${projectPath}`;

  return new Vue({
    el: document.getElementById('js-issuable-app'),
    apolloProvider,
    // Only create store if createStore exists.
    ...(createStore && { store: createStore({ projectId, issueIid: iid }) }),
    components: {
      issuableApp,
    },
    provide: {
      canUpdate,
      fullPath,
      iid,
      slaFeatureAvailable: parseBoolean(slaFeatureAvailable),
      uploadMetricsFeatureAvailable: parseBoolean(uploadMetricsFeatureAvailable),
    },
    render(createElement) {
      return createElement('issuable-app', {
        props: {
          ...issuableData,
          descriptionComponent: incidentTabs,
          showTitleBorder: false,
        },
      });
    },
  });
}
