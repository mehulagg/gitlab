import axios from '~/lib/utils/axios_utils';
import * as types from './mutation_types';

export const requestPlatforms = ({ state, commit, getters, dispatch }) => {
  axios
    .get(state.platformsPath)
    .then(resp => {
      commit(types.SET_AVAILABLE_PLATFORMS, resp?.data);
      // Select the first platform and architecture
      const platform = Object.keys(resp.data)[0];

      commit(types.SET_AVAILABLE_PLATFORM, platform);
      dispatch('selectArchitecture', getters.getSupportedArchitectures[0]);
      dispatch('requestPlatformsInstructions');
    })
    .catch(() => dispatch('toggleAlert', true));
};

export const requestPlatformsInstructions = ({ commit, state, dispatch }) => {
  let path = `${state.instructionsPath}?os=${state.selectedAvailablePlatform}`;
  path =
    state.selectedArchitecture !== ''
      ? `${path}&arch=${state.selectedArchitecture}`
      : `${path}&arch=amd64`;

  axios
    .get(path)
    .then(resp => commit(types.SET_INSTRUCTIONS, resp?.data))
    .catch(() => dispatch('toggleAlert', true));
};

export const startInstructionsRequest = ({ dispatch }, architecture) => {
  dispatch('selectArchitecture', architecture);
  dispatch('requestPlatformsInstructions');
};

export const selectPlatform = ({ commit, dispatch, getters }, platform) => {
  commit(types.SET_AVAILABLE_PLATFORM, platform);

  const architecture = getters.getSupportedArchitectures
    ? getters.getSupportedArchitectures[0]
    : '';
  dispatch('selectArchitecture', architecture);
  dispatch('requestPlatformsInstructions');
};

export const selectArchitecture = ({ commit }, architecture) => {
  commit(types.SET_ARCHITECTURE, architecture);
};

export const toggleAlert = ({ commit }, state) => {
  commit(types.SET_SHOW_ALERT, state);
};
