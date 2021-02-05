import { DEFAULT_MAINTENANCE_ENABLED, DEFAULT_BANNER_MESSAGE } from '../constants';
import * as types from './mutation_types';

export default {
  [types.REQUEST_UPDATE_MAINTENANCE_MODE_SETTINGS](state) {
    state.loading = true;
  },
  [types.RECEIVE_UPDATE_MAINTENANCE_MODE_SETTINGS_SUCCESS](
    state,
    { maintenanceEnabled, bannerMessage },
  ) {
    state.loading = false;
    state.maintenanceEnabled = maintenanceEnabled;
    state.bannerMessage = bannerMessage;
  },
  [types.RECEIVE_UPDATE_MAINTENANCE_MODE_SETTINGS_ERROR](state) {
    state.loading = false;
    state.maintenanceEnabled = DEFAULT_MAINTENANCE_ENABLED;
    state.bannerMessage = DEFAULT_BANNER_MESSAGE;
  },
  [types.SET_MAINTENANCE_ENABLED](state, maintenanceEnabled) {
    state.maintenanceEnabled = maintenanceEnabled;
  },
  [types.SET_BANNER_MESSAGE](state, bannerMessage) {
    state.bannerMessage = bannerMessage;
  },
};
