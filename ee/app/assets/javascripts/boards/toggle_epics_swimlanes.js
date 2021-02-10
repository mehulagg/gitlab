import Vue from '~/lib/vue_with_runtime_compiler';
import store from '~/boards/stores';
import ToggleEpicsSwimlanes from './components/toggle_epics_swimlanes.vue';

export default () => {
  const el = document.getElementById('js-board-epics-swimlanes-toggle');

  if (!el) {
    return null;
  }

  return new Vue({
    el,
    components: {
      ToggleEpicsSwimlanes,
    },
    store,
    render(createElement) {
      return createElement(ToggleEpicsSwimlanes);
    },
  });
};
