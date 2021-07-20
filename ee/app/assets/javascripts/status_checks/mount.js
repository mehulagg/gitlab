import Vue from 'vue';
import Vuex from 'vuex';
import createFlash from '~/flash';
import { s__ } from '~/locale';
import StatusChecks from './components/status_checks.vue';
import createStore from './store';

Vue.use(Vuex);

export default function mountProjectSettingsApprovals(el) {
  if (!el) {
    return null;
  }

  const store = createStore();
  const { projectId, statusChecksPath } = el.dataset;

  store.dispatch('setSettings', { projectId, statusChecksPath });
  store.dispatch('fetchStatusChecks').catch((error) => {
    createFlash({
      message: s__('StatusCheck|An error occurred fetching the status checks.'),
      captureError: true,
      error,
    });
  });

  return new Vue({
    el,
    store,
    render(h) {
      return h(StatusChecks);
    },
  });
}
