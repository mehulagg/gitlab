import * as types from './mutation_types';

export default {
  [types.SET_AVAILABLE_PLATFORMS](state, platforms) {
    state.availablePlatforms = platforms;
  },
  [types.SET_AVAILABLE_PLATFORM](state, index) {
    state.selectedAvailablePlatform = index;
  },
  [types.SET_ARCHITECTURE](state, index) {
    state.selectedArchitecture = index;
  },
  [types.SET_INSTRUCTIONS](state, instructions) {
    state.instructions = instructions;
  },
  [types.SET_SHOW_ALERT](state, show) {
    state.showAlert = show;
  },
};
