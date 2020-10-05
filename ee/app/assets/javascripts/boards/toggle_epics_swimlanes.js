import Vue from 'vue';
import ToggleEpicsSwimlanes from './components/toggle_epics_swimlanes.vue';
import store from '~/boards/stores';

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
