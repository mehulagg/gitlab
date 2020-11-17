import Vue from 'vue';
import Translate from '~/vue_shared/translate';
import createStore from './store';
import GeoSettingsApp from './components/app.vue';

Vue.use(Translate);

export default () => {
  const el = document.getElementById('js-geo-settings-form');

  return new Vue({
    el,
    store: createStore(),
    components: {
      GeoSettingsApp,
    },

    render(createElement) {
      return createElement('geo-settings-app');
    },
  });
};
