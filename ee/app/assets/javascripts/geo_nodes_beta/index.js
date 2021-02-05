import Vue from 'vue';
import Translate from '~/vue_shared/translate';
import GeoNodesBetaApp from './components/app.vue';

Vue.use(Translate);

export const initGeoNodesBeta = () => {
  const el = document.getElementById('js-geo-nodes-beta');

  if (!el) {
    return false;
  }

  return new Vue({
    el,
    render(createElement) {
      return createElement(GeoNodesBetaApp);
    },
  });
};
