import axios from '~/lib/utils/axios_utils';
import statusCodes from '~/lib/utils/http_status';
import createFlash from '~/flash';
import { __ } from '~/locale';
import * as types from './mutation_types';

export const requestPlatforms = ({ state, commit, getters, dispatch }) => {
  axios
    .get(state.platformsPath)
    .then(resp => {
      if (resp.status === statusCodes.OK) {
        commit(types.SET_AVAILABLE_PLATFORMS, resp?.data);
        // Select the first platform and architecture
        const platform = Object.keys(resp.data)[0];

        commit(types.SET_AVAILABLE_PLATFORM, platform);
        dispatch('selectArchitecture', getters.getSupportedArchitectures[0]);
        dispatch('requestPlatformsInstructions');
      }
    })
    .catch(() => createFlash({ message: __('An error has occurred') }));
};

export const requestPlatformsInstructions = ({ commit, state }) => {
  let path = `${state.instructionsPath}?os=${state.selectedAvailablePlatform}`;
  path =
    state.selectedArchitecture !== ''
      ? `${path}&arch=${state.selectedArchitecture}`
      : `${path}&arch=amd64`;

  axios
    .get(path)
    .then(resp => {
      if (resp.status === statusCodes.OK) {
        commit(types.SET_INSTRUCTIONS, resp?.data);
      }
    })
    .catch(() =>
      createFlash({ message: __('An error has occurred fetching platform instructions') }),
    );
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
