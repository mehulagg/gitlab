import axios from '~/lib/utils/axios_utils';
import statusCodes from '~/lib/utils/http_status';
import createFlash from '~/flash';
import { __ } from '~/locale';
import * as types from './mutation_types';

export const requestOsInstructions = ({ state, commit }) => {
  axios
    .get(state.instructionsPath)
    .then(resp => {
      if (resp.status === statusCodes.OK) {
        commit(types.SET_AVAILABLE_PLATFORMS, resp.data?.available_platforms);
      }
    })
    .catch(() => createFlash({ message: __('An error has occurred') }));
};

export const requestArchitectureInstructions = ({ state, getters }) => {
  const params = {
    os: getters.getSelectedOS,
    arch: getters.getSelectedArchitecture,
  };

  axios
    .get(state.instructionsPath, params)
    .then(() => {
      // TODO: Commit here
    })
    .catch(() => {
      // TODO: Createflash here
    });
};

export const selectPlatform = ({ commit }, index) => {
  commit(types.SET_AVAILABLE_PLATFORM, index);
};

export const selectArchitecture = ({ commit }, index) => {
  commit(types.SET_ARCHITECTURE, index);
};
