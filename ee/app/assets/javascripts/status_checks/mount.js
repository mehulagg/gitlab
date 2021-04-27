import Vue from 'vue';
import Vuex from 'vuex';
import ProjectSettingsApp from './components/app.vue';
import createStore from './store';

Vue.use(Vuex);

export default function mountProjectSettingsApprovals(el) {
  if (!el) {
    return null;
  }

  return new Vue({
    el,
    store: createStore(),
    render(h) {
      return h(ProjectSettingsApp);
    },
  });
}
