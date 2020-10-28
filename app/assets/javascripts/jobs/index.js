import Vue from 'vue';
import { pick } from 'lodash';
import JobApp from './components/job_app.vue';
import createStore from './store';

export default () => {
  const element = document.getElementById('js-job-vue-app');

  const store = createStore();

  // Let's start initializing the store (i.e. fetching data) right away
  store.dispatch('init', element.dataset);

  return new Vue({
    el: element,
    store,
    components: {
      JobApp,
    },
    render(createElement) {
      return createElement('job-app', {
        props: pick(element.dataset, [
          'artifactHelpUrl',
          'deploymentHelpUrl',
          'runnerHelpUrl',
          'runnerSettingsUrl',
          'variablesSettingsUrl',
          'subscriptionsMoreMinutesUrl',
          'endpoint',
          'pagePath',
          'logState',
          'buildStatus',
          'projectPath',
        ]),
      });
    },
  });
};
