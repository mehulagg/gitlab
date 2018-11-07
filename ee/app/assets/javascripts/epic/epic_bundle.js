import Vue from 'vue';
import { mapActions } from 'vuex';

import Cookies from 'js-cookie';
import bp from '~/breakpoints';
import { convertObjectPropsToCamelCase } from '~/lib/utils/common_utils';

import createStore from './store';
import EpicApp from './components/epic_app.vue';

export default () => {
  const el = document.getElementById('epic-app-root');
  const epicMeta = convertObjectPropsToCamelCase(JSON.parse(el.dataset.meta), { deep: true });
  const epicData = JSON.parse(el.dataset.initial);
  const store = createStore();

  // Collapse the sidebar on mobile screens by default
  const bpBreakpoint = bp.getBreakpointSize();
  if (bpBreakpoint === 'xs' || bpBreakpoint === 'sm') {
    Cookies.set('collapsed_gutter', true);
  }

  return new Vue({
    el,
    store,
    components: { EpicApp },
    created() {
      this.setEpicMeta(epicMeta);
      this.setEpicData(epicData);
    },
    methods: {
      ...mapActions(['setEpicMeta', 'setEpicData']),
    },
    render: createElement => createElement('epic-app'),
  });
};
