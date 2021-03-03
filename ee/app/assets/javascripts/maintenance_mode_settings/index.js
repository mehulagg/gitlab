import Vue from 'vue';
import Translate from '~/vue_shared/translate';
import MaintenanceModeSettingsApp from './components/app.vue';
import { createStore } from './store';

Vue.use(Translate);

export const initMaintenanceModeSettings = () => {
  const el = document.getElementById('js-maintenance-mode-settings');

  if (!el) {
    return false;
  }

  const { maintenanceEnabled, bannerMessage } = el.dataset;

  return new Vue({
    el,
    store: createStore({ maintenanceEnabled, bannerMessage }),
    render(createElement) {
      return createElement(MaintenanceModeSettingsApp);
    },
  });
};
