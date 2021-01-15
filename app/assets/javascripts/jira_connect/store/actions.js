import * as types from './mutation_types';

export const setErrorMessage = ({ commit }, errorMessage) => {
  commit(types.SET_ERROR_MESSAGE, errorMessage);
};
